
#import "WebRequestHandler.h"
#import "Common.h"

NSString *const kNotifError				= @"kNotifError";
NSString *const kNotifResultObject		= @"kNotifResultObject";
NSString *const kNotifDownloadedLength	= @"kNotifDownloadedLength";

static id __sharedInstance;

static NSString *const kWebRequestDidFail				= @"kWebRequestDidFail";
static NSString *const kWebRequestDidFinish				= @"kWebRequestDidFinish";
static NSString *const kWebRequestDidDynamicParse       = @"kWebRequestDidDynamicParse";
static NSString *const kWebRequestDidReceiveResponse	= @"kWebRequestDidReceiveResponse";
static NSString *const kWebRequestDidReceiveData		= @"kWebRequestDidReceiveData";
static NSString *const kWebRequestDidCancel             = @"kWebRequestDidCancel";

static NSString *const kRequestInfoObjectKey	= @"kRequestInfoObjectKey";
static NSString *const kRequestInfoReceiversKey	= @"kRequestInfoReceiversKey";


@interface WebRequestHandler (Private)

- (NSMutableDictionary*) requestInfoForRequest:(WebRequest*) request;
- (BOOL) canStartRequestNow:(WebRequest*) request;
- (void) handleNextRequest;
- (void) unregisterAllObjectsForRequest:(WebRequest*) request;
- (NSInvocation*) invocationWithSelector:(SEL) selector;
- (void) workingThreadStarted;

@end



@implementation WebRequestHandler

@synthesize lowPrioMaxCount;
@synthesize normalPrioMaxCount;
@synthesize highPrioMaxCount;

#pragma mark 
#pragma mark Singleton methods >>>

+ (WebRequestHandler*) sharedInstance {
	
	@synchronized(self) {
		if (__sharedInstance == nil) {
			[[self alloc] init]; // assignment not done here
		}
    }
	
    return __sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
	
    @synchronized(self) {
        if (__sharedInstance == nil) {
            __sharedInstance = [super allocWithZone:zone];
            return __sharedInstance;  // assignment and return on first allocation
        }
    }
	
    return nil; //on subsequent allocation attempts return nil
	
}


- (id)copyWithZone:(NSZone *)zone {
    return self;
}


- (id)retain {
    return self;
}


- (unsigned)retainCount {
    return UINT_MAX;  //denotes an object that cannot be released
}

- (oneway void)release {
    //do nothing
}


- (id)autorelease {
    return self;
}

#pragma mark -
#pragma mark Init

- (id) init
{
	self = [super init];
	if (self != nil) {
		lowPrioMaxCount		= 5;
		normalPrioMaxCount	= 20;
		highPrioMaxCount	= 40;
		notifCenter			= [[NSNotificationCenter defaultCenter] retain];
		pendingRequests		= [[NSMutableArray alloc] initWithCapacity:10];
		workingRequests		= [[NSMutableArray alloc] initWithCapacity:10];
		
		[NSThread detachNewThreadSelector:@selector(workingThreadMain:)
								 toTarget:self 
							   withObject:self];
	}
	return self;
}

#pragma mark -
#pragma mark Public

+ (void) handleRequest:(WebRequest*) request registerObjectForNotifications:(id<WebRequestHandlerNotificationProtocol>) receiver {
	[[WebRequestHandler sharedInstance] handleRequest:request registerObjectForNotifications:receiver];
}

- (void) handleRequest:(WebRequest*) request registerObjectForNotifications:(id<WebRequestHandlerNotificationProtocol>) receiver {
	if ( request == nil ) {
		return;
	}

	request.delegate = self;
	
	BOOL canStartNow = [self canStartRequestNow:request];
	NSMutableArray *receivers = [NSMutableArray arrayWithCapacity:10];
	NSMutableArray *storage = (canStartNow) ? workingRequests : pendingRequests;
	NSMutableDictionary *requestInfo = [NSMutableDictionary dictionaryWithCapacity:2];
	
	[requestInfo setValue:request forKey:kRequestInfoObjectKey];
	[requestInfo setValue:receivers forKey:kRequestInfoReceiversKey];
	[storage addObject:requestInfo];
	
	if ( receiver != nil ) {
		[self registerObjectForNotifications:receiver forRequest:request];
	}
	
	if ( canStartNow ) {
		[request performSelector:@selector(send) 
						onThread:workingThread 
					  withObject:nil
				   waitUntilDone:NO];
	}

}

+ (void) cancelRequest:(WebRequest*) request {
    [[self sharedInstance] cancelRequest:request];
}

- (void) cancelRequest:(WebRequest*) request {
    if ( request == nil ) {
        return;
    }
    
    NSDictionary *pendingRequestDict = [pendingRequests objectWithKey:kRequestInfoObjectKey eqealTo:request];
    if ( pendingRequestDict != nil ) {
        [notifCenter postNotificationName:kWebRequestDidCancel
                                   object:request 
                                 userInfo:nil];
        
        [self unregisterAllObjectsForRequest:request];

        [pendingRequests removeObject:pendingRequestDict];
        return;
    }
    
    NSDictionary *workingRequestDict = [workingRequests objectWithKey:kRequestInfoObjectKey eqealTo:request];
    if ( workingRequestDict != nil ) {
        [request performSelector:@selector(cancel)
                        onThread:workingThread 
                      withObject:nil
                   waitUntilDone:YES];
        
        [notifCenter postNotificationName:kWebRequestDidCancel
                                   object:request 
                                 userInfo:nil];
        
        [self unregisterAllObjectsForRequest:request];
        
        [workingRequests removeObject:workingRequestDict];
        
        [self handleNextRequest];
        
        return;
    }
    
}


- (void) registerObjectForNotifications:(id<WebRequestHandlerNotificationProtocol>) receiver forRequest:(WebRequest*) request {

	[[[self requestInfoForRequest:request] valueForKey:kRequestInfoReceiversKey] addObject:receiver];
	
	SEL webRequestDidFail				= @selector(webRequestDidFail:);
	SEL webRequestDidFinish				= @selector(webRequestDidFinish:);
	SEL webRequestDidDynamicParse       = @selector(webRequestDidDynamicParse:);
  	SEL webRequestDidCancel				= @selector(webRequestDidCancel:);
	SEL webRequestDidReceiveResponse	= @selector(webRequestDidReceiveResponse:);
	SEL webRequestDidReceiveData		= @selector(webRequestDidReceiveData:);
	
	if ( [receiver respondsToSelector:webRequestDidFail] ) {
		[notifCenter addObserver:receiver selector:webRequestDidFail name:kWebRequestDidFail object:request];
	}

	if ( [receiver respondsToSelector:webRequestDidFinish] ) {
		[notifCenter addObserver:receiver selector:webRequestDidFinish name:kWebRequestDidFinish object:request];
	}
    
    if ( [receiver respondsToSelector:webRequestDidDynamicParse] ) {
		[notifCenter addObserver:receiver selector:webRequestDidDynamicParse name:kWebRequestDidDynamicParse object:request];
	}   
    
    if ( [receiver respondsToSelector:webRequestDidCancel] ) {
		[notifCenter addObserver:receiver selector:webRequestDidCancel name:kWebRequestDidCancel object:request];
	}

	if ( [receiver respondsToSelector:webRequestDidReceiveResponse] ) {
		[notifCenter addObserver:receiver selector:webRequestDidReceiveResponse name:kWebRequestDidReceiveResponse object:request];
	}

	if ( [receiver respondsToSelector:webRequestDidReceiveData] ) {
		[notifCenter addObserver:receiver selector:webRequestDidReceiveData name:kWebRequestDidReceiveData object:request];
	}
    
	
}

- (void) unregisterObjectForNotifications:(id<WebRequestHandlerNotificationProtocol>) receiver forRequest:(WebRequest*) request {
	
	[notifCenter removeObserver:receiver name:kWebRequestDidFail object:request];
	[notifCenter removeObserver:receiver name:kWebRequestDidFinish object:request];
   	[notifCenter removeObserver:receiver name:kWebRequestDidDynamicParse object:request];
  	[notifCenter removeObserver:receiver name:kWebRequestDidCancel object:request];
	[notifCenter removeObserver:receiver name:kWebRequestDidReceiveData object:request];
	[notifCenter removeObserver:receiver name:kWebRequestDidReceiveResponse object:request];
	
	[[[self requestInfoForRequest:request] valueForKey:kRequestInfoReceiversKey] removeObject:receiver];
}

- (void) unregisterObjectForAllNotifications:(id<WebRequestHandlerNotificationProtocol>) receiver {
    [notifCenter removeObserver:receiver name:kWebRequestDidFail object:nil];
	[notifCenter removeObserver:receiver name:kWebRequestDidFinish object:nil];
	[notifCenter removeObserver:receiver name:kWebRequestDidDynamicParse object:nil];
   	[notifCenter removeObserver:receiver name:kWebRequestDidCancel object:nil];
	[notifCenter removeObserver:receiver name:kWebRequestDidReceiveData object:nil];
	[notifCenter removeObserver:receiver name:kWebRequestDidReceiveResponse object:nil];
}

#pragma mark -
#pragma mark Private

- (NSMutableDictionary*) requestInfoForRequest:(WebRequest*) request{
	for (NSMutableDictionary *requestInfo in workingRequests) {
		if ( [requestInfo valueForKey:kRequestInfoObjectKey] == request ) {
			return requestInfo;
		}
	}
	
	for (NSMutableDictionary *requestInfo in pendingRequests) {
		if ( [requestInfo valueForKey:kRequestInfoObjectKey] == request ) {
			return requestInfo;
		}
	}
	
	return nil;
}

- (BOOL) canStartRequestNow:(WebRequest*) request {
	NSUInteger curMax = 0;
	switch (request.priority) {
		case WebRequestPriorityLow:
			curMax = lowPrioMaxCount;
			break;
		case WebRequestPriorityNormal:
			curMax = normalPrioMaxCount;			
			break;
		case WebRequestPriorityHigh:
			curMax = highPrioMaxCount;
			break;			
	}
	
	return [workingRequests count] < curMax && workingThread != nil;
}
 
- (void) handleNextRequest {
	NSUInteger i, count = [pendingRequests count];
	for (i = 0; i < count; i++) {
		NSMutableDictionary *requestInfo = [pendingRequests objectAtIndex:i];
		WebRequest *request = [requestInfo valueForKey:kRequestInfoObjectKey];
		if ( [self canStartRequestNow:request] ) {
			[workingRequests addObject:requestInfo];
			[pendingRequests removeObject:requestInfo];
			[request performSelector:@selector(send) 
							onThread:workingThread 
						  withObject:nil
					   waitUntilDone:NO];
			return;
		}
	}
}

- (void) unregisterAllObjectsForRequest:(WebRequest*) request {
	
	NSDictionary *requestInfo = [self requestInfoForRequest:request];
	NSMutableArray *receivers = [requestInfo valueForKey:kRequestInfoReceiversKey];

	for (int i = [receivers count] - 1; i >= 0 ; i--) {
		[self unregisterObjectForNotifications:[receivers objectAtIndex:i] forRequest:request];
	}
}

- (NSInvocation*) invocationWithSelector:(SEL) selector {
	NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
	[inv setSelector:selector];
	[inv retainArguments];
	return inv;
}

- (void) workingThreadStarted {
	[self handleNextRequest];
}

#pragma mark -
#pragma mark Working Thread

- (void) workingThreadMain:(id) obj {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	workingThread = [NSThread currentThread];
	
	[self performSelectorOnMainThread:@selector(workingThreadStarted) withObject:nil waitUntilDone:NO];
	
	while ( ![workingThread isCancelled] ) {
		NSAutoreleasePool *loopPool = [[NSAutoreleasePool alloc] init];
		
		[NSThread sleepForTimeInterval:0.1f];
		[[NSRunLoop currentRunLoop] run];
		
		[loopPool release];
	}
	
	NSDate *limitDate = [[NSDate alloc] initWithTimeIntervalSinceNow:0.01];
	[[NSRunLoop currentRunLoop] runUntilDate:limitDate];
	[limitDate release];
	
	workingThread = nil;
	
	[pool release];
	pool = nil;
}

#pragma mark -
#pragma mark WebRequestObjectProtocol imp

- (void) WebRequest:(WebRequest*) streamedFileDownloadRequest didFailedWithStreamError:(NSError*) error {
	
	if ( [[NSThread currentThread] isEqual:workingThread] ) {
		NSInvocation *inv = [self invocationWithSelector:@selector(WebRequest:didFailedWithStreamError:)];
		[inv setArgument:&streamedFileDownloadRequest atIndex:2];
		[inv setArgument:&error atIndex:3];
		[inv performSelectorOnMainThread:@selector(invokeWithTarget:) withObject:self waitUntilDone:YES];
		return;
	}
	
	//DbgInfo(@"Request fail [%@]\n%@", [streamedFileDownloadRequest.request URL], error);
	[notifCenter postNotificationName:kWebRequestDidFail
							   object:streamedFileDownloadRequest 
							 userInfo:[NSDictionary dictionaryWithObject:error forKey:kNotifError]];

	[self unregisterAllObjectsForRequest:streamedFileDownloadRequest];
	[workingRequests removeObject:[self requestInfoForRequest:streamedFileDownloadRequest]];
	
	[self handleNextRequest];
}

//! Called when connection did recieve response
- (void) webRequestObject:(WebRequestObject*) webRequestObject didReceiveResponse:(NSURLResponse*) response {
	
	if ( [[NSThread currentThread] isEqual:workingThread] ) {
		NSInvocation *inv = [self invocationWithSelector:@selector(webRequestObject:didReceiveResponse:)];
		[inv setArgument:&webRequestObject atIndex:2];
		[inv setArgument:&response atIndex:3];
		[inv performSelectorOnMainThread:@selector(invokeWithTarget:) withObject:self waitUntilDone:YES];
		return;
	}	
	
	[notifCenter postNotificationName:kWebRequestDidReceiveResponse
							   object:webRequestObject 
							 userInfo:nil];
}

//! Called when connection did get piece of data
- (void) webRequestObject:(WebRequestObject*) webRequestObject didReceiveDataWithLength:(NSUInteger) length {
	
	if ( [[NSThread currentThread] isEqual:workingThread] ) {
		NSInvocation *inv = [self invocationWithSelector:@selector(webRequestObject:didReceiveDataWithLength:)];
		[inv setArgument:&webRequestObject atIndex:2];
		[inv setArgument:&length atIndex:3];
		[inv performSelectorOnMainThread:@selector(invokeWithTarget:) withObject:self waitUntilDone:YES];
		return;
	}	
	
	[notifCenter postNotificationName:kWebRequestDidReceiveData
							   object:webRequestObject 
							 userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInteger:length] forKey:kNotifDownloadedLength]];
}

//! Called when connection failed
- (void) webRequestObject:(WebRequestObject*) webRequestObject didFailWithConnectionError:(NSError *)error {
	
	if ( [[NSThread currentThread] isEqual:workingThread] ) {
		NSInvocation *inv = [self invocationWithSelector:@selector(webRequestObject:didFailWithConnectionError:)];
		[inv setArgument:&webRequestObject atIndex:2];
		[inv setArgument:&error atIndex:3];
		[inv performSelectorOnMainThread:@selector(invokeWithTarget:) withObject:self waitUntilDone:YES];
		return;
	}
	
	NSLog(@"Request fail [%@]\n%@\nBODY: [%@]", [webRequestObject.request URL], error, [[[NSString alloc] initWithData:webRequestObject.responseBody encoding:NSUTF8StringEncoding] autorelease]);
	[notifCenter postNotificationName:kWebRequestDidFail
							   object:webRequestObject 
							 userInfo:[NSDictionary dictionaryWithObject:error forKey:kNotifError]];
	
	WebRequest *webRequest = (WebRequest*)webRequestObject;
	[self unregisterAllObjectsForRequest:webRequest];	
	[workingRequests removeObject:[self requestInfoForRequest:webRequest]];
	
	[self handleNextRequest];
}

//! Called when web request successfully parsed data
- (void) webRequestObject:(WebRequestObject*) webRequestObject didFinishParsingWithResult:(id) parseResult {
	
	if ( [[NSThread currentThread] isEqual:workingThread] ) {
		NSInvocation *inv = [self invocationWithSelector:@selector(webRequestObject:didFinishParsingWithResult:)];
		[inv setArgument:&webRequestObject atIndex:2];
		[inv setArgument:&parseResult atIndex:3];
		[inv performSelectorOnMainThread:@selector(invokeWithTarget:) withObject:self waitUntilDone:YES];
		return;
	}
	
    WebRequest *webRequest = (WebRequest*)webRequestObject;
    if ( webRequest.responseMode == WebRequestResponseModeDynamicParsing ) {
        [notifCenter postNotificationName:kWebRequestDidDynamicParse
                                   object:webRequestObject 
                                 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:parseResult, kNotifResultObject, nil]];
    } else {
        [notifCenter postNotificationName:kWebRequestDidFinish
                                   object:webRequestObject 
                                 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:parseResult, kNotifResultObject, nil]];
        
        
        
        [self unregisterAllObjectsForRequest:webRequest];	
        [workingRequests removeObject:[self requestInfoForRequest:webRequest]];
        
        [self handleNextRequest];        
    }
    
}

//! Called when web request parse failed
- (void) webRequestObject:(WebRequestObject*) webRequestObject didFailWithParseError:(NSError *)error {
	
	if ( [[NSThread currentThread] isEqual:workingThread] ) {
		NSInvocation *inv = [self invocationWithSelector:@selector(webRequestObject:didFailWithParseError:)];
		[inv setArgument:&webRequestObject atIndex:2];
		[inv setArgument:&error atIndex:3];
		[inv performSelectorOnMainThread:@selector(invokeWithTarget:) withObject:self waitUntilDone:YES];
		return;
	}

	NSLog(@"Request parse fail [%@]\n%@\nBODY: [%@]", [webRequestObject.request URL], error, [[[NSString alloc] initWithData:webRequestObject.responseBody encoding:NSUTF8StringEncoding] autorelease]);
	[notifCenter postNotificationName:kWebRequestDidFail
							   object:webRequestObject 
							 userInfo:[NSDictionary dictionaryWithObject:error forKey:kNotifError]];
	
	WebRequest *webRequest = (WebRequest*)webRequestObject;
	[self unregisterAllObjectsForRequest:webRequest];	
	[workingRequests removeObject:[self requestInfoForRequest:webRequest]];
	
	[self handleNextRequest];
}


@end
