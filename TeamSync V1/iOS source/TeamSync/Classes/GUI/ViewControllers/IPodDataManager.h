//
//  IPodDataManager.h
//  TeamSync
//
//  Created for SMG Mobile on 03.04.12.
//  
//

#import "Track.h"
#import <MediaPlayer/MediaPlayer.h>

@interface IPodDataManager : NSObject

+ (IPodDataManager *)sharedInstance;

//////////////////


- (void)updateIPodPlaylists;
- (void)updateDetectedTracksWithKeyword:(NSString*)keyword;

- (MPMediaItem*)mediaItemForTrack:(Track*)track;

- (BOOL)userHasMediaItemForTrack:(Track*)track;

@end
