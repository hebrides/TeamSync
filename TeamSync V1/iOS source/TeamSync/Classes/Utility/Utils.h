
#import <Foundation/Foundation.h>


@interface Utils : NSObject {

}

+ (NSString *) docPath;
+ (BOOL)checkValidateEmail:(NSString*)strEmail;
+ (UIImage *) imageWithView:(UIView *)view;
+ (void)animateView:(UIView*)view duration:(float)duration;
+ (void)animateView:(UIView*)view;

@end

