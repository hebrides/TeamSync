//
//  AppServerHelper.h
//  App_iphone
//
//  Created for SMG Mobile on 1/25/12.
//  
//
#import "CoreDataObjects.h"
#import "AppServerConstants.h"



@protocol ServerRequestDelegate
- (void) serverRequest:(ServerRequest)serverRequest didFailWithError:(NSError*)error userInfo:(NSDictionary*)userInfo;
- (void) serverRequestDidFinish:(ServerRequest)serverRequest result:(id)result userInfo:(NSDictionary*)userInfo;
@end


@interface AppServerHelper : NSObject {

    
    
}
+ (AppServerHelper*) sharedInstance;

//+ (void)searchRequestFor:(NSString*)keyword withlistener:(id<ServerRequestDelegate>)listener;

+ (void)sendPlaylist:(Playlist*)playlist toStartSessionWithlistener:(id<ServerRequestDelegate>)listener;
+ (void)signUpUsername:(NSString*)username email:(NSString*)email 
              password:(NSString*)password withlistener:(id<ServerRequestDelegate>)listener;
+ (void)loginWithUsername:(NSString*)username password:(NSString*)password role:(BOOL)isMaster withlistener:(id<ServerRequestDelegate>)listener;

+ (void)updateMastersListWithlistener:(id<ServerRequestDelegate>)listener;

+ (void)updateMaster:(Master*)master playlistWithlistener:(id<ServerRequestDelegate>)listener;

/*
+ (NSString*)urlForRequest:(ServerRequest)request;

+ (void)updateHomeFeedsWithlistener:(id<ServerRequestDelegate>)listener;
+ (void)preloadLatestNewsFeedsWithlistener:(id<ServerRequestDelegate>)listener toCount:(int)toCount;
+ (void)updateGalleryFeedsWithlistener:(id<ServerRequestDelegate>)listener;
+ (void)updateImagesForGalleryFeed:(GalleryFeedItem*)galleryFeed withlistener:(id<ServerRequestDelegate>)listener;
+ (void)updateClubEventsWithlistener:(id<ServerRequestDelegate>)listener; // STRONG LINK UNLESS END
+ (void)updateTourFeedsWithlistener:(id<ServerRequestDelegate>)listener;
+ (void)updateRadioScheduleFeedsWithlistener:(id<ServerRequestDelegate>)listener;

+ (void)updateDownloadFeedsWithlistener:(id<ServerRequestDelegate>)listener;
+ (void)sendDownloadRequestWithCVSFile:(NSString*)cvsFile;

// Music Discovery
+ (void)updateMusicDiscoveryRootArtistsWithlistener:(id<ServerRequestDelegate>)listener;
+ (void)updateMusicDiscoveryBeatportTrackInfo:(MDTrack*)track withlistener:(id<ServerRequestDelegate>)listener;
+ (void)updateRelatedTracksForTrack:(MDTrack*)track withlistener:(id<ServerRequestDelegate>)listener;
+ (void)updateRelatedArtistsForTrack:(MDTrack*)track withlistener:(id<ServerRequestDelegate>)listener;
+ (void)updateInfoForArtist:(MDArtist*)artist withlistener:(id<ServerRequestDelegate>)listener;
+ (void)updateRelatedTracksForArtist:(MDArtist*)artist withlistener:(id<ServerRequestDelegate>)listener;

// Radio
+ (void)updateRadioDataWithlistener:(id<ServerRequestDelegate>)listener;
*/
@end
