//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSDeviceListViewController.h
// Description		:	TSDeviceListViewController class Declaration.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <CFNetwork/CFSocketStream.h>
#import "TSServerBrowserDelegate.h"
#import "TSServerBrowser.h"
#import "TSAppConfig.h"
#import "TSRoom.h"
#import "TSRoomDelegate.h"
#import "TSRemoteRoom.h"
#import "TSLocalRoom.h"
#import "TSSCommunicationManager.h"
#import "TSAppController.h"

@class TSClientSongListViewController;
@interface TSDeviceListViewController : UIViewController <NSNetServiceDelegate,NSNetServiceBrowserDelegate,TSServerBrowserDelegate, TSRoomDelegate, TSSCommunicationManagerDelegate>
{
    __weak IBOutlet UILabel     *titleLabel;
    __weak IBOutlet UIImageView *bgImageView;
    NSNetService                *netService;
    NSNetServiceBrowser         *browser;
    NSMutableArray              *services;
    NSMutableArray              *servArr;
    __weak IBOutlet UIButton    *joinButton;
    __weak IBOutlet UIButton    *logoutButton;
    __weak IBOutlet UIButton    *cancelButton;
    __weak IBOutlet UIButton    *doneButton;
    TSRemoteRoom                *room;
    TSLocalRoom                 *roomLoc;
    TSSCommunicationManager     *commManager;
    NSString *selectedMasterName;
    BOOL isConnected;
    __weak IBOutlet UIButton *disconnectbutton;

    TSAppController             *appController;
    
}
@property (weak, nonatomic) IBOutlet UITableView *deviceListTableview;
@property (nonatomic,retain) NSNetServiceBrowser *browser;
@property (nonatomic,retain) NSMutableArray *services;
@property(nonatomic,retain) TSServerBrowser* serverBrowser;
@property(nonatomic,retain) NSMutableArray* selectedDevices;
@property(nonatomic,retain) TSRoom* chatRoom;
@property(nonatomic,assign) NSInteger selectedRowIndex;
@property(nonatomic,assign) BOOL isModifyTableView;


- (IBAction)onCancelButtonPressed:(id)sender;
- (IBAction)onDoneButtonPressed:(id)sender;
- (IBAction)onLogoutButtonPressed:(id)sender;
- (IBAction)onJoinbuttonPressed:(id)sender;
- (IBAction)onDisconnectbuttonPressed:(id)sender;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil modifyTableInteraction:(BOOL)isModify;

@end
