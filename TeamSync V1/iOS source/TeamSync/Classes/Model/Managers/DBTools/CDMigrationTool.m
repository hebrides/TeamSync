//
//  CDMigrationTool.m
//  App_iphoneim
//
//  Created for SMG Mobile on 12/22/11.
//  
//


#import "CDMigrationTool.h"

static NSString *const kMappingConfigFile	= @"MappingConfig.plist";
static NSString *const kVersionsFile		= @"CDDBFileVersions.plist";


@implementation CDMigrationTool

+ (BOOL) migrateDB:(NSURL*) sourceFilePath toURL:(NSURL*) destURL toModel:(NSManagedObjectModel*) finalModel usingModelsDir:(NSString*) modelsDir {
    
	NSError *error = nil;
	NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
																							  URL:sourceFilePath
																							error:&error];
	if ( sourceMetadata == nil ) {
		NSLog(@"Can't get DB metadata: %@", error);
		return NO;
	}
    
	NSManagedObjectModel *sourceModel = [NSManagedObjectModel mergedModelFromBundles:nil
																	forStoreMetadata:sourceMetadata];
	
	NSString *sourceModelVersion = [self currentVersionForModel:sourceModel];
	if ( [sourceModelVersion length] == 0 ) {
		sourceModelVersion = [[self versionsMappingArray] objectAtIndex:0];
	}
	NSString *finalModelVersion = [self currentVersionForModel:finalModel];	
	
	if ( [sourceModelVersion isEqualToString:finalModelVersion] ) {
		return NO;
	}
	
	NSManagedObjectModel *fromModel = [sourceModel retain];
	NSManagedObjectModel *toModel = [self createModelNextAfterModel:sourceModel withModelsDir:modelsDir];	
	
	NSURL *migrationSourceURL = sourceFilePath;
	NSURL *migrationDestinationURL = nil;
	NSMutableArray *migratedFiles = [NSMutableArray array];
	
	while ( ![fromModel isEqual:toModel] && toModel != nil ) {
		NSMigrationManager *migrationManager = [[NSMigrationManager alloc] initWithSourceModel:fromModel
																			  destinationModel:toModel];						
		
		NSMappingModel *mappingModel = [NSMappingModel mappingModelFromBundles:nil 
																forSourceModel:fromModel
															  destinationModel:toModel];
		
		migrationDestinationURL = [NSURL fileURLWithPath:[[migrationSourceURL path] stringByAppendingString:@"-migrated"]];
		[migratedFiles addObject:migrationDestinationURL];
		
		BOOL ok = [migrationManager migrateStoreFromURL:migrationSourceURL
												   type:NSSQLiteStoreType
												options:nil
									   withMappingModel:mappingModel
									   toDestinationURL:migrationDestinationURL
										destinationType:NSSQLiteStoreType
									 destinationOptions:nil
												  error:&error];
		
		[migrationManager release];
        
		if ( ok ) {
			NSLog(@"Migration successfull [%@]->[%@]", [self currentVersionForModel:fromModel], [self currentVersionForModel:toModel]);
			
			migrationSourceURL = migrationDestinationURL;
			[fromModel release];
			fromModel = toModel;
			toModel = [self createModelNextAfterModel:toModel withModelsDir:modelsDir]; 
			
			NSLog(@"Next Migration [%@]->[%@]", [self currentVersionForModel:fromModel], [self currentVersionForModel:toModel]);
		} else {
			NSLog(@"Migration failed:\n%@ - %@", error, [error localizedFailureReason]);
			[fromModel release];
			[toModel release];
			[self deleteFiles:migratedFiles];
			return NO;
		}
	}
	
	[fromModel release];
	[toModel release];
    
    //	[[NSFileManager defaultManager] moveItemAtPath:[sourceFilePath path]
    //											toPath:[[sourceFilePath path] stringByAppendingString:@"-backup"]
    //											 error:nil];
	
    
	
	
	[[NSFileManager defaultManager] moveItemAtPath:[migrationDestinationURL path]
											toPath:[destURL path]
											 error:nil];
	
    //	BOOL metadataUpdated = [NSPersistentStoreCoordinator setMetadata:destinationMetadata
    //											forPersistentStoreOfType:NSSQLiteStoreType
    //																 URL:sourceFilePath
    //															   error:&error];
	
    //	if ( !metadataUpdated ) {
    //		NSLog(@"Metadata of store not updated: %@", error);
    //	}
	
	NSDictionary *destinationMetadata = [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType
																								   URL:destURL
																								 error:&error];
    
	if ( ![finalModel isConfiguration:nil compatibleWithStoreMetadata:destinationMetadata] ) {
		NSLog(@"NOT Compatible: %@", error);
	}
    
	[self deleteFiles:migratedFiles];
    
	return YES;
}

+ (NSString*) currentVersionForModel:(NSManagedObjectModel*) model {
	NSArray *sortedVersionsInfo = [[[model versionIdentifiers] allObjects] sortedArrayUsingSelector:@selector(compareNumbers:)];
	return [sortedVersionsInfo lastObject];
}

+ (NSArray*) versionsMappingArray {
	static NSArray *mappingArray = nil;
	if ( mappingArray == nil ) {
		mappingArray = [[NSArray alloc] initWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:kMappingConfigFile]];
	}
	
	return mappingArray;
}

+ (NSManagedObjectModel*) createModelWithVersion:(NSString*) version withModelsDir:(NSString*) modelsDir {
	NSString *path = [NSString stringWithString:modelsDir];
	path = [path stringByAppendingPathComponent:[version stringByAppendingPathExtension:@"mom"]];
	NSURL *momURL = [NSURL fileURLWithPath:path];
	
	return [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
}

+ (NSManagedObjectModel*) createModelNextAfterModel:(NSManagedObjectModel*) sourceModel withModelsDir:(NSString*) modelsDir {
    
	NSString *sourceModelVersion = [self currentVersionForModel:sourceModel];
	if ( [sourceModelVersion length] == 0 ) {
		sourceModelVersion = [[self versionsMappingArray] objectAtIndex:0];
	}
	NSArray *mappingArray = [self versionsMappingArray];
	if ( [sourceModelVersion isEqualToString:[mappingArray lastObject]] ) {
		return nil;
	}
	
	NSString *nextModelVersion = [mappingArray objectAtIndex:[mappingArray indexOfObject:sourceModelVersion] + 1];
	return [self createModelWithVersion:nextModelVersion withModelsDir:modelsDir];
}

+ (void) deleteFiles:(NSArray*) files {
	for (NSURL *file in files) {
		[[NSFileManager defaultManager] removeItemAtPath:[file path] error:nil];
	}
}

+ (BOOL) DBExistAtURL:(NSURL*) DBPath {
	return [[NSFileManager defaultManager] fileExistsAtPath:[DBPath path]];
}

+ (NSURL*) findExistedLatestVersionDBFile {
	NSArray *DBFileList = [NSArray arrayWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:kVersionsFile]];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
	if ( docDir == nil ) {
		return nil;
	}
	
	for (NSInteger i = [DBFileList count] - 1; i >= 0; i--) {
		NSURL *DBPathURL = [NSURL fileURLWithPath:[docDir stringByAppendingPathComponent:[DBFileList objectAtIndex:i]]];
		if ( [self DBExistAtURL:DBPathURL] ) {
			return DBPathURL;
		}
	}
	return nil;
}

@end

