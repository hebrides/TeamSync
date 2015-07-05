
#import <UIKit/UIKit.h>
#import "WebRequestObject.h"
#import "WebRequest.h"
//#import "DataManager.h"


//extern NSString *const kGoogleSearchSuggesstions;

//! Class used in factory method pattern to produce WebRequestObject objects
@interface WebRequestBuilder : NSObject {

}

//! Method that create WebRequestObject objects by infi dictionary.
/*! To create WebRequestObject object you need properly setup info dictionary.
 That dictionary at leat must have kWebRequestObjectClass key with class name of needed request object
 Also it can have any other key and values needed by concrate WebRequestObject class or by code that used this request
*/
+ (WebRequest*) createWebRequestObjectWithInfoDictionary:(NSMutableDictionary*) requestInfo;

//+ (WebRequest*) requestSearchGoogleForTerm:(CDTerm*) term;
//+ (BOOL) isSearchGoogleForTermRequest:(WebRequest*) request;
+ (WebRequest*) createWebRequestWithURL:(NSURL*) url;




@end

