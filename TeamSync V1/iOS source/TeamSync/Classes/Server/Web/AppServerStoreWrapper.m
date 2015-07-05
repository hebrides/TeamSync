//
//  AppServerStoreWrapper.m
//  App_iphone
//
//  Created for SMG Mobile on 2/7/12.
//  
//

#import "AppServerStoreWrapper.h"
#import "StoreManager.h"
#import "Common.h"
#import "Utils.h"
#import "DataProvider.h"

@implementation AppServerStoreWrapper

/*
+ (void)check2Dic:(NSDictionary*)dic {
    NSArray *keys = [dic allKeys];
    for (NSString *key in keys) {
        
        NSObject *obj = [dic objectForKey:key];
        if ([[key lowercaseString] isEqualToString:@"club"]) { //21498
            NSLog(@"key: %@", key);
            NSLog(@"obj: %@", obj);
        }
        
        if ([obj isKindOfClass:[NSDictionary class]]) {
            [AppServerStoreWrapper check2Dic:(NSDictionary*)obj];
        } else if ([obj isKindOfClass:[NSArray class]]) {
            [AppServerStoreWrapper check1Arr:(NSArray*)obj];
        }
        
    }
}
+ (void)check1Arr:(NSArray*)arr {
    
    for (NSObject *obj in arr) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            [AppServerStoreWrapper check2Dic:(NSDictionary*)obj];
        } else if ([obj isKindOfClass:[NSArray class]]) {
            [AppServerStoreWrapper check1Arr:(NSArray*)obj];
        }
    }
}

*/
//+ (NSMutableDictionary*)parseXMLData:(NSData*)xmlData {
//	XMLCollector *parser = [[[XMLCollector alloc] init] autorelease];
//	parser.storeElementParameters = YES;
//	return [NSMutableDictionary dictionaryWithDictionary:[parser parseAndCollectData:xmlData]];	
//}
+ (NSArray*)arrayForKeyPath:(NSString*)path from:(NSDictionary*)dic {
    NSArray *array = [dic safeValueForKeyPath:path];
    if (array != nil && [array isKindOfClass:[NSDictionary class]]) {
        return [NSArray arrayWithObject:array];
    }
    return array;
}

+ (id)storeData:(NSData*)responseData fromRequest:(ServerRequest)serverRequest userInfo:(NSDictionary*)userInfo {
   
    id result = [responseData objectFromJSONData];
    
//    if (result == nil) {
//        result = [self parseXMLData:responseData];
//    }
    
//    NSString *str = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//    NSLog(@"str: %@", str);
//    NSLog(@"result: %@", result);
    
//    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"RESPONSE" 
//                                                     message:str
//                                                    delegate:nil 
//                                           cancelButtonTitle:@"OK"
//                                           otherButtonTitles:nil];
//    [alert show];


    if (serverRequest == ServerRequestSignUp) { 

    } else if (serverRequest == ServerRequestLogin) {
        User *user = [DataProvider currentActiveUser];
        user.token = [result objectForKey:@"token"];
        
//    } else if (serverRequest == ServerRequestItunesSearch) {
//        NSString *path = @"results";
//        NSArray *items = [self arrayForKeyPath:path from:result];
//        [[StoreManager sharedInstance] updateDetectedItunesTracksWith:items];        
//    
    } else if (serverRequest == ServerRequestSendPlaylistToStartSession) {
    
    } 
    // SLAVE
    else if (serverRequest == ServerRequestMastersList) { 
        [[StoreManager sharedInstance] updateMastersListWith:result];
    
    } else if (serverRequest == ServerRequestGetMastersPlaylist) {
        Master *master = [userInfo objectForKey:kCDOMaster];
        [[StoreManager sharedInstance] updatePlaylist:result forMaster:master];
    }
    else {
//        NSString *str = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
//        NSLog(@"str: %@", str);
//        //
//        //        NSString *writePath = [[Utils docPath] stringByAppendingString:@"/BeatportTrackRelatedArtists.plist"];
//        //        BOOL write = [result writeToFile:writePath atomically:YES];
//        //        NSLog(@"write: %d", write);
//
//        NSLog(@"bodyScheme: %@", result);
    }

    return result;
}

@end
