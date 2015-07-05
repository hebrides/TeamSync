//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	NSDictionary+TSDeepCopyDictionary.m
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import "NSDictionary+TSDeepCopyDictionary.h"

@implementation NSDictionary (TSDeepCopyDictionary)

-(NSMutableDictionary*)  deepMutableCopy
{
	NSMutableDictionary	*	theDict = [[NSMutableDictionary alloc] init];
	NSEnumerator		*	enny = [self keyEnumerator];
	NSString			*	currKey = nil;
	
	while(( currKey = [enny nextObject] ))
	{
		id	currObj = [self objectForKey: currKey];
		if( [currObj respondsToSelector: @selector(deepCopy)] )
			currObj = [[currObj deepMutableCopy] autorelease];
		else
			currObj = [[currObj mutableCopy] autorelease];
		[theDict setObject: currObj forKey: currKey];
	}
	
	return theDict;
}

@end
