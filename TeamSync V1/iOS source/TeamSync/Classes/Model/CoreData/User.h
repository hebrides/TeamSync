//
//  User.h
//  TeamSync
//
//  Created for SMG Mobile on 3/28/12.
//  
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Playlist;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * token;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSNumber * isMaster;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSNumber * isActive;
@property (nonatomic, retain) NSSet *playlists;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addPlaylistsObject:(Playlist *)value;
- (void)removePlaylistsObject:(Playlist *)value;
- (void)addPlaylists:(NSSet *)values;
- (void)removePlaylists:(NSSet *)values;
@end
