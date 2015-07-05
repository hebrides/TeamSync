//
//  PlaybackManager.m
//  TeamSync
//
//  Created for SMG Mobile on 3/21/12.
//  
//

#import "PlaybackManager.h"
#import "Common.h"

@interface PlaybackManager ()
@property (nonatomic, strong) Track *currentTrack;
@property (nonatomic, assign) PlaybackState playbackState;
@property (nonatomic, assign) BOOL canSeekForward;

- (void)playbackStateChanged:(NSNotification*)notification;
@end


@implementation PlaybackManager
@synthesize currentTrack;
@synthesize playbackState;
@synthesize canSeekForward;
@synthesize isVolumeMuted;

#pragma mark -
#pragma mark Instance

+ (PlaybackManager*) sharedInstance {
	static PlaybackManager *sharedPlaybackManager = nil;
	if (sharedPlaybackManager == nil) {
		sharedPlaybackManager = [[PlaybackManager alloc] init];
	}
	return sharedPlaybackManager;
}

- (id)init {
    self = [super init];
    if (self) {
        [[MPMusicPlayerController iPodMusicPlayer] beginGeneratingPlaybackNotifications];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateChanged:) 
                                                     name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) 
                                                     name:MPMusicPlayerControllerVolumeDidChangeNotification object:nil];        
        self.canSeekForward = NO;
    }
    return self;
}

#pragma mark Notifications

- (void)playbackStateChanged:(NSNotification*)notification {
    
    MPMusicPlaybackState state = [MPMusicPlayerController iPodMusicPlayer].playbackState;
        
    if (state == MPMusicPlaybackStatePlaying) {
        self.playbackState = PlaybackStatePlaying;
    } else {
        self.playbackState = PlaybackStateStoppedDefault;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:kMusicPlayerPlaybackStateChanged object:self userInfo:nil];    
}

- (void)volumeChanged:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kMusicPlayerVolumeChanged object:self userInfo:nil];
}


#pragma mark - 
#pragma mark Playing
- (void)updateSeekState {
    self.canSeekForward = YES;
}

- (void)playTrack:(Track*)track {
    [self stopPlaying];
    
    currentTrack = track;
    
    MPMediaItem *mediaItem = [[IPodDataManager sharedInstance] mediaItemForTrack:track];
    
    if (mediaItem != nil) {
        NSArray *items = [NSArray arrayWithObject:mediaItem];
        
        MPMediaItemCollection *mediaItemCollection = [MPMediaItemCollection collectionWithItems:items];
        [[MPMusicPlayerController iPodMusicPlayer] setQueueWithItemCollection:mediaItemCollection];
        [[MPMusicPlayerController iPodMusicPlayer] play];
        [self performSelector:@selector(updateSeekState) withObject:nil afterDelay:0.3];
    }
}

- (void)stopPlaying {
    self.canSeekForward = NO;
    [[MPMusicPlayerController iPodMusicPlayer] stop];
    self.currentTrack = nil;
}

- (BOOL)isItCurrentPlayingTrack:(Track*)track {
    if (self.playbackState == PlaybackStateStoppedDefault || track == nil) {
        return NO;
    }
    return (self.currentTrack == track);
}

- (CGFloat)volume {
    return [MPMusicPlayerController iPodMusicPlayer].volume;
}

- (void)setVolume:(CGFloat)volume {
    [MPMusicPlayerController iPodMusicPlayer].volume = volume;
}


- (float)currentPlaybackTime {
    if ([[MPMusicPlayerController iPodMusicPlayer] playbackState] == MPMoviePlaybackStatePlaying) {
        return [[MPMusicPlayerController iPodMusicPlayer] currentPlaybackTime];
    }
    return 0.0;
}

- (void)playTrack:(Track*)track withCurrentPlaybackTime:(float)currentPlaybackTime {
    [self playTrack:track];
    currentPlaybackTime += 0.6;
    [[MPMusicPlayerController iPodMusicPlayer] setCurrentPlaybackTime:currentPlaybackTime];
}
@end