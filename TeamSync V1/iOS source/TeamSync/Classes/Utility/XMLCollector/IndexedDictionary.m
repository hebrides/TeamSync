
#import "IndexedDictionary.h"


@implementation IndexedDictionary

-(id)init{
	if (self = [super init]){
		keys = [[NSMutableArray alloc]init];
		values = [[NSMutableArray alloc] init];
	}  
	return self;
}

-(void)dealloc{
	[keys release];
	[values release];
	[super dealloc];
}

-(NSUInteger)count{
	return [keys count];
}

-(id)objectForKey:(id)aKey{
	NSInteger index = [self indexOfKey:aKey];
	if (index != NSNotFound){
		return [values objectAtIndex:index];
	}
	else{
		return nil;
	}
}

-(id)objectAtIndex:(NSUInteger)index{
	return [values objectAtIndex:index];
}

-(id)keyAtIndex:(NSUInteger)index{
	return [keys objectAtIndex:index];
}
-(NSInteger)indexOfKey:(NSString *)aKey{
	for(int i = 0; i < [keys count]; i++){
		if ([aKey isEqualToString:[keys objectAtIndex:i]]){
			return i;
		} 
	}
	return NSNotFound;
}

-(void)setObject:(id)anObject forKey:(id)aKey{
	NSInteger index = [self indexOfKey:aKey];
	if (index != NSNotFound){
		[keys replaceObjectAtIndex:index withObject:aKey];
		[values replaceObjectAtIndex:index withObject:anObject];
	}
	else{
		[self addObject:anObject forKey:aKey];
	}
}

-(void)addObject:(id)anObject forKey:(id)aKey{
	if (anObject != nil && aKey != nil){
		[keys addObject:aKey];
		[values addObject:anObject];
	}
}
- (NSString *)description{
	NSMutableString * result = [NSMutableString stringWithFormat:@"IndexedDictionary[%d]\n", [self count]];
	
	for(int i = 0; i < [self count]; i++){
		[result appendFormat:@"key:%d=%@\nvalue%d=%@\n", i, [[keys objectAtIndex:i]  description], i, [[values objectAtIndex:i] description]];
	}
	
return result;
}

-(NSArray *)allKeys{
	return keys;
}

@end

