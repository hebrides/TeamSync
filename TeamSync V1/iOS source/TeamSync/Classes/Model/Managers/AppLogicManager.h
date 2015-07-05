//
//  AppLogicManager.h
//  App_iphoneim
//
//  Created for SMG Mobile on 12/20/11.
//  
//

#import <Foundation/Foundation.h>

#import "CoreDataObjects.h"

// for tickets


@interface AppLogicManager : NSObject
+ (BOOL)isFirstAppStart;
+ (void)closeSession;

+ (void)setupReachability;
+ (BOOL)isOnline;


//- (void)deleteUser:(User*)user;
//- (void)deletePlaylist:(Playlist*)playlist;
//- (void)deleteTrack:(Track*)Track;



+ (void)logoutActiveUser;
+ (void)setActiveUsername:(NSString*)username password:(NSString*)password isMaster:(BOOL)isMaster;

@end
