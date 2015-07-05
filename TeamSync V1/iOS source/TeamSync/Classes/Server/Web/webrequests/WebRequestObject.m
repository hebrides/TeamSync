
#import "WebRequestObject.h"
#import "Reachability.h"

static NSInteger __webRequestObjectsCount = 0;

//! WebRequestObject private category used to work with app network activity indicator
@interface WebRequestObject(Private)

//! Method increment internal counter of all web requests and show network activity indicator
+ (void) startLoad:(WebRequestObject*) object;

//! Method decrement internal counter of all web requests and hide network activity indicator if counter == 0
+ (void) stopLoad:(WebRequestObject*) object;

- (void) restartConnection;

@end

@implementation WebRequestObject


@synthesize request;
@synthesize response;
@synthesize userInfo;
@synthesize responseBody;
@synthesize delegate;
@synthesize releaseAfterFinish;
@dynamic	expectedContentLength;
@dynamic	statusCode;
@synthesize loadedLength;
@dynamic 	unzippedNatively;
@synthesize	reachability;
@synthesize	shouldSendDidReceiveWithTimeOut;
@synthesize	didReceiveTimeout;
@synthesize authLogin;
@synthesize authPassword;

+ (void) startLoad:(WebRequestObject*) object; {
	__webRequestObjectsCount++;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

+ (void) stopLoad:(WebRequestObject*) object; {
	__webRequestObjectsCount--;
	if ( __webRequestObjectsCount == 0 ) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;	
	}
}

- (id) initWithInfo:(NSMutableDictionary*) info
{
	self = [super init];
	if (self != nil) {
        if ( info == nil ) {
            self.userInfo = [NSMutableDictionary dictionaryWithCapacity:10];
        } else {
            self.userInfo = info;            
        }

		request = [[NSMutableURLRequest alloc] init];

		releaseAfterFinish = NO;
		didReceiveTimeout = 1.0;
				
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(willResignActive)
													 name:UIApplicationWillResignActiveNotification 
												   object:nil];

		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(didBecomeActive)
													 name:UIApplicationDidBecomeActiveNotification
												   object:nil];

		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(reachabilityChanged:)
													 name:kReachabilityChangedNotification
												   object:nil];
		
	}

	return self;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[userInfo release];
	[request release];
	[response release];
	[responseBody release];
	[connection cancel];
	[connection release];
	self.reachability = nil;
	[reachabilityTimer invalidate];
	[reachabilityTimer release];
	[lastDidReceiveSent release];
    self.authLogin = nil;
    self.authPassword = nil;
	[super dealloc];
}

- (BOOL) send {

	[(id<WebRequestObjectProtocol>)self initialize];
	
	if ( ![NSURLConnection canHandleRequest:request] ) {
		//DbgInfo(@"Can't create connection for request: %@", request );
		return NO;
	}
	
	[responseBody release];
	responseBody = [[NSMutableData alloc] init];
	[connection release];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	
	if ( connection != nil ) {
		[WebRequestObject startLoad:self];
	}

	return connection != nil;
}

- (void) cancel {
	if ( connection != nil ) {
		[WebRequestObject stopLoad:self];
	}
	[connection cancel];
	[connection release];
	connection = nil;
	
	if ( releaseAfterFinish && !isAutorealesed ) {
		isAutorealesed = YES;
		[self release];
	}
}

- (void) reset {
	if ( connection != nil ) {
		[WebRequestObject stopLoad:self];
	}
	[connection cancel];
	[connection release];
	connection = nil;
	
	[response release];
	response = nil;
	
	[responseBody setLength:0];
	
	loadedLength = 0;
	
	shouldRestart = NO;
    lastRecievedLength = 0;
	
}

- (void) returnParseResult:(id) parseResult {
	if ( delegate != nil && [delegate respondsToSelector:@selector(webRequestObject:didFinishParsingWithResult:)] ) {
		[delegate webRequestObject:self didFinishParsingWithResult:parseResult];
	}
}

- (void) returnParseError:(NSError*) parseError {
	if ( delegate != nil && [delegate respondsToSelector:@selector(webRequestObject:didFailWithParseError:)] ) {
		[delegate webRequestObject:self didFailWithParseError:parseError];
	}
}

#pragma mark -
#pragma mark App states handling

- (void) willResignActive {
	if ( connection != nil && reachability != nil) {
		shouldRestart = YES;
		[WebRequestObject stopLoad:self];
		[connection cancel];
		[connection release];
		connection = nil;
	}

}

- (void) didBecomeActive {
	if ( shouldRestart && reachability != nil ) {
		BOOL internetReachable = [reachability currentReachabilityStatus] != NotReachable;
		if ( internetReachable ) {
			[self restartConnection];
		} else {
			[reachabilityTimer invalidate];
			[reachabilityTimer release];
			reachabilityTimer = [[NSTimer alloc] initWithFireDate:[NSDate date]
														 interval:[request timeoutInterval]
														   target:self
														 selector:@selector(restartConnection)
														 userInfo:nil
														  repeats:NO];
		}
	}
}

#pragma mark -
#pragma mark Private

- (void) restartConnection {
	[reachabilityTimer invalidate];
	[reachabilityTimer release];
	reachabilityTimer = nil;
	[self reset];
	[self send];
}

- (void) reachabilityChanged:(NSNotification*) notif {
	if ( reachability == [notif object] && shouldRestart && [reachability currentReachabilityStatus] != NotReachable ) {
		[self restartConnection];
	}
}

#pragma mark -
#pragma mark Dynamic properties 

- (long long) expectedContentLength {
	//return [response expectedContentLength];
	return [[[(NSHTTPURLResponse*)response allHeaderFields] valueForKey: @"Content-Length"] longLongValue];
}

- (NSInteger) statusCode {
	if ( [response isKindOfClass:[NSHTTPURLResponse class]]){
		return [(NSHTTPURLResponse*)response statusCode];
	}
	return 0;
}

- (BOOL) unzippedNatively {
	return [[[(NSHTTPURLResponse*)response allHeaderFields] valueForKey:@"Content-Encoding"] isEqualToString:@"gzip"];
}

#pragma mark Need overide:

- (void) initialize {
	
}

- (void) parse {
	[self returnParseResult:responseBody];
}

#pragma mark Delegate methods:

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)inResponse {
	[response release];
	response = [inResponse retain];
	
    //DbgInfo(@"Recive response: %@\nCode:[%d]\nHeaders [%@]", [response URL], [response statusCode], [response allHeaderFields] );
	
	if ( delegate != nil && [delegate respondsToSelector:@selector(webRequestObject:didReceiveResponse:)] ) {
		[delegate webRequestObject:self didReceiveResponse:response];
	}
}


- (void)connection:(NSURLConnection *)inConnection didReceiveData:(NSData *)data {

	loadedLength += [data length];
    lastRecievedLength += [data length];
    
	[responseBody appendData:data];
	
	if ( !(shouldSendDidReceiveWithTimeOut && [[NSDate date] timeIntervalSinceDate:lastDidReceiveSent] < didReceiveTimeout) ) {
		[lastDidReceiveSent release];
		lastDidReceiveSent = [[NSDate date] retain];
		if ( delegate != nil && [delegate respondsToSelector:@selector(webRequestObject:didReceiveDataWithLength:)] ) {
			[delegate webRequestObject:self didReceiveDataWithLength:lastRecievedLength];
            
		}
        lastRecievedLength = 0;
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)inConnection {
	[connection release];
	connection = nil;
	
	[WebRequestObject stopLoad:self];
	if ( delegate != nil && [delegate respondsToSelector:@selector(webRequestObjectDidFinishLoading:)] ) {
		[delegate webRequestObjectDidFinishLoading:self];
	}
	
	[self parse];
	
	if ( releaseAfterFinish && !isAutorealesed ) {
		isAutorealesed = YES;
		[self release];
	}

}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    id<NSURLAuthenticationChallengeSender> challangeSender = [challenge sender];

    if ( [challenge previousFailureCount] == 0) {
        NSURLCredential *credential = [challenge proposedCredential];
      
        if ( [authLogin length] > 0 && [authPassword length] > 0 ) {
            credential = [NSURLCredential credentialWithUser:authLogin password:authPassword persistence:NSURLCredentialPersistenceNone];
        } 
        
        if ( credential != nil ) {
            [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
            return;            
        }
    }
    
    [challangeSender continueWithoutCredentialForAuthenticationChallenge:challenge];
}


- (void)connection:(NSURLConnection *)inConnection didFailWithError:(NSError *)error {

	[WebRequestObject stopLoad:self];
	
	[connection release];
	connection = nil;

	if ( delegate != nil && [delegate respondsToSelector:@selector(webRequestObject:didFailWithConnectionError:)] ) {
		[delegate webRequestObject:self didFailWithConnectionError:error];
	}
	
	if ( releaseAfterFinish && !isAutorealesed ) {
		isAutorealesed = YES;
		[self release];
	}		
}


@end

