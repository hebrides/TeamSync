//
//  DataProvider.m
//  App_iphoneim
//
//  Created for SMG Mobile on 12/22/11.
//  
//

#import "DataProvider.h"

/////
#import "Common.h"
//#import "Utils.h"


@implementation DataProvider
@synthesize allClubEvents;

#pragma mark -
#pragma mark Instance
+ (DataProvider*) sharedInstance {
	static DataProvider *sharedDataProvider = nil;
	if (sharedDataProvider == nil) {
		sharedDataProvider = [[DataProvider alloc] init];
	}
	return sharedDataProvider;
}


#pragma mark -
#pragma mark Application custom methods

+ (NSArray*)array:(NSArray*)array sortedByKey:(NSString*)key ascending:(BOOL)ascending {
	NSMutableArray *outputArray = [NSMutableArray arrayWithArray:array];
	
	NSSortDescriptor* sorter = [[NSSortDescriptor alloc] initWithKey:key ascending: ascending] ;
	[outputArray sortUsingDescriptors:[NSArray arrayWithObject:sorter]];
	
	return outputArray;	
}
+ (NSArray*)array:(NSArray*)array sortedByKey:(NSString*)key {
	return [DataProvider array:array sortedByKey:key ascending:YES];	
}

+ (NSArray*)arraySortedByKey:(NSString*)key from:(NSSet*)inputSet ascending:(BOOL)ascending {
	return [DataProvider array:[inputSet allObjects] sortedByKey:key ascending:ascending];	
}

+ (NSArray*)arraySortedByKey:(NSString*)key from:(NSSet*)inputSet {
	return [DataProvider array:[inputSet allObjects] sortedByKey:key];	
}


- (NSArray*)selectForObjectName:(NSString*)name 
				 fieldPredicate:(NSPredicate*)predicate
					  orderName:(NSString*)order {
	NSFetchRequest *req = [[NSFetchRequest alloc] init];
	
	if (predicate != nil) {
		[req setPredicate: predicate];		
	}
	
	if ([order length] > 0) {
		NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:order ascending:YES];
		[req setSortDescriptors:[NSArray arrayWithObject:sorter]];
		
	}	
	[req setEntity:[NSEntityDescription entityForName:name 
							   inManagedObjectContext:[DataManager sharedInstance].managedObjectContext]];
	NSArray *res = [[DataManager sharedInstance].managedObjectContext executeFetchRequest:req error:nil];
	return res;
}


#pragma mark -
#pragma mark Providing Objects 
+ (NSArray*)allUsers {
    return [[DataManager sharedInstance] getObjectsForName:kCDOUser sortDescriptorsKey:@"username"];
}

+ (User*)currentActiveUser {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isActive == yes"];
    NSArray *users = [[DataProvider sharedInstance] selectForObjectName:kCDOUser fieldPredicate:predicate orderName:nil];
    if ([users count] == 1) {
        return [users objectAtIndex:0];
    }
    return nil;
}

+ (NSArray*)allPlaylists {
    return [[DataManager sharedInstance] getObjectsForName:kCDOPlaylist sortDescriptorsKey:kCDOPropertyOrder];
}

+ (NSArray*)allPlaylistsForCurrentActiveUser {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user == %@ and isIPodOwner == no and master == nil", [DataProvider currentActiveUser]];
    return [[DataProvider sharedInstance] selectForObjectName:kCDOPlaylist fieldPredicate:predicate orderName:nil];
}

+ (NSArray*)allDetectedTracks {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"playlist == nil"];
    return [[DataProvider sharedInstance] selectForObjectName:kCDOTrack fieldPredicate:predicate orderName:nil];
}
+ (NSArray*)allMasters {
    return [[DataProvider sharedInstance] selectForObjectName:kCDOMaster fieldPredicate:nil orderName:@"login"];
}
+ (NSArray*)allPlaylistsFromIPod {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isIPodOwner == yes"];
    return [[DataProvider sharedInstance] selectForObjectName:kCDOPlaylist 
                                               fieldPredicate:predicate orderName:nil];

}
#pragma mark For sending to server

+ (NSData*)JSONDataFromPlaylist:(Playlist*)playlist {
    NSArray *tracks = [DataProvider arraySortedByKey:kCDOPropertyOrder from:playlist.tracks];
    NSMutableArray *validateDics = [NSMutableArray arrayWithCapacity:[tracks count]];
    
    for (Track *track in tracks) {
        NSArray *keys = [[[track entity] attributesByName] allKeys];
        NSDictionary *trackValues = [track dictionaryWithValuesForKeys:keys];
        NSMutableDictionary *trackInfo = [NSMutableDictionary dictionaryWithDictionary:trackValues];

        NSString *releaseDate = [NSString stringWithFormat:@"%@", [trackInfo objectForKey:@"releaseDate"]];
        [trackInfo setObject:releaseDate forKey:@"releaseDate"];

        [validateDics addObject:trackInfo];
        
        [trackInfo setObject:@"itunes" forKey:@"service"];
    }
    
    NSMutableDictionary *resPlaylist = [NSMutableDictionary dictionary];
    [resPlaylist setObject:validateDics forKey:@"tracks"];
    [resPlaylist setObject:playlist.title forKey:@"title"];
    [resPlaylist setObject:@"now empty" forKey:@"desc"];
    
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:2];
    [result setObject:resPlaylist forKey:@"playlist"];
    
//    User *user = playlist.user;
    [result setObject:@"master" forKey:@"role"];
//    [result setObject:user.username forKey:@"login"];
    
    NSString *resultJSON = [result JSONString];
    resultJSON = [NSString stringWithFormat:@"data=%@", resultJSON];
    return [resultJSON dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSData*)signUpDataWithUsername:(NSString*)username email:(NSString*)email password:(NSString*)password {
    
    NSMutableDictionary *credInfo = [NSMutableDictionary dictionaryWithCapacity:3];
    [credInfo setObject:username forKey:@"username"];
    [credInfo setObject:email forKey:@"email"];
    [credInfo setObject:password forKey:@"password"];
    
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:2];
    [result setObject:credInfo forKey:@"signup"];
    
    NSString *resultJSON = [result JSONString];
    resultJSON = [NSString stringWithFormat:@"data=%@", resultJSON];        
    return [resultJSON dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSData*)loginDataWithUsername:(NSString*)username password:(NSString*)password role:(BOOL)isMaster {
    
    NSMutableDictionary *credInfo = [NSMutableDictionary dictionaryWithCapacity:3];
    [credInfo setObject:username forKey:@"username"];
    [credInfo setObject:password forKey:@"password"];
    
    
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:2];
    [result setObject:credInfo forKey:@"login"];
    [result setObject:isMaster ? @"master" : @"slave" forKey:@"role"];
    
    NSString *resultJSON = [result JSONString];
    resultJSON = [NSString stringWithFormat:@"data=%@", resultJSON];        
    return [resultJSON dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSData*)mastersListData {
    
    User *user = [DataProvider currentActiveUser];
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:2];
    [result setObject:[user.isMaster boolValue] ? @"master" : @"slave" forKey:@"role"];

    NSString *resultJSON = [result JSONString];
    resultJSON = [NSString stringWithFormat:@"data=%@", resultJSON];        
    return [resultJSON dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSData*)playlistDataForMaster:(Master*)master {
    
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:2];
    [result setObject:@"slave" forKey:@"role"];
    [result setObject:[NSString stringWithFormat:@"%@", master.id] forKey:@"master_id"];
    
    NSString *resultJSON = [result JSONString];
    resultJSON = [NSString stringWithFormat:@"data=%@", resultJSON];        
    return [resultJSON dataUsingEncoding:NSUTF8StringEncoding];
}

//+ (NSData*)mastersListData {
//    
//    User *user = [DataProvider currentActiveUser];
//    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:2];
//    [result setObject:[user.isMaster boolValue] ? @"master" : @"slave" forKey:@"role"];
//    
//    NSString *resultJSON = [result JSONString];
//    resultJSON = [NSString stringWithFormat:@"data=%@", resultJSON];        
//    return [resultJSON dataUsingEncoding:NSUTF8StringEncoding];
//}
@end
