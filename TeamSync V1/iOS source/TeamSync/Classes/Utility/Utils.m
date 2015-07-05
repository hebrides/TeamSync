
#import "Utils.h"
#import <QuartzCore/QuartzCore.h>

#import "Managers.h"
#import "CoreDataObjects.h"



@implementation Utils

+(NSString *) docPath {
    NSArray *paths = nil;
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if( paths != nil &&  [paths count] > 0)
    {
        NSString *destinationPath = [paths objectAtIndex:0];
		return destinationPath;
    }
    return nil;
}

+ (BOOL)checkValidateEmail:(NSString*)strEmail{
	if(strEmail == nil || [strEmail length]<5)
		return NO;
	if([strEmail rangeOfString:@"@"].location == NSNotFound || 
	   [strEmail rangeOfString:@"@"].location == 0 ||
	   [strEmail rangeOfString:@"@"].location == [strEmail length]-1 ||
	   [strEmail rangeOfString:@"."].location == NSNotFound ||
	   [strEmail rangeOfString:@"."].location == 0 ||
	   [strEmail rangeOfString:@"."].location == [strEmail length]-1)
		return NO;
	
	NSString *strServer = [strEmail substringFromIndex:[strEmail rangeOfString:@"@"].location+1];
	if([strServer rangeOfString:@"."].location == NSNotFound ||
	   [strServer rangeOfString:@"."].location == [strServer length]-1 ||
	   [strServer rangeOfString:@"."].location == 0 ||
	   [strServer rangeOfString:@"@"].location != NSNotFound)
		return NO;
	
	return YES;
}

+ (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContext(view.frame.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
	
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
	
    UIGraphicsEndImageContext();
	
    return img;
}

+ (void)animateView:(UIView*)view {
    [Utils animateView:view duration:0.3];	
}

+ (void)animateView:(UIView*)view duration:(float)duration {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4) {
        return;
    }

	
	[[view layer] removeAllAnimations];
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[animation setDuration:duration];
	[[view layer] addAnimation:animation forKey:kCATransitionFade];
}
@end

