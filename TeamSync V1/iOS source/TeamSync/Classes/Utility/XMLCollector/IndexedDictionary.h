
#import <Foundation/Foundation.h>

//NSDictionary
@interface IndexedDictionary : NSObject {
	NSMutableArray * keys;
	NSMutableArray * values;
}

-(NSUInteger)count;
-(id)objectForKey:(id)aKey;
-(id)objectAtIndex:(NSUInteger)index;
-(id)keyAtIndex:(NSUInteger)index;
-(NSInteger)indexOfKey:(NSString *)aKey;
-(void)setObject:(id)anObject forKey:(id)aKey;
-(void)addObject:(id)anObject forKey:(id)aKey;
-(NSArray *)allKeys;

@end

