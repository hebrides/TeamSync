//
//  AppLogicManager.m
//  App_iphoneim
//
//  Created for SMG Mobile on 12/20/11.
//  
//

#import "AppLogicManager.h"

#import "Reachability.h"

#import "CoreDataObjects.h"
#import "DataManager.h"
#import "DataProvider.h"
#import "StoreManager.h"

@interface AppLogicManager ()

+ (Reachability*)getReachability;
+ (void)reachabilityChanged:(NSNotification*)notification;
+ (void)updateNetworkStatus:(Reachability*)currReachability;

@end


@implementation AppLogicManager

static NSString * const kFirstAppSessionKey  = @"First_Session_Revert_Key";

+ (BOOL)isFirstAppStart {
    return ! [[NSUserDefaults standardUserDefaults] boolForKey:kFirstAppSessionKey];
}

+ (void)closeSession {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFirstAppSessionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[DataManager sharedInstance] save];
}


+ (Reachability*)getReachability {
    __strong Reachability *reachability = nil;
	if (reachability == nil) {
		reachability = [Reachability reachabilityForInternetConnection];
		[[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(reachabilityChanged:) 
                                                     name:kReachabilityChangedNotification object:nil];
	}
    return reachability;
}

+ (void)setupReachability {
    Reachability *reachability = [self getReachability];
	[self updateNetworkStatus:reachability];
	[reachability startNotifier];
	
}

+ (void)reachabilityChanged:(NSNotification*)notification {
	Reachability* reachability = [notification object];
	[self updateNetworkStatus: reachability];
}

+ (void)updateNetworkStatus:(Reachability*)reachability {
	BOOL isOnline = ([reachability currentReachabilityStatus] != NotReachable);
    
	if (isOnline == NO) {
//		NSString *errorMessage = @"It was not possible to connect to internet. Please check your internet connection and mobile settings.";
	}
}

+ (BOOL)isOnline {
    Reachability *reachability = [self getReachability];
    return ([reachability currentReachabilityStatus] != NotReachable);
}


+ (void)logoutActiveUser {
    NSArray *users = [DataProvider allUsers];
    for (User *user in users) {
        user.isActive = [NSNumber numberWithBool:NO];
    }
}

+ (void)setActiveUsername:(NSString*)username password:(NSString*)password isMaster:(BOOL)isMaster{
   
    NSArray *users = [DataProvider allUsers];
    BOOL hasThisUser = NO;
    for (User *user in users) {
        if ([user.username isEqualToString:username] == NO) {
            user.isActive = [NSNumber numberWithBool:NO];
        } else {
            user.isActive = [NSNumber numberWithBool:YES];
            user.isMaster = [NSNumber numberWithBool:isMaster];
            hasThisUser = YES;
        }
        
    }
    if (hasThisUser == NO) {
        User *user = [[StoreManager sharedInstance] createNewUserWith:username];
        user.password = password;
        user.isActive = [NSNumber numberWithBool:YES];
        user.isMaster = [NSNumber numberWithBool:isMaster];
    }
}

@end
