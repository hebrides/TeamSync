//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSAppController.m
// Description		:	TSAppController class Implementation.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import "TSAppController.h"
#import "AppDelegate.h"
#import "TSSplashViewController.h"
#import "TSSigninViewController.h"
#import "TSClientSongListViewController.h"
#import "TSClientPlaySongViewController.h"
#import "TSDeviceListViewController.h"

@interface TSAppController (Private)
- (void)showStatusBar;
- (void)doViewTransitionAnimation;
- (void)showSplashScreen;
- (void)removeSplashScreen;
- (void)checkForSongsinMusicStore;
- (BOOL)checkForSongsinList:(NSDictionary*)details;
@end

@implementation TSAppController
@synthesize applicationWindow;
@synthesize selectedPlayState;
@synthesize selectedVolume;
@synthesize selectedDuration;
@synthesize isBroadcasted;
@synthesize musicSongArray;
@synthesize musicPlayer;
@synthesize isSentInfoOnce;
@synthesize selectedPlayList;
@synthesize yPosPlaylistTable;
@synthesize isCurrentViewLeft;
@synthesize _selectedPlayList;
@synthesize clientCount;
@synthesize deviceTime;
@synthesize connectionTimer;
@synthesize deviceTimeDiff;
@synthesize isCalledSongView;
@synthesize delegate;

#pragma mark -
#pragma mark public methods
#pragma mark -

/********************************************************************************************
 @Method Name  : initWithWindow
 @Param        : window
 @Return       : id
 @Description  : The designated initializer
 ********************************************************************************************/
- (id)initWithWindow:(UIWindow *)window
{
	if (self == [super init])
	{
		applicationWindow               = window;
        self.isBroadcasted              = NO;
        self.isCalledSongView           = NO;
        self.selectedPlayState          = @"";
        self.selectedVolume             = 0.0;
        self.selectedDuration           = @"";
        self.musicPlayer                = nil;
        self.isSentInfoOnce             = NO;
        self.selectedPlayList           = nil;
        self.yPosPlaylistTable          = 0.0;
        self.musicSongArray             = [[NSMutableArray alloc]init];
        
        self.musicPlayer                = nil;
        self.musicPlayer                = [MPMusicPlayerController iPodMusicPlayer];
        [self.musicPlayer setShuffleMode:MPMusicShuffleModeOff];
        [self.musicPlayer setRepeatMode:MPMusicRepeatModeNone];
        self.isCurrentViewLeft          = NO;
        self._selectedPlayList          = @"";
        self.clientCount                = 0;
        self.connectionTimer            = nil;
        self.deviceTime                 = @"";
        self.deviceTimeDiff             = 0;
	}
	
	return self;
}
/********************************************************************************************
 @Method Name  : loadApplication
 @Param        : nil
 @Return       : void
 @Description  : loads the application
 ********************************************************************************************/
- (void)loadApplication
{
    [self showSplashScreen];
	[self performSelector:@selector(loadUI) withObject:nil afterDelay:2.0f];
}

/********************************************************************************************
 @Method Name  : sharedAppController
 @Param        : nil
 @Return       : TSAppController*
 @Description  : appcontroller shared
 ********************************************************************************************/
+ (TSAppController*)sharedAppController
{
	TSAppController *appcontroller;
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    appcontroller  = [(AppDelegate*) appDelegate appController];
    
	return appcontroller;
}

#pragma mark -
#pragma mark private methods
#pragma mark -

/********************************************************************************************
 @Method Name  : loadUI
 @Param        : nil
 @Return       : void
 @Description  : Start the application with Login screen
 ********************************************************************************************/
- (void)loadUI
{
	[self doViewTransitionAnimation];
	[self removeSplashScreen];
    [self showSignInScreen];   
}

/********************************************************************************************
 @Method Name  : showStatusBar
 @Param        : nil
 @Return       : void
 @Description  : Shows the status bar
 ********************************************************************************************/
- (void)showStatusBar
{
	if([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0f)
	{
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
	}
	else
	{
		[UIApplication sharedApplication].statusBarHidden = NO;
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
	}
}

/********************************************************************************************
 @Method Name  : doViewTransitionAnimation
 @Param        : nil
 @Return       : void
 @Description  :
 ********************************************************************************************/
- (void)doViewTransitionAnimation
{
	CATransition *animation = [CATransition animation];
	animation.delegate = self;
	animation.duration = 0.50;
	animation.type = kCATransitionFade;
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	[[applicationWindow layer] addAnimation:animation forKey:@"dissolve"];
}

/********************************************************************************************
 @Method Name  : showSplashScreen
 @Param        : nil
 @Return       : void
 @Description  : Shows the splash screen
 ********************************************************************************************/
- (void)showSplashScreen
{
    [self doViewTransitionAnimation];

    splashViewController = [[TSSplashViewController alloc]
                            initWithNibName:@"TSSplashViewController" bundle:nil];
    
    applicationWindow.rootViewController = splashViewController;
	
}

/********************************************************************************************
 @Method Name  : removeSplashScreen
 @Param        : nil
 @Return       : void
 @Description  : Removes the splash screen
 ********************************************************************************************/
- (void)removeSplashScreen
{
	[splashViewController.view removeFromSuperview];
	splashViewController = nil;
}

/********************************************************************************************
 @Method Name  : showSignInScreen
 @Param        : nil
 @Return       : void
 @Description  : Shows the SignIn screen
 ********************************************************************************************/
- (void)showSignInScreen
{
    [self doViewTransitionAnimation];
    
    signinViewController = [[TSSigninViewController alloc]
                           initWithNibName:@"TSSigninViewController" bundle:nil];
    
    applicationWindow.rootViewController = signinViewController;
	
}

/********************************************************************************************
 @Method Name  : removeSignInScreen
 @Param        : nil
 @Return       : void
 @Description  : Removes the Sign In screen
 ********************************************************************************************/
- (void)removeSignInScreen
{
	[signinViewController.view removeFromSuperview];
	signinViewController = nil;
}


- (void)showClientSongList:(NSDictionary*)details
{
    NSString *_rowIndx = @"-1";
    
    [self removeClientSongDetails];
    if([details objectForKey:SONG_INDEX] && ![[details objectForKey:SONG_INDEX]isEqualToString:@""])
        _rowIndx =  [details objectForKey:SONG_INDEX];
    
    NSLog(@"showClientSongList");
    
    NSInteger _yPos = [[details valueForKey:TABLE_YPOS]integerValue];
    
    if([details objectForKey:@"PlaylistName"])
    {
        if(![self.selectedPlayList isEqualToString:[details objectForKey:@"PlaylistName"]])
        {
            [self removeClientSongList];
        }
    }
    
    NSLog(@"RowIndexxess = %@",_rowIndx);
    if(clientSongListviewcontroller != nil)
    {
        NSString *_broadcastedPlaylist = [details objectForKey:BROADCASTED_PLAYLISTNAME];       
        
        if(![_rowIndx isEqualToString:@""] && ![_rowIndx isEqualToString:@"-1"] && [_broadcastedPlaylist length] > 0 && [_broadcastedPlaylist isEqualToString:[details objectForKey:PLAYLISTNAME]])
        {
            [clientSongListviewcontroller scrollToNewPosition:_rowIndx.integerValue rowIndexExists:YES];
        }
        else
        {
            [clientSongListviewcontroller scrollToNewPosition:_yPos rowIndexExists:NO];
        }
    }
    else
    {
        self.selectedPlayList = [details valueForKey:@"PlaylistName"];
        clientSongListviewcontroller = [[TSClientSongListViewController alloc]initWithNibName:@"TSClientSongListViewController" withDetails:details bundle:nil selectedRowInde:_rowIndx.integerValue];
        
        applicationWindow.rootViewController = clientSongListviewcontroller;
        if([details objectForKey:SONG_INDEX] && ![[details objectForKey:SONG_INDEX]isEqualToString:@""] && ![[details objectForKey:SONG_INDEX]isEqualToString:@"-1"])
        {
            [self checkForSongsinMusicStore];
           [self checkForSongsinList:details];     
        }
    }
}

- (void)resetDurationSliderinClientView
{
    [delegate didResetDurationInMaster];
}

- (void)showClientSongListWithMusic:(NSDictionary*)details
{
    [self removeClientSongDetails];
    
    NSString *_rowIndx =  [details valueForKey:@"SongIndex"];
    
    NSInteger _yPos = [[details valueForKey:TABLE_YPOS]integerValue];
    
    if([details valueForKey:@"PlaylistName"])
    {
        if(![self.selectedPlayList isEqualToString:[details valueForKey:@"PlaylistName"]])
        {
            [self removeClientSongList];
        }
    }
    
    NSLog(@"RowIndexxess = %@",_rowIndx);

    self.selectedPlayList = [details valueForKey:@"PlaylistName"];
    clientSongListviewcontroller = [[TSClientSongListViewController alloc]initWithNibName:@"TSClientSongListViewController" withDetails:details bundle:nil selectedRowInde:_rowIndx.integerValue];
    
    applicationWindow.rootViewController = clientSongListviewcontroller;
    
    if(![_rowIndx isEqualToString:@""])
    {
        [clientSongListviewcontroller scrollToNewPosition:_rowIndx.integerValue rowIndexExists:YES];
    }
    else
    {
        [clientSongListviewcontroller scrollToNewPosition:_yPos rowIndexExists:NO];
    }

    if([details objectForKey:SONG_INDEX] && ![[details objectForKey:SONG_INDEX]isEqualToString:@""])
    {
        [self checkForSongsinMusicStore];
        [self checkForSongsinList:details];
    }

}

- (void)removeClientSongList
{
    if(clientSongListviewcontroller && [clientSongListviewcontroller.view superview])
    {
        [clientSongListviewcontroller.view removeFromSuperview];
        clientSongListviewcontroller = nil;
    }
}


- (void)checkForSongsinMusicStore
{
    MPMediaQuery *playlistsQuery = [MPMediaQuery songsQuery];
    NSArray *playListArray = [playlistsQuery collections];
    
    [self.musicSongArray removeAllObjects];
    for(MPMediaItemCollection *collection in playListArray)
    {
        NSString *_songTitle = [[collection representativeItem] valueForProperty:MPMediaItemPropertyTitle];
        if([_songTitle length] <= 0)
            _songTitle = @"";
        
        [self.musicSongArray addObject:_songTitle];
    }
}

- (void)showClientSongDetails:(NSDictionary*)details
{
    [self checkForSongsinMusicStore];
    
    //else
    if([self checkForSongsinList:details])
    {
        BOOL _IsAlertVisible = [TSCommon doesAlertViewExist];
        
        if(_IsAlertVisible)
            [TSCommon hideAlert];
        
        [self removeClientSongList];
        [self removeClientSongDetails];
        
        clientSongDetailsViewcontroller = [[TSClientPlaySongViewController alloc]initWithNibName:@"TSClientPlaySongViewController" withSongDetails:details bundle:nil];
        
        applicationWindow.rootViewController = clientSongDetailsViewcontroller;
    }
	
}

- (void)removeClientSongDetails
{
    if(clientSongDetailsViewcontroller && [clientSongDetailsViewcontroller.view superview])
    {
        [clientSongDetailsViewcontroller.view removeFromSuperview];
        clientSongDetailsViewcontroller = nil;
    }
}

- (void)changePlayStatebuttonInMaster
{
    [delegate changePlayStateMaster];
}

- (void)changeSongPlayState:(NSDictionary*)detailsDict
{
    self.selectedDuration = [detailsDict objectForKey:PLAY_DURATION];
    self.selectedPlayState = [detailsDict objectForKey:PLAY_STATUS];
    [delegate didChangedPlayStateInMaster];
}

- (void)changeSongVolume:(NSString*)volume
{
    self.selectedVolume = [volume floatValue];
    [delegate didChangedVolumnInMaster];
}

- (void)changeSongDuration:(NSDictionary*)durationDict
{
    self.selectedDuration = [durationDict objectForKey:PLAY_DURATION];
    [delegate didChangedDurationInMaster];
}

- (void)loadSignInScreenOnTermination
{
    [self doViewTransitionAnimation];
    if(deviceListViewcontroller && [deviceListViewcontroller.view superview])
    {
        [deviceListViewcontroller.view removeFromSuperview];
        deviceListViewcontroller = nil;
    }
    [self removeClientSongList];
    [self removeClientSongDetails];
    
    deviceListViewcontroller = [[TSDeviceListViewController alloc]initWithNibName:@"TSDeviceListViewController" bundle:nil modifyTableInteraction:NO];
    
    applicationWindow.rootViewController = deviceListViewcontroller;
}

- (BOOL)checkForSongsinList:(NSDictionary*)details
{
    NSString *_broadcastedPlaylist = [details objectForKey:BROADCASTED_PLAYLISTNAME];
    
    if([_broadcastedPlaylist length] > 0 && [_broadcastedPlaylist isEqualToString:[details objectForKey:PLAYLISTNAME]])
    {
        NSMutableArray *songNameArray = [[NSMutableArray alloc]init];
        
        songNameArray = [details objectForKey:SONG_NAME];
        NSInteger currentItemIndex = [[details objectForKey:SONG_INDEX]integerValue];
        
        NSString *_theSongName = [songNameArray objectAtIndex:currentItemIndex];
        
        NSPredicate *Predicate = [NSPredicate predicateWithFormat:@"SELF == %@",_theSongName];
        NSArray *filtered = [self.musicSongArray filteredArrayUsingPredicate:Predicate];
        
        if([filtered count] <= 0)
        {
            NSString *_StrMessage = [NSString stringWithFormat:@"This song '%@' is not available on your device. Please download it from iTunes.",_theSongName];
            
            BOOL _IsAlertVisible = [TSCommon doesAlertViewExist];
            
            if(_IsAlertVisible)
                [TSCommon hideAlert];
            
            [TSCommon showAlert:_StrMessage];
            if(clientSongListviewcontroller != nil)
            {
                NSInteger songNo = [[details objectForKey:@"SongIndex"] integerValue];
                [clientSongListviewcontroller scrollToNewPosition:songNo rowIndexExists:YES];
            }
            return NO;
        }
    }
    return YES;
}

@end
