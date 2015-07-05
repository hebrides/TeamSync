//
//  CDMigrationTool.h
//  App_iphoneim
//
//  Created for SMG Mobile on 12/22/11.
//  
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CDMigrationTool : NSObject {
    
}

+ (BOOL) migrateDB:(NSURL*) sourceFilePath toURL:(NSURL*) destURL toModel:(NSManagedObjectModel*) finalModel usingModelsDir:(NSString*) modelsDir;
+ (BOOL) DBExistAtURL:(NSURL*) DBPath;
+ (NSURL*) findExistedLatestVersionDBFile;

+ (NSString*) currentVersionForModel:(NSManagedObjectModel*) model;
+ (NSArray*) versionsMappingArray;
+ (NSManagedObjectModel*) createModelWithVersion:(NSString*) version withModelsDir:(NSString*) modelsDir;
+ (NSManagedObjectModel*) createModelNextAfterModel:(NSManagedObjectModel*) sourceModel withModelsDir:(NSString*) modelsDir;
+ (void) deleteFiles:(NSArray*) files;


@end

