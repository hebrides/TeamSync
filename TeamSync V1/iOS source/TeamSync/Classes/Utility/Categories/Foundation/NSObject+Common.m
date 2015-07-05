
#import "NSObject+Common.h"
//#import <objc/message.h>

typedef float (*FloatReturnObjCMsgSendFunction)(id,SEL);
typedef int (*IntReturnObjCMsgSendFunction)(id,SEL);

@implementation NSObject (Common)

- (void) printClassHieararhy {
	Class currentClass = [self class];
	NSString *result = [NSString stringWithFormat:@"Object's [%@] class hierarhy:\n\t", self];
	NSMutableArray *arr = [NSMutableArray arrayWithCapacity:10];
	
	while (currentClass != nil) {
		[arr addObject:currentClass];
		currentClass = [currentClass superclass];
	}
	
	result = [result stringByAppendingString:[arr componentsJoinedByString:@" -> "]];
	NSLog(@"%@", result);
}

- (void)logProperties{
	[self logPropertiesSubLevels:0];
}

- (void)logPropertiesSubLevels:(NSInteger)aSubLevels{
	//id objClass = object_getClass(self);
	id objClass =[self class];
	//id LenderClass = objc_getClass("UITableView");
	unsigned int outCount, i;
	NSString * name, * attributes;
	//NSString Type
	objc_property_t *properties = class_copyPropertyList(objClass, &outCount);
	//NSLog(@"outCount: %d", outCount); /* NSLog( LOG */
	NSLog(@"==========================================================");
	NSLog(@"### Class: %@",NSStringFromClass(objClass));
	NSLog(@"----------------------------------------------------------");
	
	for (i = 0; i < outCount; i++){
		objc_property_t property = properties[i];
		name = [NSString stringWithFormat:@"%s", property_getName(property)];
		attributes = [NSString stringWithFormat:@"%s", property_getAttributes(property)];
		//		NSLog(@"+++ name: %@", name);
		//		NSLog(@"*** attributes: %@", attributes);
		
		SEL propGetSel = NSSelectorFromString(name);
		if ([self respondsToSelector:propGetSel]){
			if ([attributes hasPrefix:@"T@"]){
                id objRes = objc_msgSend(self, (SEL)propGetSel);
				//id objRes = [self performSelector:(SEL)propGetSel];
				NSLog(@">>> id %@ = %@\n", name, objRes);
				if (aSubLevels > 0)
					[objRes logPropertiesSubLevels:aSubLevels - 1];
			}
			else if ([attributes hasPrefix:@"Ti"]){
				int intRes = ((IntReturnObjCMsgSendFunction)objc_msgSend)(self,propGetSel);
				NSLog(@">>> int %@ = %d\n", name, (int)intRes);				
			}
			else if ([attributes hasPrefix:@"Tf"]){
				float floatRes = ((FloatReturnObjCMsgSendFunction)objc_msgSend)(self,propGetSel);
				NSLog(@">>> float %@ = %f",name, (float)floatRes);
			}
			else if ([attributes hasPrefix:@"Tf"]){	
				BOOL boolRes = (BOOL)((IntReturnObjCMsgSendFunction)objc_msgSend)(self,propGetSel);
				NSLog(@">>>  BOOL %@ = %@",name, boolRes ? @"YES" : @"NO");
			}
		}
	}
	NSLog(@"^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");
}

- (NSString *)objectStructureInfo:(NSInteger)aLevel{
	NSMutableString * result;
	if (aLevel){
		id object = self;
		if ([self isArray]){
			
			result = [NSMutableString stringWithFormat:@"Array[%d]{",[object count]];
			for (int i = 0; i < [object count]; i++) {
				[result appendFormat:@"\n%@,", [[object objectAtIndex:i] objectStructureInfo:aLevel - 1]];
			}
			[result appendString:@"\n},"];
			return result;
		}
		else if ([self isDictionary]){
			result =  [NSMutableString stringWithFormat:@"Dictionary(%d keys)",[object count]];
			NSArray * allKeys = [object allKeys];
			for (NSString * key in allKeys) {

				[result appendFormat:@"\n%@=%@,", key, [[object objectForKey:key] objectStructureInfo:aLevel - 1]];
			}
			[result appendString:@"\n},"];
			return result;
		}
		else if ([self isString]){
			return [NSString stringWithFormat:@"String of %d chars",[object length]];
		}
		else {
			return [[object class] description];
		}
	}
	else {
		return @"";
	}
}


- (BOOL) isNumber {
	return [self isKindOfClass:[NSNumber class]];
}

- (BOOL) isString {
	return [self isKindOfClass:[NSString class]];	
}

- (BOOL) isDictionary {
	return [self isKindOfClass:[NSDictionary class]];
}

- (BOOL) isArray {
	return [self isKindOfClass:[NSArray class]];	
}

- (BOOL) isDate {
	return [self isKindOfClass:[NSDate class]];	
}

- (BOOL) isData {
	return [self isKindOfClass:[NSData class]];	
}

+ (void) releaseAndNilPointer:(id*) objectPointer {
	*objectPointer = nil;
}

@end

