

#import <UIKit/UIKit.h>

//! Protocol for all cocrate WebRequestObject classes
@protocol WebRequestObjectProtocol

//! In this method concrate class must properly setup mutable request and other needed data before connection will start
- (void) initialize;

//! This method would be called when connection downloaded all data.
/*! In this method you can parse or do anything else with downloaded data and must call 
 eather returnParseResult: or returnParseError: method and immidiatly return after this.
 */
- (void) parse;

@end

@class WebRequestObject;

//! WebRequestObject delegate category
@interface NSObject(WebRequestObjectDelegate)

//! Called when connection did recieve response
- (void) webRequestObject:(WebRequestObject*) webRequestObject didReceiveResponse:(NSURLResponse*) response;

//! Called when connection did get piece of data
- (void) webRequestObject:(WebRequestObject*) webRequestObject didReceiveDataWithLength:(NSUInteger) length;

//! Called when connection downloaded all data
- (void) webRequestObjectDidFinishLoading:(WebRequestObject*) webRequestObject;

//! Called when connection failed
- (void) webRequestObject:(WebRequestObject*) webRequestObject didFailWithConnectionError:(NSError *)error;

//! Called when web request successfully parsed data
- (void) webRequestObject:(WebRequestObject*) webRequestObject didFinishParsingWithResult:(id) parseResult;

//! Called when web request parse failed
- (void) webRequestObject:(WebRequestObject*) webRequestObject didFailWithParseError:(NSError *)error;

@end 

@class Reachability;

//! Base class that used in factory method to produce concrate web requests
@interface WebRequestObject : NSObject {
	
	// Input: 
	//! Mutable request used by connection
	NSMutableURLRequest	*request; // Created on init

	//! WebRequestObject delegate
	id					delegate;

	//! Flag indicating that WebRequestObject object must release himself after operations with connections finished (default: NO)
	BOOL				releaseAfterFinish;
	
	//! Internal lock flag indicating that autorelease method already shot
	BOOL				isAutorealesed;
	
	//! User dictionary used to store user depended and initialize data 
	NSMutableDictionary	*userInfo; // I/O data
	
	//! Connection response
	NSHTTPURLResponse	*response;	
	
	
	// Internal:
	//! Connection response body data
	NSMutableData		*responseBody;
	
	//! Web connection object
	NSURLConnection		*connection;

	NSUInteger			loadedLength;
	
	BOOL				shouldRestart;
	Reachability		*reachability;
	NSTimer				*reachabilityTimer;
	
	BOOL				shouldSendDidReceiveWithTimeOut;
	NSDate				*lastDidReceiveSent;
	NSTimeInterval		didReceiveTimeout;
    NSUInteger          lastRecievedLength;
    
    NSString            *authLogin;
    NSString            *authPassword;
}

@property (nonatomic, retain, readonly) NSMutableURLRequest	*request;
@property (nonatomic, retain, readonly) NSHTTPURLResponse	*response;
@property (nonatomic, retain)			NSMutableDictionary	*userInfo;
@property (nonatomic, retain, readonly) NSMutableData		*responseBody;
@property (nonatomic, assign)			id					delegate;
@property (nonatomic)					BOOL				releaseAfterFinish;
@property (nonatomic, readonly)			long long			expectedContentLength;
@property (nonatomic, readonly)			NSInteger			statusCode;
@property (nonatomic, readonly)			NSUInteger			loadedLength;
@property (nonatomic, readonly)			BOOL				unzippedNatively;
@property (nonatomic, retain)			Reachability		*reachability;
@property (nonatomic)					BOOL				shouldSendDidReceiveWithTimeOut;
@property (nonatomic)					NSTimeInterval		didReceiveTimeout;
@property (nonatomic, retain)			NSString            *authLogin;
@property (nonatomic, retain)			NSString            *authPassword;

//! Initialize method that save user info dictionary
- (id) initWithInfo:(NSMutableDictionary*) info;


//! Method that start connection request
- (BOOL) send;

//! Cancel current connection request
- (void) cancel;

//! Reseting current connection request before starting call
- (void) reset;


// Internal Inheritance use
//! Method called by concrate WebRequestObject to inform delegate about successful parse result
- (void) returnParseResult:(id) parseResult;

//! Method called by concrate WebRequestObject to inform delegate about parse fail
- (void) returnParseError:(NSError*) parseError;

// private
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)inResponse;
- (void)connection:(NSURLConnection *)inConnection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)inConnection;

@end

