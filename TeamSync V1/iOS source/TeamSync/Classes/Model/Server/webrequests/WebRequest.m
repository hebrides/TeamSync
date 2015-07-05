
#import "WebRequest.h"
#import "JSONKit.h"

static const NSUInteger kMemoryBuffSize = 65536;

@implementation WebRequest

@synthesize url;
@synthesize scheme;
@synthesize serverAddress;
@synthesize port;
@synthesize path;
@synthesize queryDict;
@synthesize headersDict;
@synthesize pathElements;
@synthesize requestBody;
@synthesize method;
@synthesize streamFilePath;
@synthesize responseType;
@synthesize responseMode;
@synthesize priority;
@synthesize resumeRange;
@synthesize useGZIP;
@synthesize resumeLastDownload;
@synthesize startFileSize;
@synthesize dataParser;
@synthesize oauthSigner;

#pragma mark -
#pragma mark WebRequestObjectProtocol imp

- (id) initWithInfo:(NSMutableDictionary*) info
{
	self = [super initWithInfo:info];
	if (self != nil) {
		pathElements = [NSMutableArray new];
		priority = WebRequestPriorityNormal;
		self.method = @"GET";
		self.scheme = @"http";
		resumeRange = -1;
	}
	return self;
}

- (void) reset {
	[super reset];
	startFileSize = 0;
}


- (void) initialize {

    if ( url == nil ) {
        NSString *query = [WebRequest createQueryFromDict:queryDict];
        NSString *additionalPath = [WebRequest createPathFromArr:pathElements];
        
        NSString *portStr = ( port == 0 ) ? @"" : [NSString stringWithFormat:@":%d", port];
        self.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@%@%@%@%@", 
                                         scheme,
                                         serverAddress,
                                         portStr, 
                                         path, 
                                         additionalPath,
                                         query]];
    }
    
	[request setURL:url];
	[request setHTTPMethod:method];
	
	NSLog(@"Send URL: %@", [request URL]);
	
	[request setHTTPBody:requestBody];
	
	for (NSString *key in headersDict) {
		[request setValue:[headersDict valueForKey:key] forHTTPHeaderField:key];
	}	
		
	if ( useGZIP ) {
		[request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];		
		[request setValue:@"deflate" forHTTPHeaderField:@"Accept-Encoding"];
	}
	
    // TODO: Add resume feature
    resumeLastDownload = NO;
//	if ( resumeLastDownload ) {
//		if ( resumeRange < 0 ) {
//			NSDictionary *fileAttr = [[NSFileManager defaultManager] attributesOfItemAtPath:self.streamFilePath error:nil];
//			[request setValue:[NSString stringWithFormat:@"%qu", [fileAttr fileSize]] forHTTPHeaderField:@"Range"];			
//		} else {
//			[request setValue:[NSString stringWithFormat:@"%d", resumeRange] forHTTPHeaderField:@"Range"];
//		}
//	}
	
	switch (responseType) {
		case WebRequestResponseTypeText:
			[request setValue:@"text/plain" forHTTPHeaderField:@"accept"];
			break;
		case WebRequestResponseTypeJSON:
			[request setValue:@"application/json" forHTTPHeaderField:@"accept"];
			break;
		case WebRequestResponseTypeXML:
			[request setValue:@"xml" forHTTPHeaderField:@"accept"];
			break;
		case WebRequestResponseTypeBinary:
		default:
			break;
	}
	
    if ( [oauthSigner respondsToSelector:@selector(webRequestShouldSign:)] ) {
        [oauthSigner webRequestShouldSign:self];
    }
    
	//NSLog(@"Headers out: %@", [request allHTTPHeaderFields]);
}

- (void) parse {
	
    if ( (self.statusCode >= 400 || self.statusCode == 204) ) {
		NSError *error = [NSError errorWithDomain:@"HTTTPResponseErrorDomain"
											 code:self.statusCode
										 userInfo:nil];
		[self returnParseError:error];
		return;
	}
    
	switch (responseMode) {
		case WebRequestResponseModeData:;
			NSString *resString = nil;
			id result = nil;
			switch (responseType) {
				case WebRequestResponseTypeJSON:;
                    JSONDecoder *jsonDecoder = [JSONDecoder decoder];
                    NSError *error = nil;
                    result = [jsonDecoder parseJSONData:self.responseBody error:&error];
                    if ( error == nil) {
                        [self returnParseResult:result];                        
                    } else {
                        [self returnParseError:error];
                    }
					break;
				case WebRequestResponseTypeXML:;
                    XMLCollector *parser = [[XMLCollector alloc] init];
                    parser.storeElementParameters = YES;
                    [parser setNodeNamesRequireArray:[NSArray arrayWithObjects:@"CompleteSuggestion", nil]];
                    NSDictionary *result = [parser parseAndCollectData:self.responseBody];
                    [parser release];
					[self returnParseResult:result];
					break;
				case WebRequestResponseTypeBinary:
					[self returnParseResult:self.responseBody];
					break;
				case WebRequestResponseTypeText:
					resString = [[[NSString alloc] initWithData: self.responseBody encoding:NSUTF8StringEncoding] autorelease];
					[self returnParseResult:resString];
					break;
				default:
					[self returnParseResult:self.responseBody];
					break;
			}
			break;
		case WebRequestResponseModeFileStream:
			[fileStream close];
			[self returnParseResult:nil];
			break;
        case WebRequestResponseModeDynamicParsing:;
            NSError *error = nil;
            result = [dataParser webRequest:self parseDataChunk:self.responseBody error:&error];
            if ( error != nil) {
                [self cancel];
                [self returnParseError:error];
            } else if ( result != nil ) {
                [self returnParseResult:result];
            }
            
            break;
		default:
			break;
	}
}

#pragma mark -
#pragma mark Common

- (BOOL) flushMemoryToStream {
	NSUInteger length = [responseBody length];
	if ( [fileStream write:[responseBody bytes] maxLength:length] != length) {
		//NSLog(@"Stream [%@] error [%d]", fileStream, [fileStream streamStatus] );
		[connection cancel];
		if ( delegate != nil && [delegate respondsToSelector:@selector(WebRequest:didFailedWithStreamError:)] ) {
			[delegate WebRequest:self didFailedWithStreamError:[fileStream streamError]];
		}
		[self cancel];
		return NO;
	}
	
	[responseBody setLength:0];
	
	return YES;
}

+ (NSString*) createQueryFromDict:(NSDictionary*) querySource {
	NSMutableArray *pairs = [NSMutableArray arrayWithCapacity:[querySource count]];
	NSString *query = @"";
	for (NSString *key in querySource) {
		[pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [querySource valueForKey:key]]];
	}
	
	if ( [pairs count] > 0 ) {
		query = [[query stringByAppendingFormat:@"?%@", [pairs componentsJoinedByString:@"&"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	}

	return query;
}

+ (NSString*) createPathFromArr:(NSArray*) pathElements {
	NSMutableString *result = [NSMutableString string];
	for (id pathElement in pathElements) {
		[result appendFormat:@"/%@", pathElement];
	}
	
	return result;
}

#pragma mark -
#pragma mark WebRequestObject imp

//- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
//	return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
//	if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
//
//			[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
//	
//	[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
//}


- (void)connection:(NSURLConnection *) inConnection didReceiveResponse:(NSHTTPURLResponse *)inResponse {
	
	[response autorelease];
	response = [inResponse retain];
	if ( responseMode != WebRequestResponseModeData && (self.statusCode >= 400 || self.statusCode == 204) ) {
		NSError *error = [NSError errorWithDomain:@"HTTTPResponseErrorDomain"
											 code:[(NSHTTPURLResponse*)inResponse statusCode]
										 userInfo:nil];
		[self returnParseError:error];
		[self cancel];
		return;
	}
	
	switch (responseMode) {
		case WebRequestResponseModeData:
			[super connection:inConnection didReceiveResponse:inResponse];
			break;
		case WebRequestResponseModeFileStream:

			if ( streamFilePath == nil && [streamFilePath length] == 0) {
				self.streamFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithUUID]];
			}
			
			// Create file dir
			NSString *destDir = [streamFilePath stringByDeletingLastPathComponent];
			NSFileManager *fileManager = [NSFileManager defaultManager];
			[fileManager createDirectoryAtPath:destDir withIntermediateDirectories:YES attributes:nil error:nil];
			
			//NSLog(@"streamFilePath: %@", streamFilePath);
			
			fileStream = [[NSOutputStream outputStreamToFileAtPath:streamFilePath append:resumeLastDownload] retain];
			[fileStream open];
			if ( fileStream == nil || [fileStream streamStatus] != NSStreamStatusOpen ) {
				//NSLog(@"Stream [%@] error [%d]", fileStream, [fileStream streamStatus] );
				[connection cancel];
				if ( delegate != nil && [delegate respondsToSelector:@selector(WebRequest:didFailedWithStreamError:)] ) {
					[delegate WebRequest:self didFailedWithStreamError:[fileStream streamError]];
				}
				[self cancel];
				return;
			}

			NSDictionary *fileAttr = [[NSFileManager defaultManager] attributesOfItemAtPath:self.streamFilePath error:nil];	
			startFileSize = [fileAttr fileSize];
			
			if ( delegate != nil && [delegate respondsToSelector:@selector(webRequestObject:didReceiveResponse:)] ) {
				[delegate webRequestObject:self didReceiveResponse:response];
			}
			break;
		default:
			break;
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)inConnection {
	switch (responseMode) {
		case WebRequestResponseModeFileStream:
			if (![self flushMemoryToStream]) {
				return;
			}
			break;
		default:
			break;
	}
	

	
	[super connectionDidFinishLoading:inConnection];
}

#pragma mark -
#pragma mark NSOutputStream delegate

- (void)connection:(NSURLConnection *)inConnection didReceiveData:(NSData *)data {
	
	switch (responseMode) {
		case WebRequestResponseModeData:
			[super connection:inConnection didReceiveData:data];
			break;
		case WebRequestResponseModeFileStream:;
			
			loadedLength += [data length];
			lastRecievedLength += [data length];
			if ( [responseBody length] + [data length] >= kMemoryBuffSize ) {
				if (![self flushMemoryToStream]) {
					return;
				}
			}
			
			[responseBody appendData:data];
			
			if ( !(shouldSendDidReceiveWithTimeOut && [[NSDate date] timeIntervalSinceDate:lastDidReceiveSent] < didReceiveTimeout) ) {
				[lastDidReceiveSent release];
				lastDidReceiveSent = [[NSDate date] retain];
				if ( delegate != nil && [delegate respondsToSelector:@selector(webRequestObject:didReceiveDataWithLength:)] ) {
					[delegate webRequestObject:self didReceiveDataWithLength:lastRecievedLength];
				}
                lastRecievedLength = 0;
			}
			break;
        case WebRequestResponseModeDynamicParsing:
            loadedLength += [data length];
            [self.responseBody appendData:data];
            [self parse];
            [self.responseBody setLength:0];
            break;
		default:
			break;
	}
}

#pragma mark -
#pragma mark Dealloc

- (void) dealloc{
    [url release];
	[scheme release];
	[pathElements release];
	[requestBody release];
	[method release];
	[serverAddress release];
	[path release];
	[queryDict release];
	[headersDict release];
	[fileStream close];
	[fileStream release];
	[streamFilePath release];
    self.dataParser = nil;
    self.oauthSigner = nil;
	[super dealloc];
}

@end

