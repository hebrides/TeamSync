//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSAppController.h
// Description		:	TSAppController class Declaration.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "TSCommon.h"
#import "TSProtocols.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MediaPlayer/MPVolumeView.h>

@class TSSplashViewController;
@class TSSigninViewController;
@class TSClientSongListViewController;
@class TSClientPlaySongViewController;
@class TSDeviceListViewController;
@interface TSAppController : NSObject  
{
    UIWindow                            *applicationWindow;
    TSSplashViewController              *splashViewController;
    TSSigninViewController              *signinViewController;
    TSClientSongListViewController      *clientSongListviewcontroller;
    TSClientPlaySongViewController      *clientSongDetailsViewcontroller;
    TSDeviceListViewController          *deviceListViewcontroller;
    id<TSClientSongPlayViewControllerDelegate> __unsafe_unretained delegate;
}
@property (nonatomic, retain) UIWindow *applicationWindow;
@property (nonatomic)  BOOL    isBroadcasted;
@property (nonatomic, retain)  NSString    *selectedPlayState;
@property (nonatomic)  float selectedVolume;
@property (nonatomic, retain)  NSString    *selectedDuration;
@property (retain, nonatomic) NSMutableArray *musicSongArray;
@property (nonatomic) BOOL isSentInfoOnce;
@property (nonatomic, retain) NSString *selectedPlayList;
@property (nonatomic, assign) NSInteger yPosPlaylistTable;
@property(nonatomic, strong) MPMusicPlayerController *musicPlayer;
@property (nonatomic, assign) NSInteger _currentIndex;
@property (nonatomic) BOOL isCurrentViewLeft;
@property (nonatomic) BOOL isCalledSongView;
@property (nonatomic,retain) NSString *_selectedPlayList;
@property (nonatomic, assign) NSInteger clientCount;
@property(nonatomic, strong) NSTimer  *connectionTimer;
@property(nonatomic, strong) NSString  *deviceTime;
@property(nonatomic, assign) NSTimeInterval deviceTimeDiff;
@property(unsafe_unretained) id<TSClientSongPlayViewControllerDelegate> delegate;

- (id)initWithWindow:(UIWindow *)window;
- (void)loadApplication;
+ (TSAppController*)sharedAppController;
- (void)doViewTransitionAnimation;
- (void)showClientSongList:(NSDictionary*)details;
- (void)showClientSongListWithMusic:(NSDictionary*)details;
- (void)removeClientSongList;
- (void)showClientSongDetails:(NSDictionary*)details;
- (void)removeClientSongDetails;
- (void)changeSongPlayState:(NSDictionary*)detailsDict;
- (void)changeSongVolume:(NSString*)volume;
- (void)changeSongDuration:(NSDictionary*)durationDict;
- (void)loadSignInScreenOnTermination;
- (void)showSignInScreen;
- (void)removeSignInScreen;
- (void)resetDurationSliderinClientView;
- (void)changePlayStatebuttonInMaster;
@end
