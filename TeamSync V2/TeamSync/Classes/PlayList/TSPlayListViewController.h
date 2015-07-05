//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSPlayListViewController
// Description		:	TSPlayListViewController class Declaration.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "TSSCommunicationManager.h"
#import "TSAppController.h"
#import "TSContactsViewController.h"

@interface TSPlayListViewController : UIViewController 
{
    __weak IBOutlet UITableView     *listTableView;
    __weak IBOutlet UIImageView     *bgImageView;
    TSAppController                 *appController;
    TSContactsViewController        *objContactViewController;
    __weak IBOutlet UIButton        *contactsButton;
}
@property (nonatomic,retain) NSMutableArray *playListNameArray;
@property (nonatomic,retain) NSMutableArray *playListArray;

- (IBAction)onSingOutButtonPressed:(id)sender;
- (IBAction)onInviteClientsButtonPressed:(id)sender;

@end
