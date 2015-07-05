//
//  MOSServerHelper.h
//  MOS_iphone
//
//  Created for SMG Mobile on 1/25/12.
//  
//
#import "CoreDataObjects.h"

typedef enum ServerRequest {
    ServerRequestHomeFeeds,
    ServerRequestNewsFeedsPreloading,
    ServerRequestGalleryFeeds,
    ServerRequestGalleryFeedsImagesUpdating,
	ServerRequestCount
}ServerRequest;

@protocol ServerRequestDelegate
- (void) serverRequest:(ServerRequest)serverRequest didFailWithError:(NSError*)error userInfo:(NSDictionary*)userInfo;
- (void) serverRequestDidFinish:(ServerRequest)serverRequest result:(id)result userInfo:(NSDictionary*)userInfo;
@end


@interface MOSServerHelper : NSObject {

    
    
}

@end
