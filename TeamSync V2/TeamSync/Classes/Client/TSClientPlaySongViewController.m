//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSClientPlaySongViewController.m
// Description		:	TSClientPlaySongViewController class Implementation.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import "TSClientPlaySongViewController.h"
#import "TSPlayListDetailViewController.h"
#import "TSDeviceListViewController.h"
#import "TSCommon.h"

@interface TSClientPlaySongViewController ()
- (void)customizeSeekSlider;
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
- (void)customizeSystemVolumePopup:(BOOL)status;
@end

@implementation TSClientPlaySongViewController
@synthesize seekSlider;
@synthesize currentItemIndex;
@synthesize infoDict;
@synthesize playListItems;
@synthesize durationSlider;
@synthesize trackDuration;
@synthesize chatRoom;
@synthesize selectedSongTitle;
@synthesize songNameArray;
@synthesize artistNameArray;

static TSClientPlaySongViewController * instance = nil;

+ (TSClientPlaySongViewController *) sharedInstance
{
    if( instance == nil )
    {
        instance = [[TSClientPlaySongViewController alloc] init];
    }
    return instance;
}

- (id)initWithNibName:(NSString *)nibNameOrNil withSongDetails:(NSDictionary*)dict bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.infoDict = dict;
        self.trackDuration = nil;
        self.songNameArray = [[NSMutableArray alloc]init];
        self.artistNameArray = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appController = [TSAppController sharedAppController];
    appController.delegate = self;
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    [self setLayoutOfRetina4];
    [self customizeSeekSlider];
    [self customizeDurationSlider];
    
    [TSCommon hideAlert];
    
    self.songNameArray = [self.infoDict objectForKey:SONG_NAME];
    self.artistNameArray = [self.infoDict objectForKey:COMPOSER_NAME];
    self.currentItemIndex = [[self.infoDict objectForKey:SONG_INDEX]integerValue];

    [self clearMusicList];
   
    [self setupMusicPlayer];
    [self loadMusicPlayer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self removeNotifications];
    
    [self setSeekSlider:nil];
    [self setTitleLabel:nil];
    bgImageView = nil;
    artworkImageview = nil;
    [self setDurationSlider:nil];
    minLabel = nil;
    maxLabel = nil;
    forwardButton = nil;
    backwardButton = nil;
    playButton = nil;
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
    //durationSlider.value = 0.0;
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
        [volumeView removeFromSuperview];
    }
}

- (void)setupMusicPlayer
{
    [appController.musicPlayer beginGeneratingPlaybackNotifications];
        
    [[MPMediaLibrary defaultMediaLibrary] beginGeneratingLibraryChangeNotifications];
}

- (void)removeNotifications
{    
    [appController.musicPlayer endGeneratingPlaybackNotifications];
}


#pragma mark -
#pragma mark Private Methods
#pragma mark -

- (void)loadMusicPlayer
{
    MPMediaItem *selectedItem = nil;
    NSInteger _currIndex = self.currentItemIndex;
    self.selectedSongTitle = [self.songNameArray objectAtIndex:_currIndex];
    NSString *songTitle = @"";
    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
    NSArray *itemsFromGenericQuery = [everything items];
    for (MPMediaItem *song in itemsFromGenericQuery)
    {
        songTitle = [song valueForProperty: MPMediaItemPropertyTitle];
        
        if([songTitle rangeOfString:self.selectedSongTitle].location == NSNotFound )
        {
            
        }
        else
        {
            selectedItem = song;
            break;
        }
    }
    
    if(selectedItem)
    {
        MPMediaPropertyPredicate *predicate = [MPMediaPropertyPredicate predicateWithValue:self.selectedSongTitle forProperty:MPMediaItemPropertyTitle];
        
        MPMediaQuery *mySongQuery = [[MPMediaQuery alloc] init];
        [mySongQuery addFilterPredicate: predicate];
        [appController.musicPlayer setQueueWithQuery:mySongQuery];
        //[appController.musicPlayer play];
        
        [self.durationSlider setMinimumValue:0.0];
        
        NSString *playStatus = [self.infoDict objectForKey:PLAY_STATUS];
        NSString *intervalString = [self.infoDict objectForKey:PLAY_DURATION];
        double newInterval = [intervalString doubleValue];
        
        NSTimeInterval timeDiff = 0.0;
        NSTimeInterval orgTimeDiff = 0.0;
        NSString *masterNetworkTime = [self.infoDict objectForKey:MASTER_DEVICE_TIME];
        
        NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
        [dateFormatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss +0000"];
        NSDate *Masterdate = [dateFormatter1 dateFromString:masterNetworkTime];
        
        NSDate *systemTime = [NSDate date];
        NSString *clientDeviceTime = [NSString stringWithFormat:@"%@", systemTime];
        NSDate *Clientdate = [dateFormatter1 dateFromString:clientDeviceTime];
        
        if(appController.deviceTimeDiff > 0)
        {
            timeDiff = [Clientdate timeIntervalSinceDate:Masterdate];
            
            NSLog(@"timeDiff = %f", timeDiff);
            orgTimeDiff = timeDiff - appController.deviceTimeDiff;
            
            if(timeDiff < 0)
            {
                timeDiff = fabs(timeDiff);
                NSLog(@"timeDiff = %f", timeDiff);
                
                orgTimeDiff = appController.deviceTimeDiff - timeDiff;
            }
        }
        else if(appController.deviceTimeDiff < 0)
        {
            appController.deviceTimeDiff = fabs(appController.deviceTimeDiff);
            timeDiff = [Clientdate timeIntervalSinceDate:Masterdate];
            
            if(timeDiff < 0)
            {
                timeDiff = fabs(timeDiff);
                NSLog(@"timeDiff = %f", timeDiff);
                
                orgTimeDiff = appController.deviceTimeDiff - timeDiff;
            }
        }
        
        NSLog(@"orgTimeDiff = %f", orgTimeDiff);
            
        if(orgTimeDiff < 0.0)
            orgTimeDiff = 0;
        
        NSString *info = [NSString stringWithFormat: @"%02d:%02d",
                         (int) newInterval/60,
                         (int) newInterval%60];
        NSLog(@"duration = %@", info);
        
        if(orgTimeDiff > -1 && Masterdate != nil)
        {
            if([playStatus isEqualToString:@"Play"])
            {
                if(orgTimeDiff > -1 && Masterdate != nil)
                {
                    double _duration = newInterval + orgTimeDiff + 0.08;
                    appController.musicPlayer.currentPlaybackTime = _duration;
                    [self.durationSlider setValue:_duration animated:NO];
                }
                else
                {
                    double _duration = newInterval + 0.08;
                    appController.musicPlayer.currentPlaybackTime = _duration;
                    [self.durationSlider setValue:_duration animated:NO];
                }
            }
            else
            {
                double _duration = newInterval + 0.08;
                appController.musicPlayer.currentPlaybackTime = _duration;
                [self.durationSlider setValue:_duration animated:NO];
            }
        }
        else
        {
            double _duration = newInterval + 0.08;
            appController.musicPlayer.currentPlaybackTime = _duration;
            [self.durationSlider setValue:_duration animated:NO];
        }

        if([playStatus isEqualToString:@"Play"])
        {
            [appController.musicPlayer play];
            playButton.image = [UIImage imageNamed:@"pauseBtn.png"];
        }
        else if([playStatus isEqualToString:@"Pause"])
        {
            [appController.musicPlayer pause];
            playButton.image = [UIImage imageNamed:@"playBtn.png"];
        }
        
        [self didChangedSongPlayed];
        
        float _volumeInfo = [[self.infoDict objectForKey:PLAYER_VOLUME]floatValue];
        BOOL enablePrevBtn = [[self.infoDict objectForKey:ENABLE_PREV_BTN]boolValue];
        BOOL enableNextBtn = [[self.infoDict objectForKey:ENABLE_NEXT_BTN]boolValue];
        
        [self.seekSlider setValue:_volumeInfo animated:NO];
        [[MPMusicPlayerController iPodMusicPlayer] setVolume:_volumeInfo];
        
        [self enableNextButton:enableNextBtn];
        [self enablePreviousButton:enablePrevBtn];
        
        NSNumber *durationNumber = [[appController.musicPlayer nowPlayingItem] valueForProperty:MPMediaItemPropertyPlaybackDuration];
        self.durationSlider.maximumValue =  [durationNumber floatValue];
        
        [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateDurationSlider) userInfo:nil repeats:YES];
    }
    
}

#pragma mark -
#pragma mark TSClientSongPlayViewControllerDelegate Methods
#pragma mark -

- (void)didChangedSongInMaster
{
    
}

- (void)didChangedPlayStateInMaster
{
    NSString *_playState = appController.selectedPlayState;
    
    if ([_playState isEqualToString:@"Play"])
    {
        [appController.musicPlayer play];
        playButton.image = [UIImage imageNamed:@"pauseBtn.png"];

    }
    else if ([_playState isEqualToString:@"Pause"])
    {
        [appController.musicPlayer pause];
        playButton.image = [UIImage imageNamed:@"playBtn.png"];
    }
    
    double newInterval = [appController.selectedDuration doubleValue];
    NSLog(@"play/pause newInterval = %f",newInterval);
    appController.musicPlayer.currentPlaybackTime = newInterval;
    [self.durationSlider setValue:newInterval animated:NO];
}


- (void)didChangedVolumnInMaster
{
    float newVolune = appController.selectedVolume;
    [self.seekSlider setValue:newVolune animated:YES];
    [[MPMusicPlayerController iPodMusicPlayer] setVolume:newVolune];
}


- (void)didChangedDurationInMaster
{
    double newInterval = [appController.selectedDuration doubleValue];
    NSLog(@"newInterval = %f",newInterval);

    appController.musicPlayer.currentPlaybackTime = newInterval +  0.00;
    
    double currentTime = appController.musicPlayer.currentPlaybackTime;
    NSString *tt = [NSString stringWithFormat: @"%02d:%02d",
                    (int) currentTime/60,
                    (int) currentTime%60];
    
    NSLog(@"time now = %@",tt);
    
    [self.durationSlider setValue:newInterval +  0.00 animated:NO];
}

- (void)didResetDurationInMaster
{
    [self resetDurationSlider];
}

#pragma mark -
#pragma mark control handlers
#pragma mark -

- (IBAction)onDisconnectButtonPressed:(id)sender
{
    MPMusicPlaybackState playbackState = appController.musicPlayer.playbackState;

    if (playbackState == MPMusicPlaybackStatePlaying)
    {
        [appController.musicPlayer pause];
    }
    
    commManager = [TSSCommunicationManager sharedInstance];
    [commManager.chatRoom stop];
    
    [TSAppConfig getInstance].songInformationDict = nil;
    [TSAppConfig getInstance].isEnteredBackGround = NO;
    
    [TSCommon showAlert:@"Disconnected from Master"];
    
    [appController loadSignInScreenOnTermination];

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
    
    NSNumber *durationNumber = [[appController.musicPlayer nowPlayingItem] valueForProperty:MPMediaItemPropertyPlaybackDuration];
    double totalDuration =  [durationNumber doubleValue];
    
    NSNumber *val = [NSNumber numberWithFloat:(totalDuration - currentTime)];
    double remainingTime = [val doubleValue];
    
    if(remainingTime <= 0.00)
    {
        maxLabel.text = @"00:00";
//        [self customizeDurationSlider];
//        [self.durationSlider setValue:0.0 animated:NO];
    }
    else
    {
        maxLabel.text = [NSString stringWithFormat: @"%02d:%02d",
                         (int) remainingTime/60,
                         (int) remainingTime%60];
    }

}

- (void)resetDurationSlider
{
	minLabel.text = @"00:00";
	maxLabel.text = @"00:00";
    
    long currentPlaybackTime = appController.musicPlayer.currentPlaybackTime;
	[self.durationSlider setValue:currentPlaybackTime animated:NO];
    
}


- (void)updateSeekSlider
{
    [self.seekSlider setValue:appController.musicPlayer.volume animated:NO];
}

- (void)updateNextPrevButtonState:(BOOL)isYes
{
    [self enableNextButton:isYes];
    [self enablePreviousButton:isYes];
}

- (void)enableNextButton:(BOOL)isYes
{
	if(isYes)
	{
		forwardButton.userInteractionEnabled = YES;
		[forwardButton setImage:TSLoadImageResource(@"forwardBtn")];
	}
	else
	{
		forwardButton.userInteractionEnabled = NO;
		[forwardButton setImage:TSLoadImageResource(@"forwardBtnDisabled")];
	}
    
}

- (void)enablePreviousButton:(BOOL)isYes
{
	if(isYes)
	{
		backwardButton.userInteractionEnabled = YES;
		[backwardButton setImage:TSLoadImageResource(@"rewindBtn")];
	}
	else
	{
		backwardButton.userInteractionEnabled = NO;
		[backwardButton setImage:TSLoadImageResource(@"rewindBtnDisabled")];
	}
}

- (void)clearMusicList
{
    MPMediaPropertyPredicate *predicate =
    
    [MPMediaPropertyPredicate predicateWithValue: @"NoSongsName" forProperty:MPMediaItemPropertyTitle];
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
#pragma mark - Notifications
#pragma mark-

- (void)didChangedSongPlayed
{
    MPMediaItem *currentItem = appController.musicPlayer.nowPlayingItem;
    
    if(currentItem != nil)
    {
        [self customizeDurationSlider];
        [self resetDurationSlider];
        self.titleLabel.text   = [currentItem valueForProperty:MPMediaItemPropertyTitle];
        
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
            NSLog(@"NO ALBUM ARTWORK");
            artworkImageview.image = [UIImage imageNamed:@"placeholder.png"];
        }
    }

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


@end
