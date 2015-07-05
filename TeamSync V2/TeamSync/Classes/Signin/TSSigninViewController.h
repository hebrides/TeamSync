//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSSigninViewController.h
// Description		:	TSSigninViewController class Declaration.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import <UIKit/UIKit.h>
#import "TSAppConfig.h"
#import "TSServerBrowserDelegate.h"
#import "TSServerBrowser.h"
#import "TSRoom.h"
#import "TSRoomDelegate.h"
#import "TSRemoteRoom.h"
#import "TSContactsViewController.h"

@interface TSSigninViewController : UIViewController <TSServerBrowserDelegate, TSRoomDelegate>
{
    __weak IBOutlet UIImageView         *bgImageView;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIButton *clientButton;
@property (weak, nonatomic) IBOutlet UIButton *masterButton;
@property(nonatomic,retain) TSServerBrowser* serverBrowser;
@property(nonatomic,retain) TSRoom* chatRoom;

- (IBAction)onMasterButtonPressed:(id)sender;
- (IBAction)onClientButtonPressed:(id)sender;
- (IBAction)onEnterPressed:(id)sender;

- (void)didSelectedLogoutButton;
@end
