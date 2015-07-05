//
//  MOSServer.m
//  MOS_iphone
//
//  Created for SMG Mobile on 1/25/12.
//  
//


#import "MOSServer.h"
#import "StoreManager.h"
#import "Common.h"

NSString *const kRequestId = @"RequestId";


@implementation MOSServer

#pragma mark -
#pragma mark Instance

+ (MOSServer*) sharedInstance {
    
	static MOSServer *sharedMOSServer = nil;
	if (sharedMOSServer == nil) {
		sharedMOSServer = [[MOSServer alloc] init];
	}
	return sharedMOSServer;
}

- (id) init
{
	self = [super init];
	if (self != nil) {

		// init delegates dic
		delegates = [[NSMutableDictionary alloc] init];
		for (int i = 0; i < ServerRequestCount; i++) {
			NSString *strRequestKey = [NSString stringWithFormat:@"%d", i];
			[delegates setObject:[NSMutableArray array] forKey:strRequestKey];
		}
	}
	return self;
}

#pragma mark -
#pragma mark delagate

- (void)addDelegate:(id<ServerRequestDelegate>)delegate forServerRequest:(ServerRequest)serverRequest {
	NSMutableArray *requests = [delegates objectForKey:[NSString stringWithFormat:@"%d", serverRequest]];
	[requests removeObject:delegate];
	[requests addObject:delegate];
}

- (void)removeDelegate:(id)delegate forServerRequest:(ServerRequest)serverRequest {
	NSMutableArray *requests = [delegates objectForKey:[NSString stringWithFormat:@"%d", serverRequest]];
	[requests removeObject:delegate];
}

- (void)removeDelegate:(id)delegate {
	for (int i = 0; i < ServerRequestCount; i++) {
		[self removeDelegate:delegate forServerRequest:i];
	}
}

#pragma mark -
#pragma mark request sending

- (void)sendRequest:(ServerRequest)serverRequest userInfo:(NSDictionary*)info {

    NSString *urlString = [MOSServerHelper urlForRequest:serverRequest];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[NSNumber numberWithInt:serverRequest] forKey:kRequestId];
    if ([info count]) {
        [userInfo addEntriesFromDictionary:info];
    }
    
    WebRequest *webRequest = [WebRequestBuilder createWebRequestWithURL:[NSURL URLWithString:urlString]];
    webRequest.userInfo = userInfo;
	[WebRequestHandler handleRequest:webRequest registerObjectForNotifications:self];
    
}


#pragma mark -
#pragma mark WebRequestHandlerNotificationProtocol imp 

- (void) webRequestDidFail:(NSNotification*) notif {
	NSError *error = [[notif userInfo] valueForKey:kNotifError];
	NSLog(@"error: %@", error);
	
	WebRequest *request = [notif object];
	ServerRequest serverRequest = [[[request userInfo] valueForKey:kRequestId] intValue];
	
	NSMutableArray *requests = [delegates objectForKey:[NSString stringWithFormat:@"%d", serverRequest]];
	for (id delegate in requests) {
		if ([(NSObject*)delegate respondsToSelector:@selector(serverRequest:didFailWithError:userInfo:)]) {
			[delegate serverRequest:serverRequest didFailWithError:error userInfo:[request userInfo]];
		}
	}
}

- (NSMutableDictionary*)parseXMLData:(NSData*)xmlData {
	XMLCollector *parser = [[[XMLCollector alloc] init] autorelease];
	parser.storeElementParameters = YES;
	return [NSMutableDictionary dictionaryWithDictionary:[parser parseAndCollectData:xmlData]];	
}
- (NSArray*)arrayForKeyPath:(NSString*)path from:(NSDictionary*)dic {
    NSArray *array = [dic safeValueForKeyPath:path];
    if (array != nil && [array isKindOfClass:[NSDictionary class]]) {
        return [NSArray arrayWithObject:array];
    }
    return array;
}
- (void) webRequestDidFinish:(NSNotification*) notif {
    
    
    WebRequest *request = [notif object];
	NSDictionary *userInfo = [request userInfo];
	ServerRequest serverRequest = [[userInfo valueForKey:kRequestId] intValue];
    
    
	NSData *responseData = [[notif userInfo] valueForKey:kNotifResultObject];
    NSDictionary *bodyScheme = [self parseXMLData:responseData];
    

    NSDictionary *result = bodyScheme;
    
    if (serverRequest == ServerRequestHomeFeeds) {
        NSString *path = @"dataset.rows.row";
        NSArray *items = [self arrayForKeyPath:path from:result];
        [[StoreManager sharedInstance] updateHomeFeedsWith:items];        
    } else if (serverRequest == ServerRequestNewsFeedsPreloading) {
        NSString *path = @"blogs.blog";
        NSArray *items = [self arrayForKeyPath:path from:result];
        [[StoreManager sharedInstance] addNewsFeedsWith:items];
    } else if (serverRequest == ServerRequestGalleryFeeds) {
        NSString *path = @"galleries.gallery";
        NSArray *items = [self arrayForKeyPath:path from:result];
        [[StoreManager sharedInstance] updateGalleryFeedsWith:items];
    } else if (serverRequest == ServerRequestGalleryFeedsImagesUpdating) {
        NSString *path = @"galleryimages.galleryimage";
        NSArray *items = [self arrayForKeyPath:path from:result];
        GalleryFeedItem *feed = [userInfo objectForKey:kCDOGalleryFeedItem];
        [[StoreManager sharedInstance] updateGalleryImages:items forGalleryFeed:feed];
    } else {
        NSLog(@"bodyScheme: %@", bodyScheme);
    }
    
    // delegates
	NSMutableArray *requestDelegates = [delegates objectForKey:[NSString stringWithFormat:@"%d", serverRequest]];
	
	for (id delegate in requestDelegates) {
		if ([(NSObject*)delegate respondsToSelector:@selector(serverRequestDidFinish:result:userInfo:)]) {
			[delegate serverRequestDidFinish:serverRequest result:result userInfo:userInfo];
		}
	}
}

@end
