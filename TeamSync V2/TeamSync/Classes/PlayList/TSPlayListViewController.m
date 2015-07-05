//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSPlayListViewController.m
// Description		:	TSPlayListViewController class Implementation.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import "TSPlayListViewController.h"
#import "TSPlayListTableViewCell.h"
#import "TSSigninViewController.h"
#import "TSPlayListDetailViewController.h"
#import "TSCommon.h"

@interface TSPlayListViewController ()
- (void)getPlaylistDetails;
- (void)setLayoutOfRetina4;
- (void)getSongDetailsInPlaylist:(MPMediaPlaylist*)selectedPlayList andName:(NSString*)playListName;
@end

@implementation TSPlayListViewController
@synthesize playListNameArray;
@synthesize playListArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.playListNameArray = [[NSMutableArray alloc]init];
        self.playListArray = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    appController = [TSAppController sharedAppController];
    
    [TSAppConfig getInstance].songInformationDict = nil;
    appController.yPosPlaylistTable = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadSignInView) name:@"ConnectionTerminatedNotification" object:nil];
    
    [self setLayoutOfRetina4];
    [self getPlaylistDetails];
    
    UIDevice *device = [UIDevice currentDevice];
    
    NSString *systemName = [device model];
    
    if ([systemName rangeOfString:@"iPhone"].location == NSNotFound)
    {
        contactsButton.hidden = YES;
    }
    else
    {
        contactsButton.hidden = NO;
    }

}

- (void) loadSignInView
{
    [appController loadSignInScreenOnTermination];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getPlaylistDetails
{
    [self.playListNameArray removeAllObjects];
    [self.playListArray removeAllObjects];
    
    MPMediaQuery *playlistsQuery = [MPMediaQuery playlistsQuery];
    self.playListArray = (NSMutableArray*)[playlistsQuery collections];
    
    for (MPMediaPlaylist *playlist in self.playListArray)
    {
        NSString *playlistName = playlistName = [playlist valueForProperty: MPMediaPlaylistPropertyName];
        [self.playListNameArray addObject:playlistName];
    }
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
    return [self.playListNameArray count];
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
    
    tableCell.playListNameLabel.text = [self.playListNameArray objectAtIndex:indexPath.row];
    return tableCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TSPlayListTableViewCell *cell = (TSPlayListTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.bgImageView.image = [UIImage imageNamed:@"redBar.png"];
    
    NSString *playListName = [self.playListNameArray objectAtIndex:indexPath.row];
    NSDictionary *informationDict =	nil;
    
    if ([self.playListArray count] > 0)
    {
        MPMediaPlaylist *selectedplaylist = [self.playListArray objectAtIndex:[indexPath row]];
        
        informationDict = [NSDictionary dictionaryWithObjectsAndKeys:selectedplaylist,SONG_LIST, playListName, PLAYLISTNAME,  nil];

        if(appController.isBroadcasted)
        {
            [self getSongDetailsInPlaylist:selectedplaylist andName:playListName];
        }
        
        TSPlayListDetailViewController *viewController = [[TSPlayListDetailViewController alloc]initWithNibName:@"TSPlayListDetailViewController" andDetails:informationDict bundle:nil];
        
        viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:viewController animated:YES];
        
    }

}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TSPlayListTableViewCell *cell = (TSPlayListTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.bgImageView.image = [UIImage imageNamed:@"greyBar.png"];

}

- (void)getSongDetailsInPlaylist:(MPMediaPlaylist*)selectedPlayList andName:(NSString*)playListName
{
    NSMutableArray *songNameArray = [[NSMutableArray alloc]init];
    NSMutableArray *composerNameArray = [[NSMutableArray alloc]init];

    for(NSInteger index = 0; index < [selectedPlayList count]; index++)
    {
        MPMediaItem *anItem = (MPMediaItem *)[selectedPlayList.items objectAtIndex:index];
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
    
    if([selectedPlayList count])
    {
        appController.isBroadcasted = YES;
        
        NSString *nowPlayingItemName  = @"";
        NSString *currentDuration     = @"";
        
        float volumeData = appController.musicPlayer.volume;
        NSString *volumeInfo = [NSString stringWithFormat:@"%f",volumeData];
        
        if (appController.musicPlayer.playbackState == MPMusicPlaybackStatePlaying)
        {
            nowPlayingItemName = [[appController.musicPlayer nowPlayingItem] valueForProperty:MPMediaItemPropertyTitle];
            currentDuration = [NSString stringWithFormat:@"%f", appController.musicPlayer.currentPlaybackTime];
        }
        
        NSDate *systemTime = [NSDate date];
        NSString *devicetime = [NSString stringWithFormat:@"%@", systemTime];
        
        NSMutableDictionary *informationDict = [NSMutableDictionary dictionaryWithObjectsAndKeys: playListName, PLAYLISTNAME, songNameArray, SONG_NAME, composerNameArray, COMPOSER_NAME, nowPlayingItemName, PLAYING_ITEM_NAME, currentDuration, PLAY_DURATION, volumeInfo, PLAYER_VOLUME, @"1", SONGLIST_VIEW_UNIQUE_ID,[NSString stringWithFormat:@"%d", appController._currentIndex] ,SONG_INDEX, appController._selectedPlayList, BROADCASTED_PLAYLISTNAME, devicetime, MASTER_DEVICE_TIME, nil];
        
        TSSCommunicationManager *commManager = [TSSCommunicationManager sharedInstance];
        
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

        [songNameArray removeAllObjects];
        [composerNameArray removeAllObjects];
    }
}

- (IBAction)onSingOutButtonPressed:(id)sender
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
}

- (IBAction)onInviteClientsButtonPressed:(id)sender
{
    objContactViewController = [[TSContactsViewController alloc]init];
    [self presentModalViewController:objContactViewController animated:YES];
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

-(void)setLayoutOfRetina4
{
    if([TSCommon isRetina4])
    {
        bgImageView.frame = CGRectMake(bgImageView.frame.origin.x,bgImageView.frame.origin.y, bgImageView.frame.size.width, bgImageView.frame.size.height + 88);
        
        listTableView.frame = CGRectMake(listTableView.frame.origin.x,listTableView.frame.origin.y, listTableView.frame.size.width, listTableView.frame.size.height);
    }
}

- (void)viewDidUnload
{
    bgImageView = nil;
    listTableView = nil;
    contactsButton = nil;
    [super viewDidUnload];
}
@end
