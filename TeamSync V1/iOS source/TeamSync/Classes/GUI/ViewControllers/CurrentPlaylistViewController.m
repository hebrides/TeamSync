//
//  CurrentPlaylistViewController.m
//  TeamSync
//
//  Created for SMG Mobile on 27.03.12.
//  
//

#import "CurrentPlaylistViewController.h"


@interface CurrentPlaylistViewController ()

@property (nonatomic, strong) UIBarButtonItem *prevItem;
@property (nonatomic, strong) UIBarButtonItem *nextItem;
@property (nonatomic, strong) UIBarButtonItem *playItem;

- (void)handleChangeTrackIndex:(NSNotification*)notif;
- (void)handlePlay:(NSNotification*)notif;
- (void)handleStop:(NSNotification*)notif;

@end

@implementation CurrentPlaylistViewController {
    UISlider *_slider;
    UIButton *_volumeButton;
    
    CGFloat _volume;
}

@synthesize currentTrackIndex;
@synthesize playlist;
@synthesize prevItem, nextItem, playItem;

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    BOOL isUserSignedLikeMaster = ([[DataProvider currentActiveUser].isMaster boolValue]);
    
    currentTrackIndex = 0;
    _volume = [[PlaybackManager sharedInstance] volume];

    
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0.0, 320.0, 320.0, 44.0)];
    bottomBorder.backgroundColor = [UIColor blackColor];
    [self.view addSubview:bottomBorder];
    
    _slider = [[UISlider alloc] initWithFrame:CGRectMake(10.0f, 330.0, 250.0f, 10.0f)];
    [_slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    [_slider setBackgroundColor:[UIColor clearColor]];
    _slider.minimumValue = 0.0;
    _slider.maximumValue = 1.0;
    _slider.value = _volume;
    [self.view addSubview:_slider];
    _slider.userInteractionEnabled = isUserSignedLikeMaster;

    
    _volumeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _volumeButton.frame = CGRectMake(270.0f, 324.0f, 45.0f, 37.0f);
    [_volumeButton addTarget:self action:@selector(muteVolume:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_volumeButton];    
    _volumeButton.userInteractionEnabled = isUserSignedLikeMaster;
    
    [self setupInterfaceIndicatorWithVolume:[PlaybackManager sharedInstance].volume 
                                      meted:[PlaybackManager sharedInstance].isVolumeMuted];

    
    if (isUserSignedLikeMaster) {
        UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];    
        
        self.prevItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left.png"] 
                                                         style:UIBarButtonItemStylePlain 
                                                        target:self action:@selector(prevTrack:)];
        self.nextItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"right.png"] 
                                                         style:UIBarButtonItemStylePlain 
                                                        target:self action:@selector(nextTrack:)];
        self.playItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"play.png"] 
                                                         style:UIBarButtonItemStylePlain 
                                                        target:self action:@selector(playPause:)];
        NSArray *items = [NSArray arrayWithObjects:
                          fixedSpace,
                          self.prevItem, 
                          flexibleSpace, self.playItem, flexibleSpace, 
                          self.nextItem, 
                          fixedSpace, 
                          nil];
        
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 276.0, 320.0, 44.0)];
        [self.view addSubview:toolbar];
        [toolbar setItems:items];
        toolbar.barStyle = UIBarStyleBlack;
    }
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serviceStarted) 
                                                 name:SyncNotificationServiceStarted object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleChangeTrackIndex:) 
                                                 name:SyncNotificationTrackIndexChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePlay:) 
                                                 name:SyncNotificationPlayTrack object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleStop:) 
                                                 name:SyncNotificationStopPlaying object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncPlaybackStateWithNewUser) 
                                                 name:SyncNotificationUserlistChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncVolumeWithMembers) 
                                                 name:SyncNotificationUserlistChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePlaybackSyncing:) 
                                                 name:SyncNotificationPlaybackSyncing object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleVolumeSyncing:) 
                                                 name:SyncNotificationVolumeSyncing object:nil];   

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleVolumeLevelChanged:) 
                                                 name:kMusicPlayerVolumeChanged object:nil];   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateChanged:) 
                                                 name:kMusicPlayerPlaybackStateChanged object:nil];       
    if (isUserSignedLikeMaster) {
        self.tableView.frame = CGRectMake(0.0, 0.0, 320.0, 374.0);
    } else {
        self.tableView.frame = CGRectMake(0.0, 0.0, 320.0, 417.0);
    }    

    [self updateNavigationButtons];
}

- (void)updateData {
    [self.itemsArray removeAllObjects];
    
    if (self.playlist != nil) {
        [self.itemsArray addObjectsFromArray:[DataProvider arraySortedByKey:kCDOPropertyOrder 
                                                                       from:self.playlist.tracks]];        
    }
    
    [self.tableView reloadData];
    [self updateNavigationButtons];
}
#pragma mark - UITableViewDataSource



- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"PlaylistIdentifier";
    TrackCell *cell = (TrackCell*)[table dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[TrackCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.delegate = self;
    }
    
    Track *track = [self.itemsArray objectAtIndex:indexPath.row];
    cell.trackTitle.text = track.title;
    
    NSString *desc = [NSString stringWithFormat:@"%@ (%@ - %.2f min)", 
                      track.artistName, track.genreName, [track.length floatValue]];
    
    cell.trackSubtitle.text = desc;
    
    if ([[IPodDataManager sharedInstance] userHasMediaItemForTrack:track]) {
        cell.accessoryView = nil;
    } else {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"Buy.png"] forState:UIControlStateNormal];
        button.frame = CGRectMake(0.0, 0.0, 40.0, 32.0);
        [button addTarget:self action:@selector(buyTrackAction:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = indexPath.row;
        cell.accessoryView = button;
    }
    
    if ([[PlaybackManager sharedInstance] isItCurrentPlayingTrack:track]) {
        if ([PlaybackManager sharedInstance].playbackState == PlaybackStateLoading) {
            cell.trackState = TRACK_STATE_LOADING;
        } else {
            cell.trackState = TRACK_STATE_PLAYING;
        }
    } else {
        cell.trackState = TRACK_STATE_POUSED;
    }
    
    cell.playButton.userInteractionEnabled = [[DataProvider currentActiveUser].isMaster boolValue];    
    
    return cell;
}

- (void)trackCellPlayButtonPressedAtIndexPath:(NSIndexPath*)indexPath {
    Track *track = [self.itemsArray objectAtIndex:indexPath.row];
    if ([[PlaybackManager sharedInstance] isItCurrentPlayingTrack:track]) {
        [[SyncWrapper sharedInstance] sendStopMessage];
    } else {
        [[SyncWrapper sharedInstance] sendTrackIndex:indexPath.row];
        [[SyncWrapper sharedInstance] sendPlayMessage];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == currentTrackIndex) {
        cell.backgroundColor = [UIColor colorWithRed:130.0/255.0 green:130.0/255.0 blue:130.0/255.0 alpha:1.0];
        cell.textLabel.textColor = [UIColor redColor];
        cell.detailTextLabel.textColor = [UIColor redColor];
    } else {
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor colorWithRed:156.0/255.0 green:156.0/255.0 blue:156.0/255.0 alpha:1.0];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:156.0/255.0 green:156.0/255.0 blue:156.0/255.0 alpha:1.0];
    }
}


- (void)updateNavigationButtons {
    if (currentTrackIndex == NSNotFound) {
        currentTrackIndex = 0;
    }

    if (currentTrackIndex == 0) {
        self.prevItem.enabled = NO;
    } else if ([self.itemsArray count] > 0) {
        self.prevItem.enabled = YES;
    }
    
    if (currentTrackIndex >= [self.itemsArray count] - 1) {
        self.nextItem.enabled = NO;
    } else if ([self.itemsArray count] > 0) {
        self.nextItem.enabled = YES;
    }
}

- (void)serviceStarted {
    if ([[DataProvider currentActiveUser].isMaster boolValue]) {
        [[SyncWrapper sharedInstance] sendTrackIndex:currentTrackIndex];
    }
}

#pragma mark - TrackCellDelegate
- (void)playPause:(UIBarButtonItem *)barItem {
    if (currentTrackIndex == NSNotFound) {
        return;
    } else if (currentTrackIndex < [self.itemsArray count]) {
        Track *track = [self.itemsArray objectAtIndex:currentTrackIndex];
        if ([[PlaybackManager sharedInstance] isItCurrentPlayingTrack:track]) {
            //[[PlaybackManager sharedInstance] stopPlaying];
            [[SyncWrapper sharedInstance] sendStopMessage];
        } else {
            //[[PlaybackManager sharedInstance] playTrack:track];
            [[SyncWrapper sharedInstance] sendPlayMessage];
        }
    }
}


- (void)setDirectCommand {
    
    BOOL needPlayAgain = ([PlaybackManager sharedInstance].playbackState == PlaybackStatePlaying);
    
    [[SyncWrapper sharedInstance] sendStopMessage];

    if (currentTrackIndex >= [self.itemsArray count]) {
        currentTrackIndex = 0;
    }
    if (currentTrackIndex < 0) {
        currentTrackIndex = [self.itemsArray count] - 1;
    }

    [[SyncWrapper sharedInstance] sendTrackIndex:currentTrackIndex];
    [self updateNavigationButtons];
        
    if (needPlayAgain) {
        [[SyncWrapper sharedInstance] sendPlayMessage];
    }
}

- (void)nextTrack:(UIBarButtonItem *)barItem {
    currentTrackIndex++;
    [self setDirectCommand];
}

- (void)prevTrack:(UIBarButtonItem *)barItem {
    currentTrackIndex--;
    [self setDirectCommand];
}

#pragma mark Notifs
- (void)syncPlaybackStateWithNewUser {
    if ([[DataProvider currentActiveUser].isMaster boolValue]) {
        NSMutableDictionary *syncInfo = [NSMutableDictionary dictionaryWithCapacity:3];
        [syncInfo setObject:[NSNumber numberWithInt:currentTrackIndex] 
                     forKey:kCDOTrack];
        [syncInfo setObject:[NSNumber numberWithInt:[PlaybackManager sharedInstance].playbackState] 
                     forKey:kMusicPlayerPlaybackState];
        [syncInfo setObject:[NSNumber numberWithFloat:[[PlaybackManager sharedInstance] currentPlaybackTime]] 
                     forKey:kMusicPlayerCurrentPlaybackTime];
        [[SyncWrapper sharedInstance] sendPlaybackSyncInfo:syncInfo];    
    }
} 

- (void)handlePlaybackSyncing:(NSNotification*)notif {
    if ([[DataProvider currentActiveUser].isMaster boolValue] == NO) {
        
        NSDictionary *syncInfo = [notif object];
        
        currentTrackIndex = [[syncInfo objectForKey:kCDOTrack] intValue];
        if ([[syncInfo objectForKey:kMusicPlayerPlaybackState] intValue] == PlaybackStatePlaying &&
            [PlaybackManager sharedInstance].playbackState == PlaybackStateStoppedDefault) {
            float currentPlaybackTime = [[syncInfo objectForKey:kMusicPlayerCurrentPlaybackTime] floatValue];
            [[PlaybackManager sharedInstance] playTrack:[self.itemsArray objectAtIndex:currentTrackIndex] 
                                withCurrentPlaybackTime:currentPlaybackTime];
        }
        [self.tableView reloadData];
    }
}

- (void)handleChangeTrackIndex:(NSNotification*)notif {
    NSString *num = [notif object];
    currentTrackIndex = [num intValue];
    [self.tableView reloadData];
    [self updateNavigationButtons];
}

- (void)handlePlay:(NSNotification*)notif {
    if (currentTrackIndex < [self.itemsArray count]) {
        Track *track = [self.itemsArray objectAtIndex:currentTrackIndex];
        [[PlaybackManager sharedInstance] playTrack:track];
        [self.playItem setImage:[UIImage imageNamed:@"pause.png"]];
    }
    [self.tableView reloadData];
}

- (void)handleStop:(NSNotification*)notif {
    [[PlaybackManager sharedInstance] stopPlaying];
    [self.playItem setImage:[UIImage imageNamed:@"play.png"]];
    [self.tableView reloadData];
}

#pragma mark Volume

- (void)sendSyncVolumeInfo {
}

- (void)setupInterfaceIndicatorWithVolume:(float)volumeLevel meted:(BOOL)muted{
    _slider.value = volumeLevel;
    [PlaybackManager sharedInstance].isVolumeMuted = muted;
    if (muted) {
        [_volumeButton setImage:[UIImage imageNamed:@"VolumeMuted.png"] forState:UIControlStateNormal];
    } else {
        NSString *imageName = (volumeLevel == 0.0f) ? @"VolumeOff.png" : @"VolumeOn.png";
        [_volumeButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];        
    }
}

- (void)sliderAction:(UISlider *)slider {
    [PlaybackManager sharedInstance].isVolumeMuted = NO;    
    [PlaybackManager sharedInstance].volume = _slider.value;
}

- (void)muteVolume:(UIButton *)button {
    BOOL muted = ! [PlaybackManager sharedInstance].isVolumeMuted;
    
    if (muted) {
        _volume = [PlaybackManager sharedInstance].volume;
        [self setupInterfaceIndicatorWithVolume:0 meted:muted];        
        [PlaybackManager sharedInstance].volume = 0.0f;

    } else {
        [self setupInterfaceIndicatorWithVolume:0 meted:muted];
        [PlaybackManager sharedInstance].volume = _volume;
    }
}

- (void)handleVolumeSyncing:(NSNotification *)notification {
    if ([[DataProvider currentActiveUser].isMaster boolValue] == NO) {
        NSDictionary *syncInfo = [notification object];
        [PlaybackManager sharedInstance].isVolumeMuted = [[syncInfo objectForKey:kMusicPlayerVolumeMuteState] boolValue];
        [PlaybackManager sharedInstance].volume = [[syncInfo objectForKey:kMusicPlayerVolumeChanged] floatValue];
    }
}

- (void)syncVolumeWithMembers {
    if ([[DataProvider currentActiveUser].isMaster boolValue] == YES) {
        NSMutableDictionary *syncInfo = [NSMutableDictionary dictionaryWithCapacity:2];
        
        [syncInfo setObject:[NSNumber numberWithBool:[PlaybackManager sharedInstance].isVolumeMuted] 
                     forKey:kMusicPlayerVolumeMuteState];
        [syncInfo setObject:[NSNumber numberWithFloat:[PlaybackManager sharedInstance].volume] 
                     forKey:kMusicPlayerVolumeChanged];
        [[SyncWrapper sharedInstance] sendVolumeSincInfo:syncInfo];    
    }    
}

- (void)handleVolumeLevelChanged:(NSNotification *)notification {
    [self syncVolumeWithMembers];
    [self setupInterfaceIndicatorWithVolume:[PlaybackManager sharedInstance].volume 
                                      meted:[PlaybackManager sharedInstance].isVolumeMuted];
}


#pragma mairk - Actions

- (void)buyTrackAction:(UIButton*)sender {
    NSInteger index = sender.tag;
    if (index != NSNotFound && index < [self.itemsArray count]) {
        Track *track = [self.itemsArray objectAtIndex:currentTrackIndex];
        
        NSString *url = @"http://ax.search.itunes.apple.com/WebObjects/MZSearch.woa/wa/search?media=music&src=dym&submit=edit&term=";
        url = [url stringByAppendingString:track.title];
        url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

- (void)playbackStateChanged:(NSNotification *)notification {
    
    if ([[DataProvider currentActiveUser].isMaster boolValue]) {
        MPMusicPlaybackState state = [MPMusicPlayerController iPodMusicPlayer].playbackState;

        if (state == MPMusicPlaybackStateStopped && [PlaybackManager sharedInstance].canSeekForward) {
                        
            if (currentTrackIndex < ([self.itemsArray count] - 1)) {
                currentTrackIndex++;
                [[SyncWrapper sharedInstance] sendTrackIndex:currentTrackIndex];            
                [[SyncWrapper sharedInstance] sendPlayMessage];
            }
        }   
    }
    [self.tableView reloadData];
}

@end
