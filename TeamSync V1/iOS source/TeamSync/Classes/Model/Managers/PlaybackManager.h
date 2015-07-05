//
//  PlaybackManager.h
//  TeamSync
//
//  Created for SMG Mobile on 3/21/12.
//  
//

#import <AVFoundation/AVFoundation.h>
#import "IPodDataManager.h"
#import "Track.h"

#define kMusicPlayerVolumeMuteState             @"kMusicPlayerVolumeMuteState"
#define kMusicPlayerVolumeChanged               @"kMusicPlayerVolumeChanged"
#define kMusicPlayerPlaybackStateChanged        @"kMusicPlayerPlaybackStateChanged"
#define kMusicPlayerPlaybackState               @"kMusicPlayerPlaybackState"
#define kMusicPlayerCurrentPlaybackTime         @"kMusicPlayerCurrentPlaybackTime"

typedef enum PlaybackState {
	PlaybackStateStoppedDefault,
    PlaybackStateLoading,
	PlaybackStatePlaying
}PlaybackState;

@interface PlaybackManager : NSObject  {
//    __strong MPMoviePlayerController *player;
//    __strong NSString *currentTrackUrl;
    
}

@property (nonatomic, readonly) PlaybackState playbackState;
@property (nonatomic, readonly) BOOL canSeekForward;
@property (nonatomic, assign) BOOL isVolumeMuted;

+ (PlaybackManager*) sharedInstance;

- (void)playTrack:(Track*)track;
- (void)stopPlaying;
- (BOOL)isItCurrentPlayingTrack:(Track*)track;

- (void)setVolume:(CGFloat)volume;
- (CGFloat)volume;

- (float)currentPlaybackTime;
- (void)playTrack:(Track*)track withCurrentPlaybackTime:(float)currentPlaybackTime;



@end