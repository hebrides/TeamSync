
#import "NSURL+Common.h"


@implementation NSURL (Common_Private)

- (NSDictionary*) queryParameters {
	NSArray *pairs = [[self query] componentsSeparatedByString:@"&"];
	if ( [pairs count] == 0 ) {
		return [NSDictionary dictionary];
	}
	
	NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:[pairs count] / 2 + 1];
	for (NSString *pair in pairs) {
		NSArray *pairArr = [pair componentsSeparatedByString:@"="];
		if ( [pairArr count] == 2 ) {
			[result setValue:[pairArr objectAtIndex:1]
					  forKey:[pairArr objectAtIndex:0]];
		}
	}
	return result;
}

@end

