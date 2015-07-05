/////////////////////////////////////////////////////////////////////////////
// File Name        : TSNNotificationDisplay.h
// Description      : TSNNotificationDisplay class declararion
// Author           : Zco Eng
// Copyright        : Zco. All rights reserved 
// Version History  :
//////////////////////////////////////////////////////////////////////////////

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>

#define NOTIFICATION_DISPLAY_TAG 101

typedef enum 
{
  NotificationDisplayTypeText = 0,
  NotificationDisplayTypeLoading = 1
} NotificationDisplayType;

@interface TSNNotificationDisplay : UIView
{
	UILabel *lblDisplay;
	UIActivityIndicatorView *activity;
	NotificationDisplayType type;
}

@property (nonatomic, assign) NotificationDisplayType type;

- (id) initWithFrame:(CGRect)frame;
- (void) setNotificationText:(NSString*) _text;
- (void) displayInView:(UIWindow*) _view atCenter:(CGPoint) _center withInterval:(float) _interval withMessage:(NSString*)message;
- (void) removeNotification;

@end
