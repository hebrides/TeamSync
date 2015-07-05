//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSPlayListDetailViewController.m
// Description		:	TSPlayListDetailViewController class Implementation.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import "TSPlayListDetailViewController.h"
#import "TSCommon.h"
#import "TSPlayListViewController.h"
#import "TSPlayListTableViewCell.h"
#import "TSPlaySongViewController.h"
#import "TSDeviceListViewController.h"
#import "NSDictionary+TSDeepCopyDictionary.h"
#import "TSSigninViewController.h"

@interface TSPlayListDetailViewController ()
- (void)setLayoutOfRetina4;
- (void)broadCastSongDetails:(NSDictionary*)details;
- (void) setScrollPositionOfClientTbl;
- (NSMutableDictionary*)  deepMutableCopy;
- (void)setupMusicPlayer;
- (void)removeNotifications;
- (void)broadCastVolumeChanges:(float)volume;
- (void)selectCurrentlyPlayingSong:(NSInteger)indexPos;
- (void) releaseAllMemory;
@end

@implementation TSPlayListDetailViewController
@synthesize infoDict;
@synthesize playListItems;
@synthesize songInfoDict;
@synthesize songNameArray;
@synthesize composerNameArray;
@synthesize songDict;
@synthesize tableYPosition;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil andDetails:(NSDictionary*)dict bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.infoDict = dict;
        self.songInfoDict = nil;
        self.songNameArray = [[NSMutableArray alloc]init];
        self.composerNameArray = [[NSMutableArray alloc]init];
        selectedRow = -1;
        self.tableYPosition = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    appController = [TSAppController sharedAppController];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeConnectButton) name:@"changeConnectButton" object:nil];
    
    appController.isCurrentViewLeft = YES;
    
    [self setupMusicPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendPlayListDetails) name:@"PlayListDetailsNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToCurrentSong) name:@"updatedSongNotification" object:nil];
    
    titleLabel.text = [self.infoDict objectForKey:PLAYLISTNAME];
    self.playListItems = [self.infoDict objectForKey:SONG_LIST];
   
    if(appController.isBroadcasted == YES)
    {
        broadcastButton.hidden = YES;
        broadcastLabel.hidden = YES;
        if([TSCommon isRetina4])
        {
            [self setLayoutOfRetina4];
        }
        else
        {
            [self.songListTableView setFrame:CGRectMake(self.songListTableView.frame.origin.x, self.songListTableView.frame.origin.y, self.songListTableView.frame.size.width, 364)];
        }
        
        [self sendPlayListDetails:NO];
    }
    else
    {
        if([TSCommon isRetina4])
        {
            bgImageView.frame = CGRectMake(bgImageView.frame.origin.x,bgImageView.frame.origin.y, bgImageView.frame.size.width, bgImageView.frame.size.height + 88);
            [broadcastButton setFrame:CGRectMake(broadcastButton.frame.origin.x, broadcastButton.frame.origin.y + 90, broadcastButton.frame.size.width, broadcastButton.frame.size.height)];
            [broadcastLabel setFrame:CGRectMake(broadcastLabel.frame.origin.x, broadcastLabel.frame.origin.y + 90, broadcastLabel.frame.size.width, broadcastLabel.frame.size.height)];
        }
            
    }

    if([self.playListItems count] <= 0)
    {
        broadcastButton.hidden = YES;
        broadcastLabel.hidden = YES;
    }
    
}

- (void) viewDidAppear:(BOOL)animated
{
    TSSCommunicationManager *commManager = [TSSCommunicationManager sharedInstance];
    NSInteger clientsAvailable = 0;
    if([[TSAppConfig getInstance].type isEqualToString:@"Master"])
    {
        commManager = [TSSCommunicationManager sharedInstance];
        clientsAvailable = commManager.localChatRoom.clientArr.count;
    }
    
    if(clientsAvailable > 0)
    {
        [disconnectButton setImage:TSLoadImageResource(@"connectBtn") forState:UIControlStateNormal];
    }
    else
    {
        [disconnectButton setImage:TSLoadImageResource(@"disconnectBtn") forState:UIControlStateNormal];
    }
    
    if([appController._selectedPlayList isEqualToString:[self.infoDict valueForKey:PLAYLISTNAME]])
    {
        if([self.infoDict valueForKey:@"SongIndex"])
        {
            NSInteger indxRow =  [[self.infoDict valueForKey:@"SongIndex"] integerValue];
            [self selectCurrentlyPlayingSong:indxRow];
        }
        else if( appController._currentIndex >= 0 )
            [self selectCurrentlyPlayingSong:appController._currentIndex];
    }
}

- (void)scrollToCurrentSong
{
    if([appController._selectedPlayList isEqualToString:[self.infoDict valueForKey:PLAYLISTNAME]])
    {
        if(appController._currentIndex >= 0)
        {
            NSInteger indxRow =  appController._currentIndex;
            [self selectCurrentlyPlayingSong:indxRow];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self releaseAllMemory];
    [super viewDidUnload];
}

- (void)setupMusicPlayer
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

    [notificationCenter addObserver:self
                           selector:@selector(handleNowPlayingItemChanged:)
                               name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                             object:appController.musicPlayer];

    [notificationCenter addObserver:self
                           selector:@selector(handleExternalVolumeChanged:)
                               name:MPMusicPlayerControllerVolumeDidChangeNotification
                             object:appController.musicPlayer];
    
    [appController.musicPlayer beginGeneratingPlaybackNotifications];
    
    [[MPMediaLibrary defaultMediaLibrary] beginGeneratingLibraryChangeNotifications];
    
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMusicPlayerControllerVolumeDidChangeNotification
                                                  object:appController.musicPlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                                                  object:appController.musicPlayer];
    
    [appController.musicPlayer endGeneratingPlaybackNotifications];
}

- (void)sendPlayListDetails:(BOOL) isScrolling
{
    [self.songNameArray removeAllObjects];
    [self.composerNameArray removeAllObjects];
    
    for(NSInteger index = 0; index < [self.playListItems count]; index++)
    {
        MPMediaItem *anItem = (MPMediaItem *)[self.playListItems.items objectAtIndex:index];
        NSString *composerName = @"";
        
        if (anItem)
        {
            [songNameArray addObject:[anItem valueForProperty:MPMediaItemPropertyTitle]];
            
            composerName = [anItem valueForProperty:MPMediaItemPropertyComposer];
            if([composerName length] != 0)
                [composerNameArray addObject:composerName];
            else
                [composerNameArray addObject:@""];
        }
    }
    
    disconnectButton.hidden = NO;
    
    [self.songListTableView reloadData];
    
    if(self.songListTableView.visibleCells && self.songListTableView.visibleCells.count > 0)
    {
        for(int i = 0;i < self.songListTableView.visibleCells.count;i++)
        {
            TSPlayListTableViewCell *objCell = self.songListTableView.visibleCells[i];
            indxPthRow = objCell.tag;
        }
    }
    
    NSString *nowPlayingItemName  = @"";
    NSString *currentDuration     = @"";
    
    float volumeData = appController.musicPlayer.volume;
    NSString *volumeInfo = [NSString stringWithFormat:@"%f",volumeData];
    
    if (appController.musicPlayer.playbackState == MPMusicPlaybackStatePlaying)
    {
        nowPlayingItemName = [[appController.musicPlayer nowPlayingItem] valueForProperty:MPMediaItemPropertyTitle];
        currentDuration = [NSString stringWithFormat:@"%f", appController.musicPlayer.currentPlaybackTime];
    }
    
    NSString *tablePos = [NSString stringWithFormat:@"%d", appController.yPosPlaylistTable];

    NSString *_updSongIndex = @"";
    if([self.infoDict valueForKey:@"SongIndex"])
    {
        _updSongIndex = [self.infoDict valueForKey:@"SongIndex"];
    }
       

    NSMutableDictionary *informationDict;
    if(!isScrolling)
    {
        
        informationDict = [NSMutableDictionary dictionaryWithObjectsAndKeys: titleLabel.text, PLAYLISTNAME, self.songNameArray, SONG_NAME, self.composerNameArray, COMPOSER_NAME,[NSString stringWithFormat:@"%d",appController._currentIndex], SONG_INDEX, nowPlayingItemName, PLAYING_ITEM_NAME, tablePos, TABLE_YPOS, currentDuration, PLAY_DURATION, volumeInfo, PLAYER_VOLUME, appController._selectedPlayList, BROADCASTED_PLAYLISTNAME, @"1", SONGLIST_VIEW_UNIQUE_ID, nil];
    }
    else
    {
        informationDict = [NSMutableDictionary dictionaryWithObjectsAndKeys: titleLabel.text, PLAYLISTNAME, self.songNameArray, SONG_NAME, self.composerNameArray, COMPOSER_NAME,@"", SONG_INDEX, nowPlayingItemName, PLAYING_ITEM_NAME, tablePos, TABLE_YPOS, currentDuration, PLAY_DURATION, volumeInfo, PLAYER_VOLUME, appController._selectedPlayList, BROADCASTED_PLAYLISTNAME, @"1", SONGLIST_VIEW_UNIQUE_ID, nil];

    }
    
    if(appController.isBroadcasted)
    {
        TSSCommunicationManager *commManager = [TSSCommunicationManager sharedInstance];
        if(commManager.localChatRoom.clientArr && commManager.localChatRoom.clientArr.count > 0)
        {
            if([TSCommon isNetworkConnected])
            {
               [commManager.chatRoom broadcastChatMessage:@"" andDetails:informationDict fromUser:[TSAppConfig getInstance].name selectedView:kSongListView];
            }
            else
            {
                appController.isBroadcasted = NO;
                TSSigninViewController *viewController = [[TSSigninViewController alloc]initWithNibName:@"TSSigninViewController" bundle:nil];
                viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentModalViewController:viewController animated:YES];
                
                TSSCommunicationManager *commManager = [TSSCommunicationManager sharedInstance];
                [commManager.chatRoom stop];
                
                [viewController didSelectedLogoutButton];
                
                MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
                
                if(musicPlayer.playbackState == MPMusicPlaybackStatePlaying)
                    [musicPlayer pause];
                
                [[NSNotificationCenter defaultCenter] removeObserver:self
                                                                name:MPMediaLibraryDidChangeNotification
                                                              object:nil];
                [TSCommon showAlert:@"Currently there is no connectivity, Please try later when you have WiFi or Cell Phone Signals."];
            }
        }
        
        [TSAppConfig getInstance].songInformationDict = informationDict;
    }

    [self.songListTableView reloadData];
    
    if(self.songNameArray && self.songNameArray.count == 0)
    {
        broadcastButton.hidden = YES;
        broadcastLabel.hidden = YES;
    }
}

- (void)changeConnectButton
{
    if(appController.clientCount > 0)
    {
        [disconnectButton setImage:TSLoadImageResource(@"connectBtn") forState:UIControlStateNormal];
    }
    else
    {
        [disconnectButton setImage:TSLoadImageResource(@"disconnectBtn") forState:UIControlStateNormal];
    }
}

- (IBAction)onBroadcastButtonPressed:(id)sender
{
    appController.isBroadcasted = YES;
    broadcastButton.hidden = YES;
    broadcastLabel.hidden = YES;
    
    if([TSCommon isRetina4])
    {
        [self setLayoutOfRetina4];
    }
    else
    {
        [self.songListTableView setFrame:CGRectMake(self.songListTableView.frame.origin.x, self.songListTableView.frame.origin.y, self.songListTableView.frame.size.width, 364)];
    }
    
    [self sendPlayListDetails:NO];
}

- (IBAction)onDisconnectButtonPressed:(id)sender
{
    TSDeviceListViewController *viewController = [[TSDeviceListViewController alloc]initWithNibName:@"TSDeviceListViewController" bundle:nil modifyTableInteraction:YES];
    viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:viewController animated:YES];

}

- (IBAction)onBackButtonPressed:(id)sender
{
    TSPlayListViewController *viewController = [[TSPlayListViewController alloc]initWithNibName:@"TSPlayListViewController" bundle:nil];
    viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:viewController animated:YES];
    viewController = nil;
    [self releaseAllMemory];
}


#pragma mark -
#pragma mark UITableview delegate methods
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%d",self.playListItems.count);
    return [self.playListItems count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier    = @"Not Set";
    TSPlayListTableViewCell *tableCell = (TSPlayListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    tableCell = nil;
    
    if (tableCell == nil)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"TSPlayListTableViewCell"
                                                       owner:[TSPlayListTableViewCell class]
                                                     options:nil];
        tableCell           = (TSPlayListTableViewCell*)[array objectAtIndex:0];
    }
    
    tableCell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableCell.tag = indexPath.row;
    tableCell.accessoryType = UITableViewCellAccessoryNone;
    tableCell.bgImageView.image = [UIImage imageNamed:@"greyBar.png"];
    
    if(selectedRow >= 0 && selectedRow == [indexPath row])
        tableCell.bgImageView.image = [UIImage imageNamed:@"redBar.png"];
    
    MPMediaItem *anItem = (MPMediaItem *)[self.playListItems.items objectAtIndex: [indexPath row]];
    
    if (anItem)
    {
        tableCell.playListNameLabel.text = [anItem valueForProperty:MPMediaItemPropertyTitle];
    }

    indxPthRow = indexPath.row;
    return tableCell;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!decelerate)
    {
        [self setScrollPositionOfClientTbl];
    }
        
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self setScrollPositionOfClientTbl];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([TSCommon isNetworkConnected])
    {
        TSPlayListTableViewCell *cell = (TSPlayListTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
        cell.bgImageView.image = [UIImage imageNamed:@"redBar.png"];
        
        NSDictionary *informationDict = nil;
        NSString *songIndex = @"";
        
        appController._selectedPlayList = [self.infoDict objectForKey:PLAYLISTNAME];
        
        if(!appController.isBroadcasted)
        {
            [self.songNameArray removeAllObjects];
            [self.composerNameArray removeAllObjects];
            
            for(NSInteger index = 0; index < [self.playListItems count]; index++)
            {
                MPMediaItem *anItem = (MPMediaItem *)[self.playListItems.items objectAtIndex:index];
                NSString *composerName = @"";
                
                if (anItem)
                {
                    [songNameArray addObject:[anItem valueForProperty:MPMediaItemPropertyTitle]];
                    
                    composerName = [anItem valueForProperty:MPMediaItemPropertyComposer];
                    if([composerName length] != 0)
                        [composerNameArray addObject:composerName];
                    else
                        [composerNameArray addObject:@""];
                }
            }
            
            songIndex = [NSString stringWithFormat:@"%d",indexPath.row];
            informationDict = [NSDictionary dictionaryWithObjectsAndKeys:titleLabel.text, PLAYLISTNAME, self.playListItems,SONG_LIST, songIndex, SONG_INDEX, nil];
            
            TSPlaySongViewController *viewController = [[TSPlaySongViewController alloc]initWithNibName:@"TSPlaySongViewController" withSongDetails:informationDict bundle:nil];
            viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentModalViewController:viewController animated:YES];
            viewController = nil;
        }
        else
        {
            songIndex = [NSString stringWithFormat:@"%d",indexPath.row];
            
            float volumeData = [[MPMusicPlayerController iPodMusicPlayer]volume];
            NSString *volumeInfo = [NSString stringWithFormat:@"%f",volumeData];
            
            NSString *prevBtnEnabled = @"";
            NSString *nextBtnEnabled = @"";
            
            NSInteger songCount = [self.songNameArray count];
            
            if(indexPath.row == 0 && songCount == 1)
            {
                prevBtnEnabled = @"NO";
                nextBtnEnabled = @"NO";
            }
            else if(indexPath.row == 0 && songCount > 1)
            {
                prevBtnEnabled = @"NO";
                nextBtnEnabled = @"YES";
            }
            else if(indexPath.row != 0 && indexPath.row  == (songCount - 1))
            {
                prevBtnEnabled = @"YES";
                nextBtnEnabled = @"NO";
            }
            else if(indexPath.row != 0 && indexPath.row < (songCount - 1))
            {
                prevBtnEnabled = @"YES";
                nextBtnEnabled = @"YES";
            }
                        
            NSString *_yPos = [NSString stringWithFormat:@"%d",appController.yPosPlaylistTable];            
            informationDict = [NSDictionary dictionaryWithObjectsAndKeys: titleLabel.text, PLAYLISTNAME, songIndex, SONG_INDEX,  self.songNameArray, SONG_NAME, self.composerNameArray, COMPOSER_NAME, volumeInfo, PLAYER_VOLUME, prevBtnEnabled, ENABLE_PREV_BTN, nextBtnEnabled, ENABLE_NEXT_BTN, @"Pause", PLAY_STATUS, @"nan", PLAY_DURATION, _yPos, TABLE_YPOS, appController._selectedPlayList, BROADCASTED_PLAYLISTNAME, @"2", SONGDETAILS_VIEW_UNIQUE_ID, nil];
            
            self.songDict = [informationDict deepMutableCopy];
            
            if(appController.isBroadcasted)
            {
                [TSAppConfig getInstance].songInformationDict = self.songDict;
            }
            
            [self broadCastSongDetails:informationDict];
            
            NSDictionary *_infoDict = [NSDictionary dictionaryWithObjectsAndKeys:titleLabel.text, PLAYLISTNAME, self.playListItems,SONG_LIST, songIndex, SONG_INDEX, _yPos, TABLE_YPOS, nil];
            
            TSPlaySongViewController *viewController = [[TSPlaySongViewController alloc]initWithNibName:@"TSPlaySongViewController" withSongDetails:_infoDict bundle:nil];
            
            viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentModalViewController:viewController animated:YES];
            viewController = nil;
            
        }
        [self releaseAllMemory];
    }
    else
    {
        appController.isBroadcasted = NO;
        TSSigninViewController *viewController = [[TSSigninViewController alloc]initWithNibName:@"TSSigninViewController" bundle:nil];
        viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:viewController animated:YES];
        
        TSSCommunicationManager *commManager = [TSSCommunicationManager sharedInstance];
        [commManager.chatRoom stop];
        
        [viewController didSelectedLogoutButton];
        
        MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
        
        if(musicPlayer.playbackState == MPMusicPlaybackStatePlaying)
            [musicPlayer pause];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:MPMediaLibraryDidChangeNotification
                                                      object:nil];
        
        [TSCommon showAlert:@"Currently there is no connectivity, Please try later when you have WiFi or Cell Phone Signals."];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TSPlayListTableViewCell *cell = (TSPlayListTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.bgImageView.image = [UIImage imageNamed:@"greyBar.png"];
    
}

- (void)broadCastSongDetails:(NSDictionary*)details
{
    disconnectButton.hidden = NO;
    appController.isBroadcasted = YES;
    
    [self.songNameArray removeAllObjects];
    [self.composerNameArray removeAllObjects];
    [self.songListTableView reloadData];
}

- (void) setScrollPositionOfClientTbl
{
    if(appController.isBroadcasted)
    {
        if(self.songListTableView.visibleCells && self.songListTableView.visibleCells.count > 0)
        {
            for(int i = 0;i < self.songListTableView.visibleCells.count;i++)
            {
                TSPlayListTableViewCell *objCell = self.songListTableView.visibleCells[i];
                indxPthRow = objCell.tag;
               // break;
            }
        }
        
        if([[TSAppConfig getInstance].type isEqualToString:@"Master"])
        {
            
            CGPoint tableViewCenter = [self.songListTableView contentOffset];
            self.tableYPosition = tableViewCenter.y;
            appController.yPosPlaylistTable = tableViewCenter.y;

            NSLog(@"SCROLLPOS = %d",appController.yPosPlaylistTable);
            
            [self sendPlayListDetails:YES];
            
        }
    }
    
}

- (void)broadCastVolumeChanges:(float)volume
{
    NSString *volumeString = [NSString stringWithFormat:@"%f",volume];
    
    TSSCommunicationManager *commManager = [TSSCommunicationManager sharedInstance];
    
    if([TSCommon isNetworkConnected])
    {
        [commManager.chatRoom broadcastChatMessage:volumeString andDetails:nil fromUser:[TSAppConfig getInstance].name selectedView:kSongVolumeChanges];
    }
    else
    {
        appController.isBroadcasted = NO;
        TSSigninViewController *viewController = [[TSSigninViewController alloc]initWithNibName:@"TSSigninViewController" bundle:nil];
        viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:viewController animated:YES];
        
        TSSCommunicationManager *commManager = [TSSCommunicationManager sharedInstance];
        [commManager.chatRoom stop];
        
        [viewController didSelectedLogoutButton];
        
        MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
        
        if(musicPlayer.playbackState == MPMusicPlaybackStatePlaying)
            [musicPlayer pause];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:MPMediaLibraryDidChangeNotification
                                                      object:nil];

        [TSCommon showAlert:@"Currently there is no connectivity, Please try later when you have WiFi or Cell Phone Signals."];
    }
}

#pragma mark-
#pragma mark - Notifications
#pragma mark-

// When the now playing item changes, update song info labels and artwork display.
- (void)handleNowPlayingItemChanged:(id)notification
{
    [delegate didChangedToNextSong];
}


// When the volume changes, sync the volume slider
- (void)handleExternalVolumeChanged:(id)notification
{
    if(appController.isBroadcasted == YES)
        [self broadCastVolumeChanges:appController.musicPlayer.volume];
}

#pragma mark -
#pragma mark portrait
#pragma mark -


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL) shouldAutorotate
{
    return YES;
}

#pragma mark -
#pragma mark iPhone5

- (void)setLayoutOfRetina4
{
    if([TSCommon isRetina4])
    {
        bgImageView.frame = CGRectMake(bgImageView.frame.origin.x,bgImageView.frame.origin.y, bgImageView.frame.size.width, bgImageView.frame.size.height + 88);
        
        self.songListTableView.frame = CGRectMake(self.songListTableView.frame.origin.x,self.songListTableView.frame.origin.y, self.songListTableView.frame.size.width, self.songListTableView.frame.size.height + 52);
    }
}

- (void)selectCurrentlyPlayingSong:(NSInteger)indexPos
{
    NSIndexPath *indexPath;
    indexPath = [NSIndexPath indexPathForRow:indexPos inSection:0];
    
    if(indexPos == self.playListItems.count)
        selectedRow = indexPos - 1;
    else
        selectedRow = indexPos;
    
    NSInteger rowPos;
    if([TSCommon isRetina4])
        rowPos = 9;
    else
        rowPos = 7;

    
    if(self.playListItems.count >= rowPos)
    {
        if(indexPos + rowPos >= self.playListItems.count - 1)
        {
            NSIndexPath *tmpIndexPath = [NSIndexPath indexPathForRow:self.playListItems.count - rowPos inSection:0];
            CGRect frame1 = [self.songListTableView rectForRowAtIndexPath:tmpIndexPath];
            [self.songListTableView setContentOffset:CGPointMake(0, frame1.origin.y) animated:NO];
            
        }
        else
        {
            indexPath = [NSIndexPath indexPathForRow:indexPos inSection:0];
            
            CGRect frame = [self.songListTableView rectForRowAtIndexPath:indexPath];
            [self.songListTableView setContentOffset:CGPointMake(0, frame.origin.y) animated:NO];
        }
    }
    else
    {
        [self.songListTableView setContentOffset:CGPointMake(0, 0) animated:NO];
    }
    
    if(indexPos < self.playListItems.count)
    {
        TSPlayListTableViewCell *cell = (TSPlayListTableViewCell*)[self.songListTableView cellForRowAtIndexPath:indexPath];
        cell.bgImageView.image = [UIImage imageNamed:@"redBar.png"];
        
        
        indexPath = [NSIndexPath indexPathForRow:indexPos - 1 inSection:0];
        if(indexPath)
        {
            cell = (TSPlayListTableViewCell*)[self.songListTableView cellForRowAtIndexPath:indexPath];
            cell.bgImageView.image = [UIImage imageNamed:@"greyBar.png"];
        }
        
        indexPath = [NSIndexPath indexPathForRow:indexPos + 1 inSection:0];
        if(indexPath)
        {
            cell = (TSPlayListTableViewCell*)[self.songListTableView cellForRowAtIndexPath:indexPath];
            cell.bgImageView.image = [UIImage imageNamed:@"greyBar.png"];
        }
    }
}



- (void) releaseAllMemory
{   
    [self removeNotifications];
    [self setSongListTableView:nil];
    titleLabel = nil;
    bgImageView = nil;
    disconnectButton = nil;
    broadcastButton = nil;
    broadcastLabel = nil;
    self.songNameArray= nil;
    self.composerNameArray = nil;
}

@end
