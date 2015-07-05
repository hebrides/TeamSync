
#import <Foundation/Foundation.h>


@interface NSArray (Common_1) 

- (BOOL) isValidIndex:(NSInteger) index;
- (NSArray*) filteredArrayUsingPredicateFormat:(NSString*) predicateFormat, ...;
- (id)objectAtIndex:(NSUInteger)index orDefaultObject:(id) defObj;
- (id)objectWithKey:(NSString*) key eqealTo:(id) value;

@end

