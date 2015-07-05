//
//  Track.h
//  TeamSync
//
//  Created for SMG Mobile on 3/19/12.
//  
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Playlist;

@interface Track : NSManagedObject

@property (nonatomic, retain) NSNumber * length;
@property (nonatomic, retain) NSString * audioUrl;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * artistName;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSDate * releaseDate;
@property (nonatomic, retain) NSString * genreName;
@property (nonatomic, retain) NSNumber * itunesid;
@property (nonatomic, retain) Playlist *playlist;

@end
