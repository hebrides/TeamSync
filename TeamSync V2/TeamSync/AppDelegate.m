//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	AppDelegate.m
// Description		:	AppDelegate class Implementation.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import "AppDelegate.h"
#import "TSAppController.h"

@implementation AppDelegate
@synthesize appController;
@synthesize netService;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.netService = [[NSNetService alloc]initWithDomain:@"" type:@"_services._dns-sd._udp" name:@"" port:8085];
    self.netService.delegate = self;
    [self.netService publish];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    appController = [[TSAppController alloc]initWithWindow:self.window];
    [appController loadApplication];

    [self.window makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    if(musicPlayer.playbackState == MPMusicPlaybackStatePlaying)
    {
        
    }
    else
    {
        if([[TSAppConfig getInstance].type isEqualToString:@"Master"])
        {
            [musicPlayer pause];
            [appController changePlayStatebuttonInMaster];
            
            double interval = appController.musicPlayer.currentPlaybackTime;
            NSString *intervalString = [NSString stringWithFormat:@"%f", interval];
            NSDictionary *informationDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Pause", PLAY_STATUS, intervalString, PLAY_DURATION, nil];
            
            TSSCommunicationManager *commManager = [TSSCommunicationManager sharedInstance];
            [commManager.chatRoom broadcastChatMessage:@"" andDetails:informationDict fromUser:[TSAppConfig getInstance].name selectedView:kSongStateChanges];
        }
    }
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    if(musicPlayer.playbackState == MPMusicPlaybackStatePlaying)
    {
        
    }
    else
    {
        if([[TSAppConfig getInstance].type isEqualToString:@"Master"])
        {
            [musicPlayer pause];
            [appController changePlayStatebuttonInMaster];
            
            double interval = appController.musicPlayer.currentPlaybackTime;
            NSString *intervalString = [NSString stringWithFormat:@"%f", interval];
            NSDictionary *informationDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Pause", PLAY_STATUS, intervalString, PLAY_DURATION, nil];
            
            TSSCommunicationManager *commManager = [TSSCommunicationManager sharedInstance];
            [commManager.chatRoom broadcastChatMessage:@"" andDetails:informationDict fromUser:[TSAppConfig getInstance].name selectedView:kSongStateChanges];
        }
    }
    
    __block UIBackgroundTaskIdentifier backgroundTask; //Create a task object
    
    backgroundTask = [application beginBackgroundTaskWithExpirationHandler: ^ {
    }];
    
    dispatch_queue_t opQ = dispatch_queue_create("com.myapp.network", NULL);
    dispatch_async(opQ, ^{
        TSAppConfig *objConfig = [TSAppConfig getInstance];
        objConfig.isEnteredBackGround = YES;

    });
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    TSAppConfig *objConfig = [TSAppConfig getInstance];
    objConfig.isEnteredBackGround = NO;
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    if(musicPlayer.playbackState == MPMusicPlaybackStatePlaying)
        [musicPlayer pause];

    [self.netService stop];
    
    if (appController.connectionTimer)
    {
		[appController.connectionTimer invalidate];
		appController.connectionTimer = nil;
    }

    
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict
{
    NSLog(@"Testing");
}

@end
