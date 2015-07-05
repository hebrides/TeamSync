
#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (Common_Private)

- (void) deleteObjectIfExist:(NSManagedObject *)object;

@end

