//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSPlaySongViewController.m
// Description		:	TSPlaySongViewController class Implementation.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import "TSPlayListDetailViewController.h"
#import "TSPlaySongViewController.h"
#import "TSDeviceListViewController.h"
#import "TSCommon.h"
#import "NSDictionary+TSDeepCopyDictionary.h"
#import "TSSigninViewController.h"

@interface TSPlaySongViewController ()
- (void)customizeSeekSlider;
- (void)customizeDurationSlider;
- (void)setupMusicPlayer;
- (void)loadMusicPlayer;
- (void)updateSeekSlider;
- (void)updateNextPrevButtonState:(BOOL)isYes;
- (void)enableNextButton:(BOOL)isYes;
- (void)enablePreviousButton:(BOOL)isYes;
- (void)clearMusicList;
- (void)setLayoutOfRetina4;
- (void)removeNotifications;
- (void)updateDurationSlider;
- (void)resetDurationSlider;
- (void)broadCastPlayStateChanges:(NSString*)playState;
- (void)broadCastVolumeChanges:(float)volume;
- (void)broadCastSong:(NSInteger)selectedType;
- (void)broadCastSongDurationChanges:(NSTimeInterval)interval;
- (void)didChangedSongPlayed:(BOOL)status;
- (void)broadCastDummyInfo;
- (void)initializeSongAndBradcastArray;
- (void)releaseAllMemory;
- (void)fillSongAndComposerArray;
- (NSInteger)getCurrentlyPlayingSongIndex:(NSString *)currTitle;
@end

@implementation TSPlaySongViewController
@synthesize backwardButton;
@synthesize forwardButton;
@synthesize playButton;
@synthesize seekSlider;
@synthesize isCalledNotification;
@synthesize currentItemIndex;
@synthesize infoDict;
@synthesize playListItems;
@synthesize durationSlider;
@synthesize trackDuration;
@synthesize chatRoom;
@synthesize songNameArray;
@synthesize composerNameArray;
@synthesize songDict;
@synthesize isPlaying;
@synthesize playListName;
@synthesize tableYPosition;
@synthesize isFromListView;

static TSPlaySongViewController * instance = nil;

+ (TSPlaySongViewController *) sharedInstance
{
    if( instance == nil )
    {
        instance = [[TSPlaySongViewController alloc] init];
    }
    return instance;
}

- (id)initWithNibName:(NSString *)nibNameOrNil withSongDetails:(NSDictionary*)dict bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.infoDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        self.trackDuration = nil;
        self.isPlaying = NO;
        self.songNameArray = [[NSMutableArray alloc]init];
        self.composerNameArray = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    yAxis = [[self.infoDict objectForKey:@"YPosition"] integerValue];
    appController   = [TSAppController sharedAppController];
    appController.delegate = self;
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
//    AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, audioSessionPropertyListener, nil);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeConnectButton) name:@"changeConnectButton" object:nil];
    
    appController.isCurrentViewLeft = NO;
    self.isCalledNotification = NO;
    
    if(commManager != nil)
    {
        commManager = nil;
    }
    commManager = [TSSCommunicationManager sharedInstance];
    chatRoom.delegate = commManager;
    commManager.delegate = self;
    
    [self setLayoutOfRetina4];
    [self customizeSeekSlider];
    [self customizeDurationSlider];
    
    self.playListItems = [self.infoDict objectForKey:SONG_LIST];
    appController._currentIndex = [[self.infoDict objectForKey:SONG_INDEX]integerValue];
    NSLog(@"INITIALINDEX = %d",appController._currentIndex);
    self.playListName = [self.infoDict objectForKey:PLAYLISTNAME];
    self.tableYPosition = [self.infoDict objectForKey:TABLE_YPOS];
    
    [self clearMusicList];
    [self updateTheMediaColledtionsItems:self.playListItems];
    
    [self setupMusicPlayer];
    [self loadMusicPlayer];
}

- (void) viewDidAppear:(BOOL)animated
{
    commManager = [TSSCommunicationManager sharedInstance];
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self releaseAllMemory];
    
    disconnectButton = nil;
    [super viewDidUnload];
}


- (void)activate
{
    if ( chatRoom != nil )
    {
        chatRoom.delegate = self;
        [chatRoom start];
    }
}

- (void)customizeSeekSlider
{
	[seekSlider setThumbImage:[UIImage imageNamed:@"playerPin.png"] forState:UIControlStateNormal];
	[seekSlider setMaximumTrackImage:[UIImage imageNamed:@"playScrollBg.png"] forState:UIControlStateNormal];
	[seekSlider setMinimumTrackImage:[UIImage imageNamed:@"playScroll.png"] forState:UIControlStateNormal];
}

- (void)customizeDurationSlider
{
	[durationSlider setThumbImage:[UIImage imageNamed:@"playerPin.png"] forState:UIControlStateNormal];
	[durationSlider setMaximumTrackImage:[UIImage imageNamed:@"playTimerBg.png"] forState:UIControlStateNormal];
	[durationSlider setMinimumTrackImage:[UIImage imageNamed:@"playTimer.png"] forState:UIControlStateNormal];
    durationSlider.value = 0.0;
}

- (void)setupMusicPlayer
{
    // Register for music player notifications
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(handleNowPlayingItemChanged:)
                               name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                             object:appController.musicPlayer];
    [notificationCenter addObserver:self
                           selector:@selector(handlePlaybackStateChanged:)
                               name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
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
                                                    name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                                                  object:appController.musicPlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
                                                  object:appController.musicPlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMusicPlayerControllerVolumeDidChangeNotification
                                                  object:appController.musicPlayer];
    
    [appController.musicPlayer endGeneratingPlaybackNotifications];
}


#pragma mark -
#pragma mark Private Methods
#pragma mark -

- (void)loadMusicPlayer
{   
    MPMediaItem *selectedItem = (MPMediaItem *)[self.playListItems.items objectAtIndex:appController._currentIndex];
    [appController.musicPlayer setNowPlayingItem:selectedItem];
    
    [self updateNextPrevButtonState:YES];
    [self.durationSlider setMinimumValue:0.0];
    [self.seekSlider setValue:appController.musicPlayer.volume animated:NO];
    
    [self.durationSlider addTarget: self action: @selector(durationSliderTouchEnd:) forControlEvents: UIControlEventTouchUpInside];
    
    if ([[MPMusicPlayerController iPodMusicPlayer] playbackState] == MPMusicPlaybackStatePlaying)
    {
        [appController.musicPlayer play];
        NSLog(@"Called play");
        self.isPlaying = YES;
        [playButton setImage:TSLoadImageResource(@"pauseBtn") forState:UIControlStateNormal];

    }
    else
    {
        [appController.musicPlayer pause];
        self.isPlaying = NO;
        [playButton setImage:TSLoadImageResource(@"playBtn") forState:UIControlStateNormal];
    }
    
    if(self.isPlaying)
        [self broadCastPlayStateChanges:@"Play"];
    else
        [self broadCastPlayStateChanges:@"Pause"];


    self.durationSlider.value = appController.musicPlayer.currentPlaybackTime;
    self.durationSlider.minimumValue = 0;
    
    appController.musicPlayer.currentPlaybackTime = 0.0;

    NSNumber *durationNumber = [[appController.musicPlayer nowPlayingItem] valueForProperty:MPMediaItemPropertyPlaybackDuration];
    self.durationSlider.maximumValue =  [durationNumber floatValue];
    
    if(self.isCalledNotification == NO)
        [self didChangedSongPlayed:NO];

    [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateDurationSlider) userInfo:nil repeats:YES];
    
    [self fillSongAndComposerArray];

}


#pragma mark -
#pragma mark TSClientSongPlayViewControllerDelegate Methods
#pragma mark -

- (void)changePlayStateMaster
{
    self.isPlaying = NO;
    [playButton setImage:TSLoadImageResource(@"playBtn") forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark bonjour bradcasting Methods
#pragma mark -

- (void)broadCastDummyInfo
{
    NSDictionary *informationDict = [NSDictionary dictionaryWithObjectsAndKeys: @"Test", DUMMY_INFO, nil];
    
    if([TSCommon isNetworkConnected])
    {
         [commManager.chatRoom broadcastChatMessage:@"" andDetails:informationDict fromUser:[TSAppConfig getInstance].name selectedView:kDummyInfo];
    }
    else
    {
        appController.isBroadcasted = NO;
        TSSigninViewController *viewController = [[TSSigninViewController alloc]initWithNibName:@"TSSigninViewController" bundle:nil];
        viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:viewController animated:YES];
        
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

- (void)broadCastPlayStateChanges:(NSString*)playState
{
    if([TSCommon isNetworkConnected])
    {
        double interval = durationSlider.value;//appController.musicPlayer.currentPlaybackTime;
        NSString *intervalString = [NSString stringWithFormat:@"%f", interval];
        NSDictionary *informationDict = [NSDictionary dictionaryWithObjectsAndKeys:playState, PLAY_STATUS, intervalString, PLAY_DURATION, nil];
        
        [commManager.chatRoom broadcastChatMessage:@"" andDetails:informationDict fromUser:[TSAppConfig getInstance].name selectedView:kSongStateChanges];
    }
    else
    {
        appController.isBroadcasted = NO;
        TSSigninViewController *viewController = [[TSSigninViewController alloc]initWithNibName:@"TSSigninViewController" bundle:nil];
        viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:viewController animated:YES];
        
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

- (void)broadCastVolumeChanges:(float)volume
{
    NSString *volumeString = [NSString stringWithFormat:@"%f",volume];

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

- (void)broadCastSongDurationChanges:(NSTimeInterval)interval
{    
    NSString *intervalString = [NSString stringWithFormat:@"%f", interval];
    
    NSDictionary *informationDict = [NSDictionary dictionaryWithObjectsAndKeys:intervalString, PLAY_DURATION, nil];

    if([TSCommon isNetworkConnected])
    {
        [commManager.chatRoom broadcastChatMessage:@"" andDetails:informationDict fromUser:[TSAppConfig getInstance].name selectedView:kSongDurationChanges];
    }
    else
    {
        appController.isBroadcasted = NO;
        TSSigninViewController *viewController = [[TSSigninViewController alloc]initWithNibName:@"TSSigninViewController" bundle:nil];
        viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:viewController animated:YES];
        
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

- (void)broadCastSong:(NSInteger)selectedType
{
    [self fillSongAndComposerArray];
   
    NSInteger songIndex = 0;
    MPMediaItem *currentItem = appController.musicPlayer.nowPlayingItem;
    NSString *curSongtitle = [currentItem valueForProperty: MPMediaItemPropertyTitle];

    if([curSongtitle length] > 0)
    {
        songIndex = [self getCurrentlyPlayingSongIndex:curSongtitle];

        float volumeData = appController.musicPlayer.volume;
        NSString *volumeInfo = [NSString stringWithFormat:@"%f",volumeData];
        
        NSString *prevBtnEnabled = @"";
        NSString *nextBtnEnabled = @"";
        
        NSInteger songCount = [self.songNameArray count];
        
        if(songIndex == 0 && songCount == 1)
        {
            prevBtnEnabled = @"NO";
            nextBtnEnabled = @"NO";
        }
        else if(songIndex == 0 && songCount > 1)
        {
            prevBtnEnabled = @"NO";
            nextBtnEnabled = @"YES";
        }
        else if(songIndex != 0 && songIndex  == (songCount - 1))
        {
            prevBtnEnabled = @"YES";
            nextBtnEnabled = @"NO";
        }
        else if(songIndex != 0 && songIndex < (songCount - 1))
        {
            prevBtnEnabled = @"YES";
            nextBtnEnabled = @"YES";
        }
        
        NSString *playStatus = @"";
        
        if(self.isPlaying)
            playStatus = @"Play";
        else
            playStatus = @"Pause";
        
        NSString *intervalString = [NSString stringWithFormat:@"%f", appController.musicPlayer.currentPlaybackTime];
        
        NSDate *systemTime = [NSDate date];
        NSString *devicetime = [NSString stringWithFormat:@"%@", systemTime];

        NSDictionary *informationDict = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%d",appController._currentIndex], SONG_INDEX, self.playListName, PLAYLISTNAME, self.songNameArray, SONG_NAME, self.composerNameArray, COMPOSER_NAME, volumeInfo, PLAYER_VOLUME, prevBtnEnabled, ENABLE_PREV_BTN, nextBtnEnabled, ENABLE_NEXT_BTN, playStatus, PLAY_STATUS, intervalString, PLAY_DURATION, self.tableYPosition, TABLE_YPOS, @"2", SONGDETAILS_VIEW_UNIQUE_ID,appController._selectedPlayList, BROADCASTED_PLAYLISTNAME, devicetime,MASTER_DEVICE_TIME, nil];

        self.songDict = [informationDict deepMutableCopy];
        
        if(appController.isBroadcasted)
        {
            [TSAppConfig getInstance].songInformationDict = self.songDict;
        }
        
        appController._currentIndex = songIndex;
        NSLog(@"CURRENTINDEX = %d",appController._currentIndex);
        
        if(appController.isCurrentViewLeft == NO)
        {
            if([TSCommon isNetworkConnected])
            {
                [commManager.chatRoom broadcastChatMessage:@"" andDetails:informationDict fromUser:[TSAppConfig getInstance].name selectedView:kSongDetailsView];
            }
            else
            {
                appController.isBroadcasted = NO;
                TSSigninViewController *viewController = [[TSSigninViewController alloc]initWithNibName:@"TSSigninViewController" bundle:nil];
                viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentModalViewController:viewController animated:YES];
                
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
        else
        {            
            NSDictionary *_informationDict = [NSDictionary dictionaryWithObjectsAndKeys: self.playListName, PLAYLISTNAME, self.songNameArray, SONG_NAME, self.composerNameArray, COMPOSER_NAME,[NSString stringWithFormat:@"%d",appController._currentIndex], SONG_INDEX, curSongtitle, PLAYING_ITEM_NAME, intervalString, PLAY_DURATION, volumeInfo, PLAYER_VOLUME, self.tableYPosition, TABLE_YPOS,appController._selectedPlayList, BROADCASTED_PLAYLISTNAME, devicetime,MASTER_DEVICE_TIME, nil];

            if([TSCommon isNetworkConnected])
            {
                [commManager.chatRoom broadcastChatMessage:@"" andDetails:_informationDict fromUser:[TSAppConfig getInstance].name selectedView:kSongDetailsInSongList];
            }
            else
            {
                appController.isBroadcasted = NO;
                TSSigninViewController *viewController = [[TSSigninViewController alloc]initWithNibName:@"TSSigninViewController" bundle:nil];
                viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentModalViewController:viewController animated:YES];
                
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
    }
    else
    {
        if([TSCommon isNetworkConnected])
        {
            [commManager.chatRoom broadcastChatMessage:@"settoBegin" andDetails:nil fromUser:[TSAppConfig getInstance].name selectedView:kSongDetailsResetSlider];
        }
        else
        {
            appController.isBroadcasted = NO;
            TSSigninViewController *viewController = [[TSSigninViewController alloc]initWithNibName:@"TSSigninViewController" bundle:nil];
            viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentModalViewController:viewController animated:YES];
            
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
    
    NSLog(@"BROADCASTSONG = %d",appController._currentIndex);
    appController.isSentInfoOnce = NO;
}

#pragma mark -
#pragma mark control handlers
#pragma mark -

-(void)durationSliderTouchEnd:(id)sender
{
    if(appController.isBroadcasted)
    {
        NSLog(@"Touches End");
        
        if(self.isPlaying)
        {
            self.isPlaying = NO;
            if(appController.isBroadcasted == YES)
                [self broadCastPlayStateChanges:@"Pause"];
            
            [appController.musicPlayer pause];
            [playButton setImage:TSLoadImageResource(@"playBtn") forState:UIControlStateNormal];
            
        }
        
        appController.musicPlayer.currentPlaybackTime = durationSlider.value;
        double interval = durationSlider.value;
        NSLog(@"interval = %f", interval);
        [self broadCastSongDurationChanges:interval];
        [self updateDurationSlider];
    }

}

- (IBAction)onDurationSliderChanged:(id)sender
{
    UISlider *slider = (UISlider *)sender;
	appController.musicPlayer.currentPlaybackTime = slider.value;
    
	[self updateDurationSlider];
}

- (IBAction)onseekSliderClicked:(id)sender
{    
    UISlider *slider = (UISlider *)sender;
    appController.musicPlayer.volume = slider.value;
	[self updateSeekSlider];
}

- (IBAction)onPlayButtonClicked:(id)sender
{
    if(self.isPlaying)
    {
        self.isPlaying = NO;
        if(appController.isBroadcasted == YES)
            [self broadCastPlayStateChanges:@"Pause"];
        
        [appController.musicPlayer pause];
        [playButton setImage:TSLoadImageResource(@"playBtn") forState:UIControlStateNormal];

    }
    else
    {
        self.isPlaying = YES;
        if(appController.isBroadcasted == YES)
            [self broadCastPlayStateChanges:@"Play"];
        
		[appController.musicPlayer play];
        [playButton setImage:TSLoadImageResource(@"pauseBtn") forState:UIControlStateNormal];
    }
    
    NSString *playStatus = @"";
    
    if(self.isPlaying)
        playStatus = @"Play";
    else
        playStatus = @"Pause";
    
    TSAppConfig *objConf = [TSAppConfig getInstance];
    [objConf.songInformationDict setValue:playStatus forKey:PLAY_STATUS];
}

- (IBAction)onBackButtonPressed:(id)sender
{
    [self.songNameArray removeAllObjects];
    [self.composerNameArray removeAllObjects];
    
    [self.infoDict setValue:[NSString stringWithFormat:@"%d",appController._currentIndex] forKey:@"SongIndex"];
    TSPlayListDetailViewController *playListDetailViewController = [[TSPlayListDetailViewController alloc]initWithNibName:@"TSPlayListDetailViewController" andDetails:self.infoDict bundle:nil];
    playListDetailViewController.delegate = self;
    playListDetailViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:playListDetailViewController animated:YES];
    [self releaseAllMemory];
    playListDetailViewController = nil;
}

- (IBAction)onDisconnectButtonPressed:(id)sender
{
    TSDeviceListViewController *viewController = [[TSDeviceListViewController alloc]initWithNibName:@"TSDeviceListViewController" bundle:nil modifyTableInteraction:YES];
    viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:viewController animated:YES];
    viewController = nil;
}

- (IBAction)onNextTrackButtonPressed:(id)sender
{
    self.isCalledNotification = NO;
    TSAppConfig *objConf = [TSAppConfig getInstance];

    if(appController.musicPlayer.indexOfNowPlayingItem + 1 < [self.playListItems count])
    {
        [appController.musicPlayer skipToNextItem];
        [objConf.songInformationDict setValue:[NSString stringWithFormat:@"%d", appController.musicPlayer.indexOfNowPlayingItem] forKey:@"SongIndex"];
      
        MPMediaItem *currentItem = appController.musicPlayer.nowPlayingItem;
        NSString *curSongtitle = [currentItem valueForProperty: MPMediaItemPropertyTitle];
        appController._currentIndex = [self getCurrentlyPlayingSongIndex:curSongtitle];
        
    }
    else if(appController.musicPlayer.indexOfNowPlayingItem + 1 == [self.playListItems count])
        [self enableNextButton:NO];
}

- (IBAction)onPreviousTrackPressed:(id)sender
{
    self.isCalledNotification = NO;
    TSAppConfig *objConf = [TSAppConfig getInstance];
    
    if(appController.musicPlayer.indexOfNowPlayingItem == 0)
        [self enablePreviousButton:NO];
    else
    {
        static NSTimeInterval skipToBeginningOfSongIfElapsedTimeLongerThan = 0.0;
        
        NSTimeInterval playbackTime = appController.musicPlayer.currentPlaybackTime;
        if (playbackTime >= skipToBeginningOfSongIfElapsedTimeLongerThan)
        {
            [appController.musicPlayer skipToPreviousItem];
            [objConf.songInformationDict setValue:[NSString stringWithFormat:@"%d", appController.musicPlayer.indexOfNowPlayingItem] forKey:@"SongIndex"];
        } else
        {
            [appController.musicPlayer skipToBeginning];
        }
        
        MPMediaItem *currentItem = appController.musicPlayer.nowPlayingItem;
        NSString *curSongtitle = [currentItem valueForProperty: MPMediaItemPropertyTitle];
        appController._currentIndex = [self getCurrentlyPlayingSongIndex:curSongtitle];
    }
}

- (void)updateDurationSlider
{
    double currentTime = appController.musicPlayer.currentPlaybackTime;
    minLabel.text = [NSString stringWithFormat: @"%02d:%02d",
                     (int) currentTime/60,
                     (int) currentTime%60];
    
    if (currentTime != currentTime)
        self.durationSlider.value = 0.0;
    else
        self.durationSlider.value = (float) currentTime;
    
    NSInteger _currentSec = (int) currentTime%60;
    if(_currentSec > 2)
    {
        self.isCalledNotification = NO;
        self.isFromListView = NO;
        appController.isSentInfoOnce = NO;
    }

    NSNumber *durationNumber = [[appController.musicPlayer nowPlayingItem] valueForProperty:MPMediaItemPropertyPlaybackDuration];
    double totalDuration =  [durationNumber doubleValue];
    
    NSNumber *val = [NSNumber numberWithFloat:(totalDuration - currentTime)];
    double remainingTime = [val doubleValue];
    
 //   NSLog(@"currentTime = %f",currentTime);
//    NSLog(@"remainingTime = %f",remainingTime);
    
    NSString *_maxDurationValue = [NSString stringWithFormat: @"%02d:%02d",
                                   (int) remainingTime/60,
                                   (int) remainingTime%60];
    
    NSInteger _min = (int) remainingTime/60;
    NSInteger _sec = (int) remainingTime%60;
    
    if((_min <= 0 && _sec <= 0))
    {
        //if(self.isPlaying)
            maxLabel.text = @"00:00";
    }
    else
    {
        maxLabel.text = _maxDurationValue;
    }

}

- (void)resetDurationSlider
{
	minLabel.text = @"00:00";
	maxLabel.text = @"00:00";
    
    long currentPlaybackTime = appController.musicPlayer.currentPlaybackTime;
	[self.durationSlider setValue:currentPlaybackTime animated:YES];
}


- (void)updateSeekSlider
{
    if(appController.isBroadcasted == YES)
        [self broadCastVolumeChanges:appController.musicPlayer.volume];
    
    [self.seekSlider setValue:appController.musicPlayer.volume animated:YES];
}

- (void)updateNextPrevButtonState:(BOOL)isYes
{    
    [self enableNextButton:isYes];
    [self enablePreviousButton:isYes];
}

- (void)enableNextButton:(BOOL)isYes
{
    if(appController.musicPlayer.indexOfNowPlayingItem + 1 == [self.playListItems count])
    {
        isYes = NO;
    }
    
	if(isYes)
	{
		forwardButton.userInteractionEnabled = YES;
		[forwardButton setImage:TSLoadImageResource(@"forwardBtn") forState:UIControlStateNormal];
	}
	else
	{
		forwardButton.userInteractionEnabled = NO;
		[forwardButton setImage:TSLoadImageResource(@"forwardBtnDisabled") forState:UIControlStateNormal];
	}
    
}

- (void)enablePreviousButton:(BOOL)isYes
{
    if(appController.musicPlayer.indexOfNowPlayingItem == 0)
        isYes = NO;
    
	if(isYes)
	{
		backwardButton.userInteractionEnabled = YES;
		[backwardButton setImage:TSLoadImageResource(@"rewindBtn") forState:UIControlStateNormal];
	}
	else
	{
		backwardButton.userInteractionEnabled = NO;
		[backwardButton setImage:TSLoadImageResource(@"rewindBtnDisabled") forState:UIControlStateNormal];
	}
}

- (void)clearMusicList
{
    MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue: @"NoSongsName" forProperty:MPMediaItemPropertyTitle];
    MPMediaQuery *mediaquery = [[MPMediaQuery alloc] init];
    
    [mediaquery addFilterPredicate:predicate];
    
    [appController.musicPlayer setQueueWithQuery:mediaquery];
    
    _userMediaItemCollection = nil;
}

- (void)updateTheMediaColledtionsItems:(MPMediaItemCollection *)mediaItemCollection
{
    if (_userMediaItemCollection == nil)
    {
        _userMediaItemCollection = mediaItemCollection;
        
        [appController.musicPlayer setQueueWithItemCollection: _userMediaItemCollection];
    }
    else
    {
        BOOL wasPlaying = NO;
        
        if (appController.musicPlayer.playbackState == MPMusicPlaybackStatePlaying)
            wasPlaying = YES;
        
        MPMediaItem *nowPlayingItem	= appController.musicPlayer.nowPlayingItem;
        NSTimeInterval currentPlaybackTime	= appController.musicPlayer.currentPlaybackTime;
        
        NSMutableArray *currentSongsList= [[_userMediaItemCollection items] mutableCopy];
        NSArray *nowSelectedSongsList = [mediaItemCollection items];
        
        [currentSongsList addObjectsFromArray:nowSelectedSongsList];
        
        _userMediaItemCollection = [MPMediaItemCollection collectionWithItems:(NSArray *) currentSongsList];
        
        [appController.musicPlayer setQueueWithItemCollection: _userMediaItemCollection];
        
        appController.musicPlayer.nowPlayingItem	= nowPlayingItem;
        appController.musicPlayer.currentPlaybackTime = currentPlaybackTime;

        if (wasPlaying)
        {
            [appController.musicPlayer play];
        }

    }
}

#pragma mark-
#pragma mark - TSSongPlayViewControllerDelegate methods
#pragma mark-

- (void)didChangedToNextSong
{
    MPMediaItem *currentItem = appController.musicPlayer.nowPlayingItem;
    NSString *curSongtitle = [currentItem valueForProperty: MPMediaItemPropertyTitle];

    if([curSongtitle length] > 0)
    {
        if(appController.isCurrentViewLeft)
            appController._currentIndex = appController._currentIndex + 1;
        else
            appController._currentIndex = [self getCurrentlyPlayingSongIndex:curSongtitle];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updatedSongNotification" object:self];
        
        [self broadCastSong:1];

    }
}


#pragma mark-
#pragma mark - Notifications
#pragma mark-

// When the now playing item changes, update song info labels and artwork display.
- (void)handleNowPlayingItemChanged:(id)notification
{
    if(self.isCalledNotification == NO)
    {
        self.isCalledNotification = YES;
        MPMediaItem *currentItem = appController.musicPlayer.nowPlayingItem;
        
        if(currentItem != nil)
        {
            self.titleLabel.text   = [currentItem valueForProperty:MPMediaItemPropertyTitle];
            
            self.durationSlider.value = appController.musicPlayer.currentPlaybackTime;
            self.durationSlider.minimumValue = 0;
            
            NSNumber *durationNumber = [[appController.musicPlayer nowPlayingItem] valueForProperty:MPMediaItemPropertyPlaybackDuration];
            self.durationSlider.maximumValue =  [durationNumber floatValue];
            
            UIImage *albumArtworkImage = NULL;
            MPMediaItemArtwork *itemArtwork = [currentItem valueForProperty:MPMediaItemPropertyArtwork];
            
            if (itemArtwork != nil)
            {
                albumArtworkImage = [itemArtwork imageWithSize:CGSizeMake(254.0, 254.0)];
            }
            
            if (albumArtworkImage)
            {
                CGSize theImgSize = CGSizeMake(254, 254);
                artworkImageview.image = [TSCommon squareImageWithImage:albumArtworkImage scaledToSize:theImgSize];
            }
            else
            {
                artworkImageview.image = [UIImage imageNamed:@"placeholder.png"];
            }
            
            [self updateNextPrevButtonState:YES];
            
            if(!self.isFromListView)
            {
                if(appController.isBroadcasted)
                {
                    if(!appController.isSentInfoOnce)
                    {
                        appController.isSentInfoOnce = YES;
                        appController._currentIndex = [self getCurrentlyPlayingSongIndex:self.titleLabel.text];
                        
                        [self broadCastSong:1];
                    }
                }
            }
        }
        else
        {
            durationSlider.value = 0.0;
            [self enableNextButton:NO];
            
            self.isPlaying = NO;
            if(appController.isBroadcasted == YES)
                [self broadCastPlayStateChanges:@"Pause"];
            
            [appController.musicPlayer pause];
            [playButton setImage:TSLoadImageResource(@"playBtn") forState:UIControlStateNormal];
        
        }
    }

}

// When the playback state changes, set the play/pause button appropriately.
- (void)handlePlaybackStateChanged:(id)notification
{
    
}

// When the volume changes, sync the volume slider
- (void)handleExternalVolumeChanged:(id)notification
{
    if(appController.isBroadcasted == YES)
        [self broadCastVolumeChanges:appController.musicPlayer.volume];
    
    [self.seekSlider setValue:appController.musicPlayer.volume animated:YES];
}

- (void)didChangedSongPlayed:(BOOL)status
{
    if(self.isCalledNotification == NO)
    {
        self.isCalledNotification = YES;
        
        MPMediaItem *currentItem = appController.musicPlayer.nowPlayingItem;
        
        if(currentItem != nil)
        {
            self.titleLabel.text   = [currentItem valueForProperty:MPMediaItemPropertyTitle];
            
            self.durationSlider.value = appController.musicPlayer.currentPlaybackTime;
            self.durationSlider.minimumValue = 0;
            
            NSNumber *durationNumber = [[appController.musicPlayer nowPlayingItem] valueForProperty:MPMediaItemPropertyPlaybackDuration];
            self.durationSlider.maximumValue =  [durationNumber floatValue];
            
            UIImage *albumArtworkImage = NULL;
            MPMediaItemArtwork *itemArtwork = [currentItem valueForProperty:MPMediaItemPropertyArtwork];
            
            if (itemArtwork != nil)
            {
                albumArtworkImage = [itemArtwork imageWithSize:CGSizeMake(254.0, 254.0)];
            }
            
            if (albumArtworkImage)
            {
                CGSize theImgSize = CGSizeMake(254, 254);
                artworkImageview.image = [TSCommon squareImageWithImage:albumArtworkImage scaledToSize:theImgSize];
            }
            else
            {
                artworkImageview.image = [UIImage imageNamed:@"placeholder.png"];
            }
            
            [self updateNextPrevButtonState:YES];
            
            if(!self.isFromListView)
            {
                if(appController.isBroadcasted)
                {
                    if(!appController.isSentInfoOnce)
                    {
                        appController.isSentInfoOnce = YES;
                        appController._currentIndex = [self getCurrentlyPlayingSongIndex:self.titleLabel.text];
                        
                        [self broadCastSong:1];
                    }
                }
            }
        }
        else
        {
            durationSlider.value = 0.0;
            [self enableNextButton:NO];
            
            self.isPlaying = NO;
            if(appController.isBroadcasted == YES)
                [self broadCastPlayStateChanges:@"Pause"];
            
            [appController.musicPlayer pause];
            [playButton setImage:TSLoadImageResource(@"playBtn") forState:UIControlStateNormal];
            
        }
    }
}

-(void)resetTrackButton
{
    [self updateNextPrevButtonState:YES];
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
    }
}
- (void)initializeSongAndBradcastArray
{
    if(self.songNameArray == nil)
        self.songNameArray = [[NSMutableArray alloc]init];
    
    if(self.composerNameArray == nil)
        self.composerNameArray = [[NSMutableArray alloc]init];
}

- (NSInteger)getCurrentlyPlayingSongIndex:(NSString *)currTitle
{
    [self fillSongAndComposerArray];

    NSInteger currIndex = 0;
    NSLog(@"SongName-- > %@",currTitle);
    
    for(NSInteger index = 0; index < [self.songNameArray count]; index++)
    {
        NSString *songName = [self.songNameArray objectAtIndex:index];
        if([currTitle isEqualToString:songName])
            currIndex = index;
    }
    return currIndex;
}

- (void)fillSongAndComposerArray
{
    [self initializeSongAndBradcastArray];
    if(self.songNameArray && self.songNameArray.count == 0)
    {
        for(NSInteger index = 0; index < [self.playListItems count]; index++)
        {
            MPMediaItem *anItem = (MPMediaItem *)[self.playListItems.items objectAtIndex:index];
            NSString *composerName = @"";
            if (anItem)
            {
                [self.songNameArray addObject:[anItem valueForProperty:MPMediaItemPropertyTitle]];
                
                composerName = [anItem valueForProperty:MPMediaItemPropertyComposer];
                
                if([composerName length] != 0)
                    [self.composerNameArray addObject:composerName];
                else
                    [self.composerNameArray addObject:@""];
            }
        }
        
    }
}

- (void)releaseAllMemory
{
    [self removeNotifications];
    
    [self setSeekSlider:nil];
    [self setBackwardButton:nil];
    [self setForwardButton:nil];
    [self setPlayButton:nil];
    [self setTitleLabel:nil];
    bgImageView = nil;
    artworkImageview = nil;
    [self setDurationSlider:nil];
    minLabel = nil;
    maxLabel = nil;
    holderView = nil;
}

@end
