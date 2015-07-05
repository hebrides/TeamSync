
#import <Foundation/Foundation.h>


@interface NSString (Common)

+ (id)stringWithUUID;
- (NSString *)stringWithBundlePath;
+ (id)pathToBundleFile:(NSString *)aFileName;
+ (id)stringFromBundleFile:(NSString *)aFileName;
- (BOOL)isNotEmpty;
- (BOOL)isEmpty;
+ (NSString *) base64StringFromData:(NSData*)data;

#ifdef __IPHONE_3_0
- (BOOL) isValidEmail;
#endif

- (NSComparisonResult) compareNumbers:(NSString*) right;

@end

