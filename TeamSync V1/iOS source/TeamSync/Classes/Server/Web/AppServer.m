//
//  AppServer.m
//  App_iphone
//
//  Created for SMG Mobile on 1/25/12.
//  
//


#import "AppServer.h"
#import "StoreManager.h"
#import "AppServerStoreWrapper.h"


NSString *const kRequestId = @"RequestId";


@implementation AppServer

#pragma mark -
#pragma mark Instance

+ (AppServer*) sharedInstance {
    
	static AppServer *sharedAppServer = nil;
	if (sharedAppServer == nil) {
		sharedAppServer = [[AppServer alloc] init];
	}
	return sharedAppServer;
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
            
            requestsArray = [NSMutableArray new];
		}
	}
	return self;
}

#pragma mark -
#pragma mark delagate

- (void)addDelegate:(id<ServerRequestDelegate>)delegate forServerRequest:(ServerRequest)serverRequest {
	if (delegate != nil) {
		NSMutableArray *requests = [delegates objectForKey:[NSString stringWithFormat:@"%d", serverRequest]];
		[requests removeObject:delegate];
		[requests addObject:delegate];
	}
}

- (void)removeDelegate:(id)delegate forServerRequest:(ServerRequest)serverRequest {
	if (delegate != nil) {
		NSMutableArray *requests = [delegates objectForKey:[NSString stringWithFormat:@"%d", serverRequest]];
        if ([requests count] > 0 && [requests indexOfObject:delegate] != NSNotFound) {
            [requests removeObject:delegate];
        }
		
	}
}

- (void)removeDelegate:(id)delegate {
	for (int i = 0; i < ServerRequestCount; i++) {
		[self removeDelegate:delegate forServerRequest:i];
	}
}

#pragma mark -
#pragma mark request sending

- (void)sendRequest:(ServerRequest)serverRequest userInfo:(NSDictionary*)info {
    NSString *urlString = @"";//[AppServerHelper urlForRequest:serverRequest];
    [self sendRequest:serverRequest userInfo:info url:urlString];
}

- (void)sendRequest:(ServerRequest)serverRequest userInfo:(NSDictionary*)info url:(NSString*)url {
    [self sendRequest:serverRequest userInfo:info url:url body:nil];
}

- (void)sendRequest:(ServerRequest)serverRequest userInfo:(NSDictionary*)info url:(NSString*)url body:(NSData*)body {
        
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[NSNumber numberWithInt:serverRequest] forKey:kRequestId];
    if ([info count]) {
        [userInfo addEntriesFromDictionary:info];
    }
    
    WebRequest *webRequest = [WebRequestBuilder createWebRequestWithURL:[NSURL URLWithString:url]];
    webRequest.userInfo = userInfo;
    
    if (body != nil) {
        [webRequest setRequestBody:body];
        [webRequest setMethod:@"POST"];
        NSDictionary *headersDict = [NSDictionary dictionaryWithObject:@"application/json" forKey:@"accept"];
        [webRequest setHeadersDict:headersDict];
        
//        NSString *str = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
//        NSLog(@"sending body: %@", str);
        
    }

    [requestsArray addObject:webRequest];
	[WebRequestHandler handleRequest:webRequest registerObjectForNotifications:self];
}

- (void)cancelRequestsForIdentifier:(ServerRequest)serverRequest {
    for (int i = [requestsArray count] - 1; i >= 0; i--) {
        WebRequest *request = [requestsArray objectAtIndex:i];
        ServerRequest requestIdentifier = [[[request userInfo] valueForKey:kRequestId] intValue];
        if (serverRequest == requestIdentifier) {
            [requestsArray removeObject:request];
            [WebRequestHandler cancelRequest:request];
        }
    }
}

- (BOOL)hasActiveRequestForURL:(NSString*)url {
    BOOL has = NO;
    
    for (WebRequest *request in requestsArray) {
        NSString *currentUrl = [request.url absoluteString];
        if ([currentUrl isEqualToString:url]) {
            has = YES;
            break;
        }
    }
    return has;
}

#pragma mark -
#pragma mark WebRequestHandlerNotificationProtocol imp 

- (void) webRequestDidFail:(NSNotification*) notif {
	NSError *error = [[notif userInfo] valueForKey:kNotifError];
	NSLog(@"error: %@", error);
	
	WebRequest *request = [notif object];
    [requestsArray removeObject:request];
	ServerRequest serverRequest = [[[request userInfo] valueForKey:kRequestId] intValue];
	
	NSMutableArray *requests = [delegates objectForKey:[NSString stringWithFormat:@"%d", serverRequest]];
	for (id delegate in requests) {
		if ([(NSObject*)delegate respondsToSelector:@selector(serverRequest:didFailWithError:userInfo:)]) {
			[delegate serverRequest:serverRequest didFailWithError:error userInfo:[request userInfo]];
		}
	}
}


- (void) webRequestDidFinish:(NSNotification*) notif {
    
    
    WebRequest *request = [notif object];
    [requestsArray removeObject:request];
    
	NSDictionary *userInfo = [request userInfo];
	ServerRequest serverRequest = [[userInfo valueForKey:kRequestId] intValue];
    
    
	NSData *responseData = [[notif userInfo] valueForKey:kNotifResultObject];
    

    id result = [AppServerStoreWrapper storeData:responseData 
                                     fromRequest:serverRequest
                                        userInfo:userInfo];
    
    
    // delegates
	NSMutableArray *requestDelegates = [delegates objectForKey:[NSString stringWithFormat:@"%d", serverRequest]];
	
    for (int i = [requestDelegates count] - 1; i >= 0; i--) {
        id delegate = [requestDelegates objectAtIndex:i];
		if ([(NSObject*)delegate respondsToSelector:@selector(serverRequestDidFinish:result:userInfo:)]) {
			[delegate serverRequestDidFinish:serverRequest result:result userInfo:userInfo];
		}
	}
}

@end
