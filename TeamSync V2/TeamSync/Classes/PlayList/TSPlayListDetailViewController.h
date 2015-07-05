//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSPlayListDetailViewController.h
// Description		:	TSPlayListDetailViewController class Declaration.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "TSAppController.h"
#import "TSProtocols.h"

@interface TSPlayListDetailViewController : UIViewController<UIScrollViewDelegate>
{
    __weak IBOutlet UIImageView     *bgImageView;
    __weak IBOutlet UILabel         *titleLabel;
    __weak IBOutlet UIButton        *disconnectButton;
    
    __weak IBOutlet UIButton        *broadcastButton;
    __weak IBOutlet UILabel         *broadcastLabel;
    TSAppController                 *appController;
    NSInteger indxPthRow;
    NSInteger selectedRow;
    
    id<TSSongPlayViewControllerDelegate> __unsafe_unretained delegate;
}
@property(unsafe_unretained) id<TSSongPlayViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *songListTableView;
@property (strong, nonatomic) NSDictionary *infoDict;
@property (nonatomic,retain) MPMediaPlaylist *playListItems;
@property (retain, nonatomic) NSDictionary *songInfoDict;
@property (retain, nonatomic) NSMutableArray *songNameArray;
@property (retain, nonatomic) NSMutableArray *composerNameArray;
@property (retain, nonatomic) NSMutableDictionary *songDict;
@property (nonatomic) NSInteger tableYPosition;

- (IBAction)onBroadcastButtonPressed:(id)sender;
- (IBAction)onDisconnectButtonPressed:(id)sender;
- (IBAction)onBackButtonPressed:(id)sender;

- (void)sendPlayListDetails:(BOOL) isScrolling;
- (id)initWithNibName:(NSString *)nibNameOrNil andDetails:(NSDictionary*)dict bundle:(NSBundle *)nibBundleOrNil ;
@end
