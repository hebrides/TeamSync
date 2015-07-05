//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSClientSongListViewController.h
// Description		:	TSClientSongListViewController class Declaration.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "TSProtocols.h"
#import "TSSCommunicationManager.h"
#import "TSAppController.h"

@interface TSClientSongListViewController : UIViewController <NSXMLParserDelegate, TSClientSongListViewCellDelegate>
{
    __weak IBOutlet UILabel     *titleLabel;
    TSSCommunicationManager     *commManager;
    TSAppController             *appController;
    __weak IBOutlet UIImageView *bgImageView;
     NSInteger                  selectedRow;
}
@property (weak, nonatomic) IBOutlet UITableView *listTableView;
@property (retain, nonatomic)NSMutableArray *songNamesArray;
@property (retain, nonatomic)NSMutableArray *composerNameArray;
@property (retain, nonatomic)NSMutableArray *musicSongArray;
@property (strong, readonly, nonatomic) NSOperationQueue* operationQueue;
@property (nonatomic) BOOL searching;
@property (retain, nonatomic) NSDictionary *infoDict;
@property (nonatomic,assign) NSInteger indxRow;
@property (nonatomic,assign) NSInteger yPos;

- (IBAction)onDisconnectButtonPressed:(id)sender;

- (void)onBackButtonPressed;
- (id)initWithNibName:(NSString *)nibNameOrNil withDetails:(NSDictionary*)songDict bundle:(NSBundle *)nibBundleOrNil selectedRowInde:(NSInteger)selRow;
- (void) scrollToNewPosition:(NSInteger) indexValue rowIndexExists:(BOOL) isExists;
@end
