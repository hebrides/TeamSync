
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>

@interface NSObject (Common)

- (void) printClassHieararhy;

- (void)logProperties;
- (void)logPropertiesSubLevels:(NSInteger)aSubLevels;
- (NSString *)objectStructureInfo:(NSInteger)aLevel;

- (BOOL) isNumber;
- (BOOL) isString;
- (BOOL) isDictionary;
- (BOOL) isArray;
- (BOOL) isDate;
- (BOOL) isData;

+ (void) releaseAndNilPointer:(id*) objectPointer;

@end

