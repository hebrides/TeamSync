
#import <Foundation/Foundation.h>
#import "WebRequest.h"

extern NSString *const kNotifError;				
extern NSString *const kNotifResultObject;		
extern NSString *const kNotifDownloadedLength;	


@protocol WebRequestHandlerNotificationProtocol <NSObject>

@optional
- (void) webRequestDidFail:(NSNotification*) notif;
- (void) webRequestDidFinish:(NSNotification*) notif;
- (void) webRequestDidDynamicParse:(NSNotification*) notif;
- (void) webRequestDidReceiveResponse:(NSNotification*) notif;
- (void) webRequestDidReceiveData:(NSNotification*) notif;
- (void) webRequestDidCancel:(NSNotification*) notif;

@end


@interface WebRequestHandler : NSObject {
	
	NSMutableArray			*pendingRequests;
	NSMutableArray			*workingRequests;
	NSNotificationCenter	*notifCenter;
	
	NSUInteger	lowPrioMaxCount;
	NSUInteger	normalPrioMaxCount;
	NSUInteger	highPrioMaxCount;
	
	NSThread	*workingThread;
}

@property (nonatomic) NSUInteger	lowPrioMaxCount;
@property (nonatomic) NSUInteger	normalPrioMaxCount;
@property (nonatomic) NSUInteger	highPrioMaxCount;

+ (WebRequestHandler*) sharedInstance;

+ (void) handleRequest:(WebRequest*) request registerObjectForNotifications:(id<WebRequestHandlerNotificationProtocol>) receiver;
- (void) handleRequest:(WebRequest*) request registerObjectForNotifications:(id<WebRequestHandlerNotificationProtocol>) receiver;
+ (void) cancelRequest:(WebRequest*) request;
- (void) cancelRequest:(WebRequest*) request;
- (void) registerObjectForNotifications:(id<WebRequestHandlerNotificationProtocol>) receiver forRequest:(WebRequest*) request;
- (void) unregisterObjectForNotifications:(id<WebRequestHandlerNotificationProtocol>) receiver forRequest:(WebRequest*) request;
- (void) unregisterObjectForAllNotifications:(id<WebRequestHandlerNotificationProtocol>) receiver;

@end

