//
//  Playlist.h
//  TeamSync
//
//  Created for SMG Mobile on 4/4/12.
//  
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Master, Track, User;

@interface Playlist : NSManagedObject

@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * isIPodOwner;
@property (nonatomic, retain) NSSet *tracks;
@property (nonatomic, retain) Master *master;
@property (nonatomic, retain) User *user;
@end

@interface Playlist (CoreDataGeneratedAccessors)

- (void)addTracksObject:(Track *)value;
- (void)removeTracksObject:(Track *)value;
- (void)addTracks:(NSSet *)values;
- (void)removeTracks:(NSSet *)values;
@end
