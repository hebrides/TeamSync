//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSCommon.m
// Description		:	TSCommon class Implementation.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import "TSCommon.h"
#import "Reachability.h"

static  BOOL  isOnline = NO;
static  BOOL  isVisible;
static  UIAlertView *_alertView;
static TSNNotificationDisplay *display;

@implementation TSCommon

/***********************************************************************************************
 // Purpose		: A common method for displaying alerts.
 // Parameters	: string aMessage
 // Return type	: data
 // Comments	: nil
 ************************************************************************************************/
+(void) showAlert:(NSString *)aMessage
{
    _alertView  = [[UIAlertView alloc]initWithTitle:APP_NAME  message:aMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil,nil];
    [_alertView show];
}

+(void) hideAlert
{
  	[_alertView dismissWithClickedButtonIndex:0 animated:YES];
    [_alertView removeFromSuperview];
    _alertView = nil;
}

+ (BOOL) doesAlertViewExist
{
    for (UIWindow* window in [UIApplication sharedApplication].windows)
    {
        NSArray* subviews = window.subviews;
        if ([subviews count] > 0)
        {
            BOOL alert = [[subviews objectAtIndex:0] isKindOfClass:[UIAlertView class]];
            //BOOL action = [[subviews objectAtIndex:0] isKindOfClass:[UIActionSheet class]];
            
            if (alert)
            {
                //[[subviews objectAtIndex:0] removeFromSuperview];
                return YES;
            }
        }
    }
    return NO;
}
/********************************************************************************************
 @Method Name  : isEmptyString
 @Param        : text - string to be checked
 @Return       : BOOL
 @Description  : To check if a given string is empty
 ********************************************************************************************/
+ (BOOL)isEmptyString:(NSString *)text
{
	text = [self trimWhiteSpaces:text];
	return (nil == text || YES == [text isEqualToString:@""] || [text length] == 0) ? YES : NO;
}

/********************************************************************************************
 @Method Name  : trimWhiteSpaces
 @Param        : text - string to be trimmed
 @Return       : NSString
 @Description  : To trim the whitespace and new line characters
 ********************************************************************************************/
+ (NSString *)trimWhiteSpaces:(NSString *)text
{
	return [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}


/********************************************************************************************
 @Method Name  : prepareProcessingAlertView
 @Param        : message - text to be shown
 @Return       : UIAlertView
 @Description  : To show the processing alert
 ********************************************************************************************/
+ (UIAlertView *)prepareProcessingAlertView:(NSString *)message
{
	UIAlertView *processingAlertView = [[UIAlertView alloc] initWithTitle:APP_NAME
																  message:message
																 delegate:nil
														cancelButtonTitle:nil
														otherButtonTitles:nil, nil];
    processingAlertView.backgroundColor = [UIColor clearColor];
	[processingAlertView dismissWithClickedButtonIndex:0 animated:YES];
	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	activityIndicator.hidesWhenStopped = YES;
	[activityIndicator setFrame:CGRectMake(120, 88, 37, 37)];
	[activityIndicator startAnimating];
	[processingAlertView addSubview:activityIndicator];
	
	return processingAlertView;
}

+ (BOOL) isNetworkConnected
{
    BOOL status = YES;
    
    BOOL isWiFiConnected = [[Reachability sharedReachability]internetConnectionStatus];
    
    [TSCommon setOnLineStatus:isWiFiConnected];
    
    if(!isWiFiConnected)
    {
        //[TSCommon applicationAlertWithMessage:@"Device is not online." withDelegate:self];
        status = NO;
    }
    
    return status;
}


+ (void)setOnLineStatus:(BOOL)status
{
    isOnline   = status;
}

+ (BOOL)isOnLine
{
    return isOnline;
}

/***********************************************************************************************
 // Purpose		: iphone 5 or not.
 // Parameters	:
 // Return type	: BOOL
 // Comments      :
 ***********************************************************************************************/
+ (BOOL) isRetina4
{
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    return ([UIScreen mainScreen].scale == RETINA_SCALE && screenHeight == RETINA_4_HEIGHT);
}

+ (UIImage *) loadImageResource:(NSString *)imageName
{
    NSString* bareName = [imageName stringByDeletingPathExtension];
    NSString* extention = [imageName pathExtension];
    NSString* newImageName = nil;
    if ([self isRetina4])
    {
        newImageName = [[NSBundle mainBundle] pathForResource:[bareName stringByAppendingFormat:RETINA_4_IMG_FORMAT] ofType:extention];
    }
    else
    {
        newImageName = [[NSBundle mainBundle] pathForResource:bareName ofType:extention];
    }
	UIImage *img        = [UIImage imageWithContentsOfFile:newImageName];
	return img;
}

+ (UIImage *)squareImageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    double ratio;
    double delta;
    CGPoint offset;
    
    //make a new square size, that is the resized imaged width
    CGSize sz = CGSizeMake(newSize.width, newSize.width);
    
    //figure out if the picture is landscape or portrait, then
    //calculate scale factor and offset
    if (image.size.width > image.size.height) {
        ratio = newSize.width / image.size.width;
        delta = (ratio*image.size.width - ratio*image.size.height);
        offset = CGPointMake(delta/2, 0);
    } else {
        ratio = newSize.width / image.size.height;
        delta = (ratio*image.size.height - ratio*image.size.width);
        offset = CGPointMake(0, delta/2);
    }
    
    //make the final clipping rect based on the calculated values
    CGRect clipRect = CGRectMake(-offset.x, -offset.y,
                                 (ratio * image.size.width) + delta,
                                 (ratio * image.size.height) + delta);
    
    
    //start a new context, with scale factor 0.0 so retina displays get
    //high quality image
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(sz, YES, 0.0);
    } else {
        UIGraphicsBeginImageContext(sz);
    }
    UIRectClip(clipRect);
    [image drawInRect:clipRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (void)showProcessViewWithFrame:(CGRect)frame andMessage:(NSString*)message
{
    if(isVisible)
    {
        return;
    }
    
    isVisible   =   TRUE;

    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    display = [[TSNNotificationDisplay alloc] initWithFrame:frame];
    display.type = NotificationDisplayTypeLoading;
    display.tag = NOTIFICATION_DISPLAY_TAG;
    [display displayInView:[UIApplication sharedApplication].keyWindow atCenter:CGPointMake([UIApplication sharedApplication].keyWindow.center.x, [UIApplication sharedApplication].keyWindow.center.y) withInterval:1.5 withMessage:message];
}

+ (void)dismissProcessView
{
    if (!isVisible)
    {
        return;
    }
    if(display)
    {
        [display removeFromSuperview];
        display = nil;
    }
    isVisible = NO;
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}


+(BOOL) validateString:(NSString *)string withStringType:(DATA_TYPE)type
{
    BOOL bReturn = NO;
    
    NSString *theString = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    theString = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    NSCharacterSet * set;
    
    if(type == NAME_DATA_TYPE)
    {
        set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789 '().-,/\n"] invertedSet];
    }
    else if(type == ADDRESS_DATA_TYPE)
    {
        set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789 ‘()'.-/#[]{}|*\\“,\n"] invertedSet];
    }
    else if(type == PHONE_DATA_TYPE)
    {
        set = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789 -()*.+\n"] invertedSet];
    }
    else if(type == ZIP_DATA_TYPE)
    {
        set = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789 -()\n"] invertedSet];
    }
    else if(type == EMAIL_DATA_TYPE)
    {
        set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789 -_@.\n"] invertedSet];
    }
    
    if ([theString rangeOfCharacterFromSet:set].location != NSNotFound)
    {
        bReturn = YES;
    }
    
    return bReturn;
}


@end
