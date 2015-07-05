//
//  ColorTable.m
//  Dictionary
//
//  Created for SMG Mobile on 12/12/11.
//  
//

#import "ColorTable.h"




@implementation ColorTable

+ (UIColor*)appBarsColor {
    return [UIColor colorWithRed:17.0/255.0 green:17.0/255.0 blue:17.0/255.0 alpha:1];
}
+ (UIColor*)appBlackColor {
    return [UIColor colorWithRed:17.0/255.0 green:17.0/255.0 blue:17.0/255.0 alpha:1];
}

+ (UIColor*)appYellowColor {
    return [UIColor colorWithRed:245.0/255.0 green:246.0/255.0 blue:61.0/255.0 alpha:1];
}

+ (UIColor*)appLightLilacColor {
    return [UIColor colorWithRed:150.0/255.0 green:64.0/255.0 blue:146.0/255.0 alpha:1];
}

+ (UIColor*)appLightSaladColor {
    return [UIColor colorWithRed:0.0/255.0 green:255.0/255.0 blue:93.0/255.0 alpha:1];
}

+ (UIColor*)appLightRedColor {
    return [UIColor colorWithRed:192.0/255.0 green:63.0/255.0 blue:155.0/255.0 alpha:1];
}

+ (UIColor*)appLightGreenColor {
    return [UIColor colorWithRed:115.0/255.0 green:241.0/255.0 blue:196.0/255.0 alpha:1];
}
+ (UIColor*)appLightBlueColor {
    return [UIColor colorWithRed:110.0/255.0 green:246.0/255.0 blue:245.0/255.0 alpha:1];
}

+ (UIColor*)appGrayColor {
    return [UIColor colorWithWhite:0.25 alpha:1];
}

+ (UIColor*)appLightGrayColor {
    return [UIColor colorWithWhite:0.55 alpha:1];
}

+ (UIColor*)appSelectedCellColor {
    return [ColorTable appYellowColor];
}

+ (UIColor*)appTableSeparatorColor {
    return [UIColor colorWithWhite:0.27 alpha:1];
}
@end
