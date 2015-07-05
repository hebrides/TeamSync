
#import <Foundation/Foundation.h>


@interface NSDate (Common)

- (NSString*) descriptionWithFormat:(NSString*) format;
- (NSString*) descriptionWithFormat:(NSString*) format withLocaleIdentifier:(NSString*) localeID;
+ (NSDate*) dateWithFormat:(NSString*) format fromString:(NSString*) text;
+ (NSDate*) dateWithFormat:(NSString*) format fromString:(NSString*) text withLocaleIdentifier:(NSString*) localeID;
- (NSString*) unixTimestamp;

@end

