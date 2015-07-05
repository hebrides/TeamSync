//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSClientSongListViewController.m
// Description		:	TSClientSongListViewController class Implementation.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import "TSClientSongListViewController.h"
#import "TSClientSongListViewCell.h"
#import "TSCommon.h"

@interface TSClientSongListViewController ()
- (void)checkForSongsinMusicStore;
- (void)setLayoutOfRetina4;
- (void)downloadSongwithName:(NSString*)songName andArtist:(NSString*)theArtistName;
- (BOOL)validateSpecialCharacters:(NSString *)string;
- (NSString*)getSongNameFromTitle:(NSString*)title andComposer:(NSString*)composerName;
- (void)customizeSystemVolumePopup:(BOOL)status;
@end

@implementation TSClientSongListViewController
@synthesize songNamesArray;
@synthesize composerNameArray;
@synthesize musicSongArray;
@synthesize operationQueue = _operationQueue;
@synthesize searching = _searching;
@synthesize infoDict;
@synthesize indxRow;
@synthesize yPos;

- (id)initWithNibName:(NSString *)nibNameOrNil withDetails:(NSDictionary*)songDict bundle:(NSBundle *)nibBundleOrNil selectedRowInde:(NSInteger)selRow
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.songNamesArray = [[NSMutableArray alloc]init];
        self.composerNameArray = [[NSMutableArray alloc]init];
        self.musicSongArray = [[NSMutableArray alloc]init];
        self.infoDict    = songDict;
        self.indxRow = selRow;
        selectedRow = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    appController = [TSAppController sharedAppController];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangedVolume) name:@"VolumeChangedNotification" object:nil];
    
    titleLabel.text = [self.infoDict objectForKey:PLAYLISTNAME];
    self.songNamesArray = [self.infoDict objectForKey:SONG_NAME];
    self.composerNameArray = [self.infoDict objectForKey:COMPOSER_NAME];
    
    self.yPos = 0;
    if([self.infoDict objectForKey:@"YPosition"])
    {
        self.yPos = [[self.infoDict objectForKey:@"YPosition"] integerValue];
    }
    
    NSString *nowPlayingItemName = @"";
    nowPlayingItemName = [self.infoDict  objectForKey:PLAYING_ITEM_NAME];

    if([TSCommon isRetina4])
    {
        [self setLayoutOfRetina4];
    }
    else
    {
        [self.listTableView setFrame:CGRectMake(self.listTableView.frame.origin.x, self.listTableView.frame.origin.y, self.listTableView.frame.size.width, 364)];
    }

    [self checkForSongsinMusicStore];
    
    if( nowPlayingItemName && ![nowPlayingItemName isEqualToString:@""])
    {
        MPMediaItem *selectedItem = nil;
        NSString *songTitle = @"";
        MPMediaQuery *everything = [[MPMediaQuery alloc] init];
        NSArray *itemsFromGenericQuery = [everything items];
        for (MPMediaItem *song in itemsFromGenericQuery)
        {
            songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
            
            if([songTitle rangeOfString:nowPlayingItemName].location == NSNotFound )
            {
               
            }
            else
            {
                NSLog (@"%@", songTitle);
                selectedItem = song;
                break;
            }
            
        }
        
        if(selectedItem)
        {
            MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:nowPlayingItemName forProperty:MPMediaItemPropertyTitle];
            MPMediaQuery *mySongQuery = [[MPMediaQuery alloc] init];
            [mySongQuery addFilterPredicate: predicate];
            [appController.musicPlayer setQueueWithQuery:mySongQuery];
            //[appController.musicPlayer play];
            
            float _volumeInfo = [[self.infoDict objectForKey:PLAYER_VOLUME]floatValue];
            NSString *intervalString = [self.infoDict objectForKey:PLAY_DURATION];
            
            double currentTime = appController.musicPlayer.currentPlaybackTime;
            double newInterval = [intervalString doubleValue];
            
            if(appController.deviceTimeDiff > 0)
            {
                NSString *masterNetworkTime = [self.infoDict objectForKey:MASTER_DEVICE_TIME];
                
                NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
                [dateFormatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss +0000"];
                NSDate *Masterdate = [dateFormatter1 dateFromString:masterNetworkTime];
                
                NSDate *systemTime = [NSDate date];
                NSString *clientDeviceTime = [NSString stringWithFormat:@"%@", systemTime];
                NSDate *Clientdate = [dateFormatter1 dateFromString:clientDeviceTime];
                
                NSTimeInterval timeDiff = [Clientdate timeIntervalSinceDate:Masterdate];
                
                if(timeDiff < 0)
                    timeDiff = fabs(timeDiff);
                
                NSTimeInterval orgTimeDiff = timeDiff - appController.deviceTimeDiff;

                if(orgTimeDiff > 0 && Masterdate != nil)
                {
                    [appController.musicPlayer play];
                    double _duration = newInterval + orgTimeDiff + 0.08;
                    appController.musicPlayer.currentPlaybackTime = _duration;
                }
                else
                {
                    NSInteger _curTime = (int)currentTime;
                    NSInteger _newTime = (int)newInterval;
                    
                    if(_curTime != _newTime)
                    {
                        [appController.musicPlayer play];
                        double _duration = newInterval + 0.08;
                        appController.musicPlayer.currentPlaybackTime = _duration;
                    }
                }
            }
            else
            {
                NSInteger _curTime = (int)currentTime;
                NSInteger _newTime = (int)newInterval;
                
                if(_curTime != _newTime)
                {
                    [appController.musicPlayer play];
                    double _duration = newInterval + 0.08;
                    appController.musicPlayer.currentPlaybackTime = _duration;
                }
            }
            
            [[MPMusicPlayerController iPodMusicPlayer] setVolume:_volumeInfo];
        }
    }
    
}


- (void) scrollToNewPosition:(NSInteger) indexValue rowIndexExists:(BOOL) isExists
{
    NSLog(@"CLIENT = %d",indexValue );
    if(isExists)
    {
        NSIndexPath *IndexPath = [NSIndexPath indexPathForRow:indexValue inSection:0];
        
        if(indexValue == self.songNamesArray.count)
            selectedRow = indexValue - 1;
        else
            selectedRow = indexValue;
        
        NSInteger rowPos = 0;
        if([TSCommon isRetina4])
            rowPos = 9;
        else
            rowPos = 7;
        
        
        if(self.songNamesArray.count >= rowPos)
        {
            if(indexValue + rowPos >= self.songNamesArray.count - 1)
            {
                NSIndexPath *tmpIndexPath = [NSIndexPath indexPathForRow:self.songNamesArray.count - rowPos inSection:0];
                CGRect frame1 = [self.listTableView rectForRowAtIndexPath:tmpIndexPath];
                [self.listTableView setContentOffset:CGPointMake(0, frame1.origin.y) animated:NO];
                
            }
            else
            {
                CGRect frame = [self.listTableView rectForRowAtIndexPath:IndexPath];
                [self.listTableView setContentOffset:CGPointMake(0, frame.origin.y) animated:NO];
            }
        }
        else
        {
            [self.listTableView setContentOffset:CGPointMake(0, 0) animated:NO];
        }
        
        [self.listTableView reloadData];
        
        NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:indexValue + 1 inSection:0];
        TSClientSongListViewCell *oldCell = (TSClientSongListViewCell*)[self.listTableView
                                                                        cellForRowAtIndexPath:oldIndexPath];
        oldCell.bgImageView.image = [UIImage imageNamed:@"greyBar.png"];
        
        TSClientSongListViewCell *cell = (TSClientSongListViewCell*)[self.listTableView cellForRowAtIndexPath:IndexPath];
        cell.bgImageView.image = [UIImage imageNamed:@"redBar.png"];
        
    }
    else
    {
        [self.listTableView setContentOffset:CGPointMake(0, indexValue) animated:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{   
    [self setListTableView:nil];
    titleLabel = nil;
    bgImageView = nil;
    [super viewDidUnload];
}


-(void)customizeSystemVolumePopup:(BOOL)status
{
    MPVolumeView *volumeView = nil;
    
    if(status)
    {
        // Prevent Audio-Change Popus
        volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(-2000., -2000., 0.f, 0.f)];
        NSArray *windows = [UIApplication sharedApplication].windows;
        
        volumeView.alpha = 0.1f;
        volumeView.userInteractionEnabled = NO;
        
        if (windows.count > 0)
        {
            [[windows objectAtIndex:0] addSubview:volumeView];
        }
        
    }
    else
    {
        MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame: CGRectZero];
        [volumeView sizeToFit];
        [self.view addSubview: volumeView];
    }
}

- (void)onBackButtonPressed
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)onDisconnectButtonPressed:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"VolumeChangedNotification"
                                                  object:nil];
    
    MPMusicPlaybackState playbackState = appController.musicPlayer.playbackState;
    
    if (playbackState == MPMusicPlaybackStatePlaying)
    {
        [appController.musicPlayer pause];
    }
    
    commManager = [TSSCommunicationManager sharedInstance];
    [commManager.chatRoom stop];
    
    [TSAppConfig getInstance].songInformationDict = nil;
    [TSAppConfig getInstance].isEnteredBackGround = NO;
    
    [TSCommon showAlert:@"Disconnected from Master."];
    [appController loadSignInScreenOnTermination];
}

- (void)checkForSongsinMusicStore
{
    MPMediaQuery *playlistsQuery = [MPMediaQuery songsQuery];
    NSArray *playListArray = [playlistsQuery collections];
    
    [self.musicSongArray removeAllObjects];
    for(MPMediaItemCollection *collection in playListArray)
    {
        NSString *_songTitle = [[collection representativeItem] valueForProperty:MPMediaItemPropertyTitle];
        if([_songTitle length] <= 0)
            _songTitle = @"";

        [self.musicSongArray addObject:_songTitle];
    }
    [self.listTableView reloadData];
}

- (void) viewDidAppear:(BOOL)animated
{
    NSString *_broadcastedPlaylist = [self.infoDict objectForKey:BROADCASTED_PLAYLISTNAME];
    
    if([_broadcastedPlaylist length] > 0 && [_broadcastedPlaylist isEqualToString:[self.infoDict objectForKey:PLAYLISTNAME]])
    {
        NSIndexPath *indexPath;
        if([self.infoDict valueForKey:@"SongIndex"] && ![[self.infoDict valueForKey:@"SongIndex"] isEqualToString:@""])
        {
            NSInteger objIndxRow =  [[self.infoDict valueForKey:@"SongIndex"] integerValue];
            indexPath = [NSIndexPath indexPathForRow:objIndxRow inSection:0];
            
            if(objIndxRow == self.songNamesArray.count)
                selectedRow = objIndxRow - 1;
            else
                selectedRow = objIndxRow;
            
            NSInteger rowPos = 0;
            if([TSCommon isRetina4])
                rowPos = 9;
            else
                rowPos = 7;
            
            if(self.songNamesArray.count >= rowPos)
            {
                if(objIndxRow + rowPos >= self.songNamesArray.count - 1)
                {
                    NSIndexPath *tmpIndexPath = [NSIndexPath indexPathForRow:self.songNamesArray.count - rowPos inSection:0];
                    CGRect frame1 = [self.listTableView rectForRowAtIndexPath:tmpIndexPath];
                    [self.listTableView setContentOffset:CGPointMake(0, frame1.origin.y) animated:NO];
                }
                else
                {
                    indexPath = [NSIndexPath indexPathForRow:objIndxRow inSection:0];
                    
                    CGRect frame = [self.listTableView rectForRowAtIndexPath:indexPath];
                    [self.listTableView setContentOffset:CGPointMake(0, frame.origin.y) animated:NO];
                }
            }
            else
            {
                [self.listTableView setContentOffset:CGPointMake(0, 0) animated:NO];
            }
            
            
            TSClientSongListViewCell *cell = (TSClientSongListViewCell*)[self.listTableView cellForRowAtIndexPath:indexPath];
            cell.bgImageView.image = [UIImage imageNamed:@"redBar.png"];
        }
        
        else if(self.yPos > 0)
        {
            [self.listTableView setContentOffset:CGPointMake(0, self.yPos) animated:NO];
        }
    }
    else
        [self.listTableView setContentOffset:CGPointMake(0, self.yPos) animated:NO];
    
    
}

- (void)didChangedVolume
{
    float newVolune = appController.selectedVolume;
    [[MPMusicPlayerController iPodMusicPlayer] setVolume:newVolune];
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
    return [self.songNamesArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier    = @"Client SongList Cell";
    TSClientSongListViewCell *tableCell = (TSClientSongListViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    tableCell = nil;
    
    if (tableCell == nil)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"TSClientSongListViewCell"
                                                       owner:[TSClientSongListViewCell class]
                                                     options:nil];
        tableCell           = (TSClientSongListViewCell*)[array objectAtIndex:0];
    }
    
    tableCell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableCell.tag = indexPath.row;
    tableCell.delegate = self;
    
    NSString *_theSongName = [self.songNamesArray objectAtIndex:indexPath.row];
    NSString *_composerName = [self.composerNameArray objectAtIndex:indexPath.row];
    
    NSPredicate *Predicate = [NSPredicate predicateWithFormat:@"SELF == %@",_theSongName];
    NSArray *filtered = [self.musicSongArray filteredArrayUsingPredicate:Predicate];
    
    tableCell.bgImageView.image = [UIImage imageNamed:@"greyBar.png"];
    if(selectedRow >= 0 && selectedRow == [indexPath row])
        tableCell.bgImageView.image = [UIImage imageNamed:@"redBar.png"];
    
    @try {
        _theSongName = [self getSongNameFromTitle:_theSongName andComposer:_composerName];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception");
    }
    
        
    if([filtered count])
    {
        tableCell.downloadButton.hidden = YES;
        tableCell.downloadLabel.hidden = YES;
        tableCell.notAvailableLabel.hidden = YES;
        tableCell.songNameLabel.text = _theSongName;
    }
    else
    {
        tableCell.songNameLabel.text = _theSongName;
        tableCell.notAvailableLabel.hidden = NO;
        tableCell.songNameLabel.textColor = [UIColor grayColor];
        tableCell.downloadButton.hidden = NO;
        tableCell.downloadLabel.hidden = NO;
    }
    return tableCell;
}

- (NSString*)getSongNameFromTitle:(NSString*)title andComposer:(NSString*)composerName
{
    NSString *songName = title;
    NSRange rangeOfSubstring = [songName rangeOfString:composerName];
    
    if(rangeOfSubstring.location == NSNotFound)
    {
        songName = [songName stringByReplacingOccurrencesOfString:@"composerName"
                                                       withString:@""];
    }
    
    
    return songName;
}


#pragma mark -
#pragma mark TSClientSongListViewCellDelegate methods
#pragma mark -

- (void)onDownloadBtnPressed:(NSInteger)btnTag
{
    CGRect _frame = CGRectMake(0, 0, 100, 100);
    [TSCommon showProcessViewWithFrame:_frame andMessage:@"Loading..."];
    
    NSString *_name = [self.songNamesArray objectAtIndex:btnTag];
    NSString *_composerName = [self.composerNameArray objectAtIndex:btnTag];
    
    _name = [self getSongNameFromTitle:_name andComposer:_composerName];
    
    [self downloadSongwithName:_name andArtist:_composerName];
}


#pragma mark -
#pragma mark iTunes song Download methods
#pragma mark -

// start an operation Queue if not started
-(NSOperationQueue*)operationQueue
{
    if(_operationQueue == nil)
    {
        _operationQueue = [NSOperationQueue new];
    }
    return _operationQueue;
}

// based on info from the iTunes affiliates docs
// http://www.apple.com/itunes/affiliates/resources/documentation/itunes-store-web-service-search-api.html
// this assume a search button to start the search.
- (void)downloadSongwithName:(NSString*)songName andArtist:(NSString*)theArtistName
{
    NSLog(@"downloadSongwithName");
    NSString *trimmedSongName= @"";
    if(![songName isEqualToString:@""])
    {
        NSArray *songNameArr = [songName componentsSeparatedByString:@" "];
        if(songNameArr && songNameArr.count > 0)
        {
            
            for(int i = 0;i < songNameArr.count;i++)
            {
                if(i > 1)
                {
                    @try
                    {
                        NSString *tmpSongName = [[TSCommon trimWhiteSpaces:[songNameArr objectAtIndex:i]] substringToIndex:1];
                        if(![self validateSpecialCharacters:tmpSongName])
                        {
                            break;
                        }
                    }
                    @catch (NSException *exception)
                    {
                        break;
                    }
                }

                trimmedSongName = [trimmedSongName stringByAppendingFormat:@" %@", [songNameArr objectAtIndex:i]];
            }
        }
        else
        {
            trimmedSongName = songName;
        }
    }
    
    NSString* songTerm = trimmedSongName;      //the song text
    
    NSArray *songTermArray = [songTerm componentsSeparatedByString:@"-"];
    
    if([songTermArray count] > 1)
    {
        NSCharacterSet *_NumericOnly = [NSCharacterSet decimalDigitCharacterSet];
        for(NSInteger index = 0; index < [songTermArray count]; index++)
        {
            NSString *_text = [songTermArray objectAtIndex:index];
            _text = [TSCommon trimWhiteSpaces:_text];
            
            NSCharacterSet *myStringSet = [NSCharacterSet characterSetWithCharactersInString:_text];
            
            if ([_NumericOnly isSupersetOfSet: myStringSet])
            {
                //String entirely contains decimal numbers only.
                songTerm = [songTerm stringByReplacingOccurrencesOfString:_text
                                                               withString:@""];
            }
        }

    }
    
    // they both need to be non-zero for this to work right.
    //if(artistTerm.length > 0 && songTerm.length > 0) {
      if(songTerm.length > 0) {  
        // this creates the base of the Link Maker url call.
        
        NSString* baseURLString = @"https://itunes.apple.com/search";
        
        NSString* searchUrlString = [NSString stringWithFormat:@"%@?media=music&entity=song&term=%@&songTerm=%@&country=US", baseURLString, songTerm, songTerm];

        // must change spaces to +
        searchUrlString = [searchUrlString stringByReplacingOccurrencesOfString:@" " withString:@"+"];

        //make it a URL
        searchUrlString = [searchUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL* searchUrl = [NSURL URLWithString:searchUrlString];
        NSLog(@"searchUrl: %@", searchUrl);
        
        // start the Link Maker search
        NSURLRequest* request = [NSURLRequest requestWithURL:searchUrl];
        self.searching = YES;
        [NSURLConnection sendAsynchronousRequest:request queue:self.operationQueue completionHandler:^(NSURLResponse* response, NSData* data, NSError* error) {
            
            // we got an answer, now find the data.
            self.searching = NO;
            if(error != nil)
            {
                [TSCommon showAlert:NOT_CONNECTED_TO_INTERNET];
                [TSCommon dismissProcessView];
            }
            else
            {
                NSError* jsonError = nil;
                NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                if(jsonError != nil)
                {
                    // do something with the error here
                    NSLog(@"JSON Error: %@", jsonError);
                }
                else
                {
                    NSArray* resultsArray = dict[@"results"];
                    
                    // it is possible to get no results. Handle that here
                    if(resultsArray.count == 0)
                    {
                        [TSCommon showAlert:@"The specified song is not available in iTunes."];
                        [TSCommon dismissProcessView];
                    }
                    else
                    {
                        // extract the needed info to pass to the iTunes store search
                        NSDictionary* trackDict = resultsArray[0];
                        NSString* trackViewUrlString = trackDict[@"trackViewUrl"];
                        if(trackViewUrlString.length == 0)
                        {
                            NSLog(@"No trackViewUrl");
                        }
                        else
                        {
                            NSURL* trackViewUrl = [NSURL URLWithString:trackViewUrlString];
                            NSLog(@"trackViewURL:%@", trackViewUrl);
                            
                            [TSCommon dismissProcessView];
                            // dispatch the call to switch to the iTunes store with the proper search url
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[UIApplication sharedApplication] openURL:trackViewUrl];
                            });
                        }
                    }
                }
            }
        }];
    }
}

-(BOOL)validateSpecialCharacters:(NSString *)string
{
    NSLog(@"validateSpecialCharacters");
    NSCharacterSet * invalidNumberSet;
	BOOL result = YES;
	invalidNumberSet = [NSCharacterSet characterSetWithCharactersInString:@"_!@#$%^&*()[]{}'\"<>:;|\\/?+=\t~`-"];
    
    NSScanner * scanner = [NSScanner scannerWithString:string];
    NSString  * scannerResult;
    
    [scanner setCharactersToBeSkipped:nil];
    
    if(![scanner isAtEnd])
    {
        if([scanner scanUpToCharactersFromSet:invalidNumberSet intoString:&scannerResult])
			result = YES;
        else
			result = NO;
    }
	return result;
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
    NSLog(@"setLayoutOfRetina4");
    if([TSCommon isRetina4])
    {
        bgImageView.frame = CGRectMake(bgImageView.frame.origin.x,bgImageView.frame.origin.y, bgImageView.frame.size.width, bgImageView.frame.size.height + 88);
        
        self.listTableView.frame = CGRectMake(self.listTableView.frame.origin.x,self.listTableView.frame.origin.y, self.listTableView.frame.size.width, self.listTableView.frame.size.height + 52);
    }
}

@end
