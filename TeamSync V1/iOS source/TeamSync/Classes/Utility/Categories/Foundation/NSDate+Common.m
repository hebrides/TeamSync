
#import "NSDate+Common.h"


@implementation NSDate (Common)

- (NSString*) descriptionWithFormat:(NSString*) format {
    return [self descriptionWithFormat:format withLocaleIdentifier:@"en_US"];
}

- (NSString*) descriptionWithFormat:(NSString*) format withLocaleIdentifier:(NSString*) localeID {
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:localeID];
    
	static NSDateFormatter *dateFormatter = nil;
    if ( dateFormatter == nil ) {
        dateFormatter = [[NSDateFormatter alloc] init];
    }

	[dateFormatter setLocale:locale];
	[dateFormatter setDateFormat:format];
	NSString *resultDescription = [dateFormatter stringFromDate:self];
	return resultDescription;
}

+ (NSDate*) dateWithFormat:(NSString*) format fromString:(NSString*) text {
	return [self dateWithFormat:format fromString:text withLocaleIdentifier:@"en_US"];
}

+ (NSDate*) dateWithFormat:(NSString*) format fromString:(NSString*) text withLocaleIdentifier:(NSString*) localeID {
	NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:localeID];
    
    static NSDateFormatter *dateFormatter = nil;
    if ( dateFormatter == nil ) {
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    
	[dateFormatter setLocale:locale];
	[dateFormatter setDateFormat:format];
	NSDate *resultDate = [dateFormatter dateFromString:text];
	return resultDate;
}

- (NSString*) unixTimestamp{
	return [NSString stringWithFormat:@"%d", (int)[self timeIntervalSince1970]];
}

@end

