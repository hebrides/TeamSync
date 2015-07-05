//
//  PlaybackViewController.m
//  TeamSync
//
//  Created for SMG Mobile on 26.03.12.
//  
//

#import "PlaybackViewController.h"

@interface PlaybackViewController ()
@property (nonatomic, strong) UINavigationController *nav0;
@property (nonatomic, strong) UINavigationController *nav1;
@property (nonatomic, strong) UINavigationController *nav2;
@property (nonatomic, strong) UINavigationController *currentNav;

@end

@implementation PlaybackViewController
@synthesize master;

@synthesize currentPlaylistVC, chatVC, teamListVC;
@synthesize nav0, nav1, nav2, currentNav;

- (void)dealloc
{
    [scheduleTimer invalidate];
    scheduleTimer = nil;
    
    self.currentPlaylistVC = nil;
    self.chatVC = nil;
    self.teamListVC = nil;
    
    self.nav0 = nil;
    self.nav1 = nil;
    self.nav2 = nil;
}


- (void)disconnect {
    if ([[DataProvider currentActiveUser].isMaster boolValue]) {
        [[PlaybackManager sharedInstance] stopPlaying];
        [[SyncWrapper sharedInstance] sendStopMessage];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[AppServer sharedInstance] removeDelegate:self];
    [[SyncWrapper sharedInstance] performSelector:@selector(stopService) 
                                       withObject:nil afterDelay:1];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)disconnectWithError {
    [[PlaybackManager sharedInstance] stopPlaying];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error connecting to server" 
                                                     message:@"Try later"
                                                    delegate:self 
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self disconnect];
}


- (id)init
{
    self = [super init];
    if (self) {

        self.currentPlaylistVC = [CurrentPlaylistViewController new];
        self.nav0 = [[UINavigationController alloc] initWithRootViewController:self.currentPlaylistVC];
        self.nav0.navigationBarHidden = YES;
        
        self.chatVC = [ChatViewController new];
        self.nav1 = [[UINavigationController alloc] initWithRootViewController:self.chatVC];
        self.nav1.navigationBarHidden = YES;
        
        self.teamListVC = [TeamListViewController new];
        self.nav2 = [[UINavigationController alloc] initWithRootViewController:self.teamListVC];
        self.nav2.navigationBarHidden = YES; 
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UISegmentedControl *_detailSegmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Playlist", @"Chat", @"Team", nil]];
    _detailSegmentedControl.frame = CGRectMake(10.0, 10.0, 300, 32.0);
    _detailSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    _detailSegmentedControl.selectedSegmentIndex = 0;
    _detailSegmentedControl.backgroundColor = [UIColor clearColor];
    _detailSegmentedControl.tintColor = [UIColor darkGrayColor];   
    _detailSegmentedControl.selectedSegmentIndex = 0;
    [_detailSegmentedControl addTarget:self action:@selector(selectScreen:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_detailSegmentedControl];    
    
    
    [self selectScreenAtIndex:0];

    
    UIBarButtonItem *disconnectItem = [[UIBarButtonItem alloc] initWithTitle:@"Disconect" 
                                                                       style:UIBarButtonItemStyleBordered 
                                                                      target:self action:@selector(disconnect)];
    self.navigationItem.leftBarButtonItem = disconnectItem;

    
    if ( ! [[DataProvider currentActiveUser].isMaster boolValue] &&
         ! [SyncWrapper sharedInstance].serviceStarted) {
        [[SyncWrapper sharedInstance] startServiceWithServiseIP:master.ip 
                                                           port:[master.port intValue]];
    }       
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(disconnectWithError) 
                                                 name:SyncNotificationConnectingClosedWithError
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateData {
    if (self.master != nil) {
        if (self.master.playlist == nil) {
            [AppServerHelper updateMaster:self.master playlistWithlistener:self];
            if ([self.navigationItem.title length] == 0) {
                self.navigationItem.title = self.master.login;
            }
        } else {
            if ([self.navigationItem.title isEqualToString:self.master.playlist.title] == NO) {
                self.navigationItem.title = self.master.playlist.title;
            }
            
            self.currentPlaylistVC.playlist = self.master.playlist;
            [self.currentPlaylistVC updateData];
        }
    } else {
        
        if ([self.navigationItem.title isEqualToString:self.currentPlaylistVC.playlist.title] == NO) {
            self.navigationItem.title = self.currentPlaylistVC.playlist.title;
        }
    }
}

#pragma mark - Private methods

- (void)selectScreen:(UISegmentedControl *)segmentedControl {
    [self selectScreenAtIndex:segmentedControl.selectedSegmentIndex];
}

- (void)selectScreenAtIndex:(int)screenIndex {


    [self.currentNav.topViewController viewWillDisappear:NO];
    [self.currentNav.view removeFromSuperview];
    [self.currentNav.topViewController viewDidDisappear:NO];
    
    switch (screenIndex) {
        case 0:
            self.currentNav = self.nav0;
            break;
        case 1:
            self.currentNav = self.nav1;
            break;
        case 2:
            self.currentNav = self.nav2;
            break;
        default:
            break;
    }

    [self.view addSubview:self.currentNav.view];
    [self.currentNav.topViewController viewWillAppear:NO];
    [self.currentNav.topViewController viewDidAppear:NO];
    
    self.currentNav.view.frame = CGRectMake(0, 52, 320, 408); 
 
    if (screenIndex == 0) {
        if ([[DataProvider currentActiveUser].isMaster boolValue]) {
            UIBarButtonItem *timerButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Clockicon.png"] 
                                                                            style:UIBarButtonItemStyleBordered 
                                                                           target:self action:@selector(timerAction:)];
            self.navigationItem.rightBarButtonItem = timerButton;            
        }
        else {
            self.navigationItem.rightBarButtonItem = nil;
        }
    } else if (screenIndex == 1) {
        self.navigationItem.rightBarButtonItem = nil;
//        UIBarButtonItem *voiceButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"microfone.png"] 
//                                                                        style:UIBarButtonItemStyleBordered 
//                                                                       target:self action:@selector(listenVoice:)];
//        self.navigationItem.rightBarButtonItem = voiceButton;            
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }

}

- (void)playTrackByClock {
    scheduleTimer = nil;
    [[SyncWrapper sharedInstance] sendTrackIndex:0];
    [[SyncWrapper sharedInstance] sendPlayMessage];
}

#pragma mark Server
- (void)serverRequest:(ServerRequest)serverRequest didFailWithError:(NSError*)error userInfo:(NSDictionary*)userInfo {
    [super serverRequest:serverRequest didFailWithError:error userInfo:userInfo];
    self.view.userInteractionEnabled = YES;
    self.activityIndicatorVisible = NO;
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error connecting to server" 
                                                     message:@"Try later"
                                                    delegate:self 
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
    [alert show];
}

- (void) serverRequestDidFinish:(ServerRequest)serverRequest 
                         result:(id)result 
                       userInfo:(NSDictionary*)userInfo {
    if (serverRequest == ServerRequestSendPlaylistToStartSession) {
        
        NSString *serviseIP = @"";
        int port = 0;

        //NSLog(@"result class: %@", NSStringFromClass([result class]));
        NSLog(@"result : %@", result);
        
        self.view.userInteractionEnabled = YES;
        self.activityIndicatorVisible = NO;

        if ([result count]) {
            NSDictionary *connectionInfo = [result objectForKey:@"connection"];    
            serviseIP = [connectionInfo objectForKey:@"ip"];
            port = [[connectionInfo objectForKey:@"port"] intValue];
        }  
        
        [[SyncWrapper sharedInstance] startServiceWithServiseIP:serviseIP port:port];   
    }
    
    [self updateData];
}


- (void)timerAction:(UIBarButtonItem *)button {
    
    AppDatePicker *picker = [[AppDatePicker alloc] initWithContentView:self.navigationController.view
                                                              delegate:self];
    [picker show];
}

- (void)appPicketView:(AppDatePicker*)pickerView didSelectedDate:(NSDate*)date {
    [scheduleTimer invalidate];
    NSTimeInterval interval = [date timeIntervalSinceNow];
    scheduleTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(playTrackByClock) userInfo:self repeats:NO];
}

- (void)listenVoice:(UIBarButtonItem *)button {
    
}



@end
