//
//  AppServerStoreWrapper.h
//  App_iphone
//
//  Created for SMG Mobile on 2/7/12.
//  
//

#import "AppServerHelper.h"

@interface AppServerStoreWrapper : NSObject
+ (id)storeData:(NSData*)responseData fromRequest:(ServerRequest)request userInfo:(NSDictionary*)userInfo;
@end
