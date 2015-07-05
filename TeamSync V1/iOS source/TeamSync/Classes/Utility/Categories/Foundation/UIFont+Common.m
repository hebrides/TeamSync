//
//  UIFont+Common.m
//  App_iphoneim
//
//  Created for SMG Mobile on 12/16/11.
//  
//

#import "UIFont+Common.h"

@implementation UIFont (Common_Private)
+ (UIFont*)appFontOfSize:(CGFloat)fontSize {
    return [UIFont systemFontOfSize:fontSize];
}
+ (UIFont*)boldAppFontOfSize:(CGFloat)fontSize {
    return [UIFont boldSystemFontOfSize:fontSize];
}

//HelveticaNeue

@end
