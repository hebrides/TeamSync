//
//  AppServerHelper.m
//  App_iphone
//
//  Created for SMG Mobile on 1/25/12.
//  
//

#import "AppServerHelper.h"
#import "Constants.h"
#import "AppServer.h"
#import "DataProvider.h"

#import "AppLogicManager.h"



@implementation AppServerHelper


#pragma mark -
#pragma mark Instance

+ (AppServerHelper*) sharedInstance {
    
	static AppServerHelper *sharedAppServerHelper = nil;
	if (sharedAppServerHelper == nil) {
		sharedAppServerHelper = [[AppServerHelper alloc] init];
	}
	return sharedAppServerHelper;
}

//+ (void)searchRequestFor:(NSString*)keyword withlistener:(id<ServerRequestDelegate>)listener {
//    [[AppServer sharedInstance] removeDelegate:listener forServerRequest:ServerRequestItunesSearch];
//    [[AppServer sharedInstance] addDelegate:listener forServerRequest:ServerRequestItunesSearch];
//    NSString *url = [NSString stringWithFormat:@"%@%@", ITUNES_SEARCH_PREFIX, keyword];
//    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    [[AppServer sharedInstance] sendRequest:ServerRequestItunesSearch userInfo:nil url:url];
//}

+ (void)sendPlaylist:(Playlist*)playlist toStartSessionWithlistener:(id<ServerRequestDelegate>)listener {
    
    NSData *body = [DataProvider JSONDataFromPlaylist:playlist];
    
    [[AppServer sharedInstance] removeDelegate:listener forServerRequest:ServerRequestSendPlaylistToStartSession];
    [[AppServer sharedInstance] addDelegate:listener forServerRequest:ServerRequestSendPlaylistToStartSession];

    User *user = [DataProvider currentActiveUser];
    NSString *url = [NSString stringWithFormat:@"%@?token=%@", SEND_PLAYLIST_TO_START_SESSION, user.token];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[AppServer sharedInstance] sendRequest:ServerRequestSendPlaylistToStartSession userInfo:nil 
                                        url:url body:body];
}

+ (void)signUpUsername:(NSString*)username email:(NSString*)email 
              password:(NSString*)password withlistener:(id<ServerRequestDelegate>)listener {
    
    NSData *body = [DataProvider signUpDataWithUsername:username email:email password:password];
    
    [[AppServer sharedInstance] removeDelegate:listener forServerRequest:ServerRequestSignUp];
    [[AppServer sharedInstance] addDelegate:listener forServerRequest:ServerRequestSignUp];
    [[AppServer sharedInstance] sendRequest:ServerRequestSignUp userInfo:nil 
                                        url:SEND_PLAYLIST_TO_START_SESSION body:body];
}

+ (void)loginWithUsername:(NSString*)username password:(NSString*)password role:(BOOL)isMaster withlistener:(id<ServerRequestDelegate>)listener {
    NSData *body = [DataProvider loginDataWithUsername:username password:password role:isMaster];
    
    [[AppServer sharedInstance] removeDelegate:listener forServerRequest:ServerRequestLogin];
    [[AppServer sharedInstance] addDelegate:listener forServerRequest:ServerRequestLogin];
    [[AppServer sharedInstance] sendRequest:ServerRequestLogin userInfo:nil 
                                        url:SEND_PLAYLIST_TO_START_SESSION body:body];
}

+ (void)updateMastersListWithlistener:(id<ServerRequestDelegate>)listener {
    NSData *body = [DataProvider mastersListData];
    
    User *user = [DataProvider currentActiveUser];
    NSString *url = [NSString stringWithFormat:@"%@?token=%@", SEND_PLAYLIST_TO_START_SESSION, user.token];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[AppServer sharedInstance] removeDelegate:listener forServerRequest:ServerRequestMastersList];
    [[AppServer sharedInstance] addDelegate:listener forServerRequest:ServerRequestMastersList];
    [[AppServer sharedInstance] sendRequest:ServerRequestMastersList userInfo:nil 
                                        url:url body:body];
}

+ (void)updateMaster:(Master*)master playlistWithlistener:(id<ServerRequestDelegate>)listener {
    NSData *body = [DataProvider playlistDataForMaster:master];
    
    User *user = [DataProvider currentActiveUser];
    NSString *url = [NSString stringWithFormat:@"%@?token=%@", SEND_PLAYLIST_TO_START_SESSION, user.token];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:master forKey:kCDOMaster];
    
    [[AppServer sharedInstance] removeDelegate:listener forServerRequest:ServerRequestGetMastersPlaylist];
    [[AppServer sharedInstance] addDelegate:listener forServerRequest:ServerRequestGetMastersPlaylist];
    [[AppServer sharedInstance] sendRequest:ServerRequestGetMastersPlaylist userInfo:userInfo 
                                        url:url body:body];
}


@end
