//
//  NSManagedObject+Common.m
//  TeamSync
//
//  Created for SMG Mobile on 3/19/12.
//  
//

#import "NSManagedObject+Common.h"

@implementation NSManagedObject (Common_Private)


- (void)deleteObject {
    NSManagedObjectContext *context = self.managedObjectContext;
    [context deleteObject:self];
}
@end
