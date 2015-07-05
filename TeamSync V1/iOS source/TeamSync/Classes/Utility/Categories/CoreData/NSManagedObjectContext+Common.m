
#import "NSManagedObjectContext+Common.h"


@implementation NSManagedObjectContext (Common_Private)

- (void) deleteObjectIfExist:(NSManagedObject *)object {
	if ( object != nil) {
		[self deleteObject:object];
	}
}

@end

