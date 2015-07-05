//
//  Track.m
//  TeamSync
//
//  Created for SMG Mobile on 3/19/12.
//  
//

#import "Track.h"
#import "Playlist.h"
#import "PlaybackManager.h"

@implementation Track

@dynamic length;
@dynamic audioUrl;
@dynamic order;
@dynamic title;
@dynamic artistName;
@dynamic imageUrl;
@dynamic releaseDate;
@dynamic genreName;
@dynamic itunesid;
@dynamic playlist;

- (void)prepareForDeletion {
    //[self prepareForDeletion];
    //NSLog(@"prepareForDeletion:");
    if ([[PlaybackManager sharedInstance] isItCurrentPlayingTrack:self]) {
        [[PlaybackManager sharedInstance] stopPlaying];
    }
}

@end
