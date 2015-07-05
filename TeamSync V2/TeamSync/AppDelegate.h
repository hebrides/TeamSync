//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	AppDelegate.h
// Description		:	AppDelegate class Declaration.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import <UIKit/UIKit.h>
#import "TSSCommunicationManager.h"
#import "TSAppConfig.h"

@class TSAppController;
@interface AppDelegate : UIResponder <UIApplicationDelegate, NSNetServiceDelegate>
{
    NSNetService                    *netService;
    TSAppController                 *appController;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSNetService *netService;
@property (readonly) TSAppController *appController;
- (TSAppController *)appController;
@end
