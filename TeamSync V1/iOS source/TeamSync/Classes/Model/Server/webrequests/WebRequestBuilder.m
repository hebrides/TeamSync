
#import "WebRequestBuilder.h"
//#import "AppDelegate.h"

//NSString *const kGoogleSearchSuggesstions = @"/complete/search";

@implementation WebRequestBuilder

#pragma mark -
#pragma mark Build base object

+ (WebRequest*) createWebRequestObjectWithInfoDictionary:(NSMutableDictionary*) requestInfo {
	return [[[WebRequest alloc] initWithInfo:requestInfo] autorelease];
}

#pragma mark -
#pragma mark Building
+ (WebRequest*) createWebRequestWithURL:(NSURL*) url {
	WebRequest *request     = [[WebRequest alloc] initWithInfo:nil];
    request.url             = url;
	//request.reachability	= [AppDelegate sharedInstance].reachability;
	request.priority		= WebRequestPriorityHigh;
    request.responseType    = WebRequestResponseTypeBinary;
    
	return [request autorelease];
	
}


//+ (BOOL) isRequestCitylist:(WebRequest*) request {
//	return [[request.userInfo valueForKey:kRequestKey] isEqualToString:kCityRequestValue];
//}

//+ (WebRequest*) requestSearchGoogleForTerm:(CDTerm*) term {
//    // http://google.com/complete/search?output=toolbar&q=searchTerm
//	WebRequest *request     = [[WebRequest alloc] initWithInfo:nil];
//    request.serverAddress   = @"google.com";
//	request.reachability	= [AppDelegate sharedInstance].reachability;
//	request.path			= kGoogleSearchSuggesstions;
//	request.priority		= WebRequestPriorityHigh;
//    request.responseType    = WebRequestResponseTypeXML;
//  	request.queryDict       = [NSDictionary dictionaryWithObjectsAndKeys:
//                               @"toolbar", @"output",
//                               term.text, @"q", nil];
//    
//	return [request autorelease];
//}


#pragma mark -
#pragma mark Determining

//+ (BOOL) isSearchGoogleForTermRequest:(WebRequest*) request {
//	return [request.path isEqualToString:kGoogleSearchSuggesstions];
//}


@end

