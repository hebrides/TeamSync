//
//  StoreManager.h
//  App_iphoneim
//
//  Created for SMG Mobile on 12/22/11.
//  
//


#import <Foundation/Foundation.h>
#import "CoreDataObjects.h"
#import "Utils.h"
#import <MediaPlayer/MediaPlayer.h>

@interface StoreManager : NSObject {
    
}

+ (StoreManager*) sharedInstance;

- (void)deleteCoreDataObject:(NSManagedObject*)coreDataObject;
- (void)removeAllObjectsForKey:(NSString*)key;
- (NSManagedObject*)updateObject:(NSManagedObject*)object withInfo:(NSDictionary*)info;
- (void)defaultUpdateForObjectsNamed:(NSString*)name items:(NSArray*)items removeOld:(BOOL)removeOld;


#pragma Custom methods
- (User*)createNewUserWith:(NSString*)username;
- (Playlist*)createPlaylistWithTitle:(NSString*)title deacription:(NSString*)desc;

//- (void)updateDetectedItunesTracksWith:(NSArray*)array;
- (void)updateDetectedTracksWith:(NSArray*)array;
- (void)removeDetecredTracks;


- (void)updateMastersListWith:(NSArray*)array;
- (void)updatePlaylist:(NSDictionary*)playlistInfo forMaster:(Master*)master;

- (Track*)createTrackWithIPodTrack:(MPMediaItem*)mediaItem;
- (void)updateIPodsPlaylists;

@end