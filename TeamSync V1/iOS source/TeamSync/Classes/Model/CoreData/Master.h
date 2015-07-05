//
//  Master.h
//  TeamSync
//
//  Created for SMG Mobile on 4/2/12.
//  
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Playlist;

@interface Master : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * login;
@property (nonatomic, retain) NSString * ip;
@property (nonatomic, retain) NSNumber * port;
@property (nonatomic, retain) Playlist *playlist;

@end
