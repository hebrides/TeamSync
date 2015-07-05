//
//  DataManager.m
//  App_iphoneim
//
//  Created for SMG Mobile on 12/22/11.
//  
//

#import "DataManager.h"
#import "CDMigrationTool.h"

static NSString *const kCoreDataStoreFileName = @"model-v1.0.sqlite";

static id __sharedInstance;

@implementation DataManager

@dynamic managedObjectModel;
@dynamic managedObjectContext;
@dynamic persistentStoreCoordinator;
@dynamic applicationDocumentsDirectory;

#pragma mark 
#pragma mark Singleton methods >>>

+ (DataManager*) sharedInstance {
	
	@synchronized(self) {
		if (__sharedInstance == nil) {
			[[self alloc] init]; // assignment not done here
		}
    }
	
    return __sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
	
    @synchronized(self) {
        if (__sharedInstance == nil) {
            __sharedInstance = [super allocWithZone:zone];
            return __sharedInstance;  // assignment and return on first allocation
        }
    }
	
    return nil; //on subsequent allocation attempts return nil
	
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}


- (id)retain {
    return self;
}


- (unsigned)retainCount {
    return UINT_MAX;  //denotes an object that cannot be released
}

- (oneway void)release {
    //do nothing
}


- (id)autorelease {
    return self;
}


#pragma mark -
#pragma mark Custom selects
- (NSArray*)getObjectsForName:(NSString*)name sortDescriptorsKey:(NSString*)sortKey ascending:(BOOL)ascending{
	NSFetchRequest *req = [[NSFetchRequest alloc] init];
	if ([sortKey length] > 0) {
		NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
		[req setSortDescriptors:[NSArray arrayWithObject:sorter]];
		[sorter release];
	}
	
	[req setEntity:[NSEntityDescription entityForName:name inManagedObjectContext:self.managedObjectContext]];
	NSArray *res = [self.managedObjectContext executeFetchRequest:req error:nil];
	[req release];
	return res;	
}


- (NSArray*)getObjectsForName:(NSString*)name sortDescriptorsKey:(NSString*)sortKey{
	return [self getObjectsForName:name sortDescriptorsKey:sortKey ascending:YES];
}




#pragma mark -
#pragma mark Core Data accessors

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
	if (managedObjectModel != nil) {
        return managedObjectModel;
    }
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"AppModel" ofType:@"momd"];
    NSURL *momURL = [NSURL fileURLWithPath:path];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
	
    return managedObjectModel;
	
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
	NSString *path = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:kCoreDataStoreFileName];
    NSURL *storeUrl = [NSURL fileURLWithPath:path];
	NSError *error = nil;
	persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
	
	if ( [CDMigrationTool DBExistAtURL:storeUrl] ) {
		
		NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
																								  URL:storeUrl
																								error:&error];
		
		if ( ![self.managedObjectModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata] ) {
			NSLog(@"CDDB exists but  NOT Compatible. Can't continue");
			[persistentStoreCoordinator release];
			persistentStoreCoordinator = nil;
		} else {
			if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
				NSLog(@"Can't add persistant store: %@ \nwith path:[%@]", [error description], storeUrl);
				[persistentStoreCoordinator release];
				persistentStoreCoordinator = nil;
			} 
		}
	} else {
		
		NSURL *oldVersionDBFile = [CDMigrationTool findExistedLatestVersionDBFile];
		if ( oldVersionDBFile == nil ) {
			if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
				NSLog(@"Can't create persistant store: %@ \nwith path:[%@]", [error description], storeUrl);
			} 
		} else {
            
			BOOL migrated = [CDMigrationTool migrateDB:oldVersionDBFile toURL:storeUrl toModel:self.managedObjectModel usingModelsDir:[[NSBundle mainBundle] pathForResource:@"AppModel" ofType:@"momd"]];
            
			NSLog(@"Migrated %@succesfull", (migrated) ? @" " : @"NOT ");
			
			if ( [[persistentStoreCoordinator persistentStores] count] == 0 && [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error] == nil) {
				NSLog(@"Can't create persistant store: %@ \nwith path:[%@]", [error description], storeUrl);
				[persistentStoreCoordinator release];
				persistentStoreCoordinator = nil;
			}
		}
	}
    
    return persistentStoreCoordinator;
}

- (id) findOrCreateManagedObjectFromEntity:(NSString*) entityName withPredicate:(NSPredicate*) predicate {
	NSFetchRequest *req = [[NSFetchRequest alloc] init];
	[req setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:self.managedObjectContext]];
	if (predicate != nil) {
		[req setPredicate:predicate];
	}
	
	
	NSArray *res = [self.managedObjectContext executeFetchRequest:req error:nil];
	[req release];
	
	NSManagedObject *resultObject = nil;
	if ( [res count] > 0 ) {
		resultObject = [res objectAtIndex:0];
	} else {
		resultObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.managedObjectContext];
	}	
	
	return resultObject;
}

#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}




#pragma mark -
#pragma mark Public 

- (NSError*) save {
	NSError *saveError = nil;
	[managedObjectContext save:&saveError];
    
	if ( saveError ){
		NSLog(@"CoreData save ERROR: %@", saveError);
	}
	return saveError;
}

- (BOOL)hasChanges {
	return [managedObjectContext hasChanges];
}

- (void)revertChanges {
	[managedObjectContext rollback];
}
@end