//
//  UIDevice+Common.m
//  App_iphone
//
//  Created for SMG Mobile on 2/23/12.
//  
//

#import "UIDevice+Common.h"
int sysctlbyname(const char *, void *, size_t *, void *, size_t);

@implementation UIDevice (Common_Private)

+ (NSString *)modelIdentifier {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *modelIdentifier = [NSString stringWithCString:machine encoding:NSStringEncodingConversionExternalRepresentation];
    free(machine);
    return modelIdentifier;
} 

+ (NSString *)appleDevice {
    NSString *modelIdentifier = [self modelIdentifier];
    
    if ([modelIdentifier isEqualToString:@"iPad1,1"]) { return @"iPad"; };
    if ([modelIdentifier isEqualToString:@"iPad2,1"]) { return @"iPad 2 (Wi-Fi)"; };
    if ([modelIdentifier isEqualToString:@"iPad2,2"]) { return @"iPad 2 (Wi-Fi/GSM/A-GPS)"; };
    if ([modelIdentifier isEqualToString:@"iPad2,3"]) { return @"iPad 2 (Wi-Fi/CDMA/A-GPS)"; };
    
    if ([modelIdentifier isEqualToString:@"iPhone1,1"])  { return @"iPhone (Original/EDGE)"; };
    if ([modelIdentifier isEqualToString:@"iPhone1,2"])  { return @"iPhone 3G"; };
    if ([modelIdentifier isEqualToString:@"iPhone2,1"])  { return @"iPhone 3GS"; };
    if ([modelIdentifier isEqualToString:@"iPhone1,2*"]) { return @"iPhone 3G (China/No Wi-Fi)"; };
    if ([modelIdentifier isEqualToString:@"iPhone2,1*"]) { return @"iPhone 3GS (China/No Wi-Fi)"; };        
    if ([modelIdentifier isEqualToString:@"iPhone3,1"])  { return @"iPhone 4 (GSM)"; };            
    if ([modelIdentifier isEqualToString:@"iPhone3,3"])  { return @"iPhone 4 (CDMA/Verizon/Sprint)"; };
    if ([modelIdentifier isEqualToString:@"iPhone4,1"])  { return @"iPhone 4S"; };
    
    if ([modelIdentifier isEqualToString:@"iPod1,1"])  { return @"iPod touch (Original)"; };
    if ([modelIdentifier isEqualToString:@"iPod2,1"])  { return @"iPod touch (2nd Gen)"; };
    if ([modelIdentifier isEqualToString:@"iPod3,1"])  { return @"iPod touch (3rd Gen)"; };
    if ([modelIdentifier isEqualToString:@"iPod4,1"])  { return @"iPod touch (4th Gen)"; };
    
    return @"N/A";
}

@end
