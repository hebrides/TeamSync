//
//  AppDelegate.m
//  TeamSync
//
//  Created for SMG Mobile on 12/16/12.
//  
//
 
#import "AppDelegate.h"


#import "LoginViewController.h"
#import "PlaylistsViewController.h"
#import "AddPlaylistViewController.h"
#import "SelectMasterViewControllerViewController.h"
#import "IPodDataManager.h"
#import "DataProvider.h"

//#import "AppServerHelper.h"

@interface AppDelegate ()
@end


@implementation AppDelegate
@synthesize window = _window;

+ (AppDelegate*)sharedAppDelegate {
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // [application setIdleTimerDisabled:YES];
    // [[IPodDataManager sharedInstance] allTracks];    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    
    rootNavigationController = [UINavigationController new];
    rootNavigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    rootNavigationController.navigationBar.translucent = NO;
    self.window.rootViewController = rootNavigationController;
    
    [self showLoginScreen];
    return YES;
}

- (void)showLoginScreen {
//    User *user = [DataProvider currentActiveUser];
//    user.password = nil;
    
    LoginViewController *loginViewController = [LoginViewController new];
    loginViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.window.rootViewController presentViewController: loginViewController
                                                      animated: YES
                                                      completion:NULL];
    // animated: ([rootNavigationController.viewControllers count] > 0)
    
    rootNavigationController.viewControllers = nil; // done with
}

- (void)loginWithMasterRole:(BOOL)master {
    
    if (master == YES) {
        PlaylistsViewController *playlists = [PlaylistsViewController new];
        rootNavigationController.viewControllers = [NSArray arrayWithObject:playlists];
        [rootNavigationController popToRootViewControllerAnimated:YES];
        
//        if ([[DataProvider allPlaylistsForCurrentActiveUser] count] == 0) {
//            AddPlaylistViewController *addPlaylist = [AddPlaylistViewController new];
//            [playlists.navigationController pushViewController:addPlaylist animated:NO];
//        }
        
    } else {
        SelectMasterViewControllerViewController *masterSelect = [SelectMasterViewControllerViewController new];
        rootNavigationController.viewControllers = [NSArray arrayWithObject:masterSelect];
        [rootNavigationController popToRootViewControllerAnimated:NO];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [AppLogicManager closeSession];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[IPodDataManager sharedInstance] updateIPodPlaylists];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [AppLogicManager closeSession];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
