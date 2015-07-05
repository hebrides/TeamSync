//
//  IPodDataManager.m
//  TeamSync
//
//  Created for SMG Mobile on 03.04.12.
//  
//

#import "IPodDataManager.h"

#import "StoreManager.h"

@implementation IPodDataManager

static IPodDataManager *_dataManager = nil;

+ (IPodDataManager *)sharedInstance {
	@synchronized(self)	{
		if (!_dataManager) {
			_dataManager = [[IPodDataManager alloc] init];
        }
		return _dataManager;
	}
	return nil;
}


- (void)updateIPodPlaylists {
    [[StoreManager sharedInstance] updateIPodsPlaylists];
}

- (void)updateDetectedTracksWithKeyword:(NSString*)keyword {
    
    if ([keyword length] == 0) {
        keyword = @"";
    }
    NSMutableSet *predicates = [NSMutableSet setWithCapacity:1];
    
    for (int i = 0; i < 1; i++) {
        NSString *predictKey = nil;
        switch (i) {
            case 0:
                predictKey = MPMediaItemPropertyTitle;
                break;
//            case 2:
//                predictKey = MPMediaItemPropertyArtist;
//                break;
//            case 1:
//                predictKey = MPMediaItemPropertyPlaybackDuration;
//                break;
//            case 3:
//                predictKey = MPMediaItemPropertyGenre;
//                break;
            default:
                continue;
                break;
        }



        if ([predictKey length] == 0) {
            continue;
        }
        MPMediaPropertyPredicate *mediaPredicate = [MPMediaPropertyPredicate predicateWithValue:keyword
                                                                                    forProperty:predictKey
                                                                                 comparisonType:MPMediaPredicateComparisonContains];
        [predicates addObject:mediaPredicate];

    }
    
    MPMediaQuery *specificQuery = [[MPMediaQuery alloc] initWithFilterPredicates: predicates];
    
    NSArray *items = [specificQuery items];
    
    [[StoreManager sharedInstance] updateDetectedTracksWith:items];
}


- (MPMediaItem*)mediaItemForTrack:(Track*)track {

    NSMutableSet *predicates = [NSMutableSet setWithCapacity:4];
    
    for (int i = 0; i < 1; i++) {
        NSString *predictKey = nil;
        NSObject *predictValue = nil;
        switch (i) {
            case 0:
                predictValue = track.title;
                predictKey = MPMediaItemPropertyTitle;
                break;
            case 1:
                predictValue = track.artistName;
                predictKey = MPMediaItemPropertyArtist;
                break;
            case 2:
                predictValue = track.length;
                predictKey = MPMediaItemPropertyPlaybackDuration;
                break;
            case 3:
                predictValue = track.releaseDate;
                predictKey = MPMediaItemPropertyReleaseDate;
                break;
            default:
                continue;
                break;
        }
        
        if ([predictKey length] == 0 || predictValue == nil) {
            continue;
        }
        
        MPMediaPropertyPredicate *mediaPredicate = [MPMediaPropertyPredicate predicateWithValue:predictValue
                                                                                    forProperty:predictKey
                                                                                 comparisonType:MPMediaPredicateComparisonContains];
        [predicates addObject:mediaPredicate];
        
    }
    
    MPMediaQuery *specificQuery = [[MPMediaQuery alloc] initWithFilterPredicates: predicates];
    NSArray *items = [specificQuery items];
    if ([items count]) {
        return [items objectAtIndex:0];
    }
    return nil;
}

- (BOOL)userHasMediaItemForTrack:(Track*)track {
    
    MPMediaItem *mediaItem = [self mediaItemForTrack:track];
//    NSLog(@"track: %@", track);
//    NSLog(@"mediaItem: %@", mediaItem);
    
    return (mediaItem != nil);
}
@end
