//
//  AppDelegate.h
//  TeamSync
//
//  Created for SMG Mobile on 12/16/12.
//  
//


#import <UIKit/UIKit.h>

@class LoginViewController;
@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    
    //LoginViewController *loginVC; // Unused
    __strong UINavigationController *rootNavigationController;
}

@property (strong, nonatomic) UIWindow *window; 
+ (AppDelegate*)sharedAppDelegate;

- (void)loginWithMasterRole:(BOOL)master;
- (void)showLoginScreen;

@end
