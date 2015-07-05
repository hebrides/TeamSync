//
//  DataManager.h
//  App_iphoneim
//
//  Created for SMG Mobile on 12/22/11.
//  
//


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DataManager : NSObject  {
    
	//! DataCore object model 
	NSManagedObjectModel *managedObjectModel;
	
	//! DataCore object context
	NSManagedObjectContext *managedObjectContext;	    
	
	//! DataCore coordinator
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

@property (nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;

+ (DataManager*) sharedInstance;

- (NSError*) save;
- (BOOL)hasChanges;
- (void)revertChanges;

- (id)findOrCreateManagedObjectFromEntity:(NSString*)entityName withPredicate:(NSPredicate*)predicate;


- (NSArray*)getObjectsForName:(NSString*)name sortDescriptorsKey:(NSString*)sortKey;
- (NSArray*)getObjectsForName:(NSString*)name sortDescriptorsKey:(NSString*)sortKey ascending:(BOOL)ascending;

@end