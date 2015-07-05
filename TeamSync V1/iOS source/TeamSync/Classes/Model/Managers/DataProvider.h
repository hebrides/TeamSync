//
//  DataProvider.h
//  App_iphoneim
//
//  Created for SMG Mobile on 12/22/11.
//  
//


#import "DataManager.h"
// Core Data
#import "CoreDataObjects.h"



@interface DataProvider : NSObject {
    
}
@property (nonatomic, retain) NSArray *allClubEvents; //unused

+ (DataProvider*) sharedInstance;


#pragma mark -
+ (NSArray*)array:(NSArray*)array sortedByKey:(NSString*)key ascending:(BOOL)ascending;
+ (NSArray*)array:(NSArray*)array sortedByKey:(NSString*)key;
+ (NSArray*)arraySortedByKey:(NSString*)key from:(NSSet*)inputSet ascending:(BOOL)ascending;
+ (NSArray*)arraySortedByKey:(NSString*)key from:(NSSet*)inputSet;

#pragma mark -

#pragma mark - Main provide method
- (NSArray*)selectForObjectName:(NSString*)name 
				 fieldPredicate:(NSPredicate*)predicate
					  orderName:(NSString*)order;
#pragma mark -

+ (NSArray*)allUsers;
+ (User*)currentActiveUser;
+ (NSArray*)allPlaylists;
+ (NSArray*)allPlaylistsForCurrentActiveUser;
+ (NSArray*)allDetectedTracks;
+ (NSArray*)allMasters;

+ (NSArray*)allPlaylistsFromIPod;

#pragma mark For sending to server
+ (NSData*)signUpDataWithUsername:(NSString*)username email:(NSString*)email password:(NSString*)password; 
+ (NSData*)loginDataWithUsername:(NSString*)username password:(NSString*)password role:(BOOL)isMaster;
+ (NSData*)JSONDataFromPlaylist:(Playlist*)playlist;
+ (NSData*)mastersListData;
+ (NSData*)playlistDataForMaster:(Master*)master;


@end
