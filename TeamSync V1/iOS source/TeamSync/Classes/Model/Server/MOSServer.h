//
//  MOSServer.h
//  MOS_iphone
//
//  Created for SMG Mobile on 1/25/12.
//  
//

#import <Foundation/Foundation.h>
//#import "XMLCollector.h"
#import "WebRequestHandler.h"
#import "WebRequestBuilder.h"

#import "CoreDataObjects.h"

#import "MOSServerHelper.h"


@interface MOSServer : NSObject <WebRequestHandlerNotificationProtocol> {
	NSMutableDictionary *delegates;
}

+ (MOSServer*) sharedInstance;

- (void)addDelegate:(id<ServerRequestDelegate>)delegate forServerRequest:(ServerRequest)serverRequest;
- (void)removeDelegate:(id)delegate forServerRequest:(ServerRequest)serverRequest;
- (void)removeDelegate:(id)delegate;

- (void)sendRequest:(ServerRequest)serverRequest userInfo:(NSDictionary*)info;



@end
