//
//  AppServer.h
//  App_iphone
//
//  Created for SMG Mobile on 1/25/12.
//  
//

#import "WebRequestHandler.h"
#import "WebRequestBuilder.h"

#import "AppServerHelper.h"
#import "SyncWrapper.h"

@interface AppServer : NSObject <WebRequestHandlerNotificationProtocol> {
	NSMutableDictionary *delegates;
    NSMutableArray *requestsArray;
    
    NSMutableData *myResponse;
}

+ (AppServer*) sharedInstance;

- (void)addDelegate:(id<ServerRequestDelegate>)delegate forServerRequest:(ServerRequest)serverRequest;
- (void)removeDelegate:(id)delegate forServerRequest:(ServerRequest)serverRequest;
- (void)removeDelegate:(id)delegate;

- (void)sendRequest:(ServerRequest)serverRequest userInfo:(NSDictionary*)info;
- (void)sendRequest:(ServerRequest)serverRequest userInfo:(NSDictionary*)info url:(NSString*)url;
- (void)sendRequest:(ServerRequest)serverRequest userInfo:(NSDictionary*)info url:(NSString*)url body:(NSData*)body;
- (void)cancelRequestsForIdentifier:(ServerRequest)serverRequest;
- (BOOL)hasActiveRequestForURL:(NSString*)url;


@end
