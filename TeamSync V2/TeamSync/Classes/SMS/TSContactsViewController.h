//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSContactsViewController.h
// Description		:	TSContactsViewController class Declaration.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "TSContactCell.h"
#import "TSCommon.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMessageComposeViewController.h>

@interface TSContactsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>
{
    NSMutableArray *objContactArr;
    NSMutableArray *selectedContactNumber;
}

@property (strong, nonatomic) IBOutlet UIImageView *bgImageView;
@property (strong, nonatomic) IBOutlet UITableView *contactListTableView;
@property(nonatomic,retain) NSMutableArray* selectedIndxPathArr;
- (IBAction)homeButtonPressed:(id)sender;
- (IBAction)sendButtonPressed:(id)sender;

@end
