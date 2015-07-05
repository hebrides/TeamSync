
#import "NSArray+Common.h"


@implementation NSArray (Common_1)

- (BOOL) isValidIndex:(NSInteger) index {
	return index >= 0 && index < [self count];
}

- (NSArray*) filteredArrayUsingPredicateFormat:(NSString*) predicateFormat, ... {
	
	va_list list;
	va_start(list, predicateFormat);
	NSArray *filteredArray = [self filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:predicateFormat arguments:list]];
	va_end(list);
	
	return filteredArray;
}

- (id) objectAtIndex:(NSUInteger)index orDefaultObject:(id) defObj {
	return ([self isValidIndex:index]) ? [self objectAtIndex:index] : defObj ;
}

- (id) objectWithKey:(NSString*) key eqealTo:(id) value {
	for (id anObject in self) {
		if ( [[anObject valueForKey:key] isEqual:value] ) {
			return anObject;
		}
	}
	return nil;
}

@end

