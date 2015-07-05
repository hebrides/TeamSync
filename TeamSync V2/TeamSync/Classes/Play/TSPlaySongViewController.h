//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSPlaySongViewController
// Description		:	TSPlaySongViewController class Declaration.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MediaPlayer/MPVolumeView.h>
#import "TSRoom.h"
#import "TSRoomDelegate.h"
#import "TSLocalRoom.h"
#import "TSAppController.h"
#import "TSSCommunicationManager.h"
#import "TSProtocols.h"

@interface TSPlaySongViewController : UIViewController <TSRoomDelegate, TSSCommunicationManagerDelegate, TSSongPlayViewControllerDelegate, TSClientSongPlayViewControllerDelegate>
{
    __weak IBOutlet UIButton *backwardButton;
    __weak IBOutlet UIButton *forwardButton;
    __weak IBOutlet UIButton *playButton;
    __weak IBOutlet UISlider *seekSlider;
    __weak IBOutlet UIImageView *bgImageView;
    __weak IBOutlet UIImageView *artworkImageview;
    __weak IBOutlet UILabel *minLabel;
    __weak IBOutlet UILabel *maxLabel;
    __weak IBOutlet UIView *holderView;

    MPMediaItemCollection	*_userMediaItemCollection;
	NSURLConnection *theConnection;
    TSAppController         *appController;
    TSSCommunicationManager *commManager;
    NSInteger yAxis;
    __weak IBOutlet UIButton *disconnectButton;
}
@property (weak, nonatomic) IBOutlet UIButton *backwardButton;
@property (weak, nonatomic) IBOutlet UIButton *forwardButton;
@property (weak, nonatomic) IBOutlet UISlider *durationSlider;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UISlider *seekSlider;
@property(nonatomic, readwrite) NSInteger currentItemIndex;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) NSMutableDictionary *infoDict;
@property (nonatomic,retain) MPMediaPlaylist *playListItems;
@property (nonatomic,retain) NSNumber *trackDuration;
@property(nonatomic,retain) TSRoom* chatRoom;
@property (nonatomic,retain) NSMutableArray *songNameArray;
@property (nonatomic,retain) NSMutableArray *composerNameArray;
@property (retain, nonatomic) NSMutableDictionary *songDict;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic, weak) NSString *playListName;
@property (nonatomic, weak) NSString *tableYPosition;
@property (nonatomic) BOOL isCalledNotification;
@property (nonatomic) BOOL isFromListView;

- (IBAction)onDurationSliderChanged:(id)sender;
- (IBAction)onseekSliderClicked:(id)sender;
- (IBAction)onPlayButtonClicked:(id)sender;
- (IBAction)onBackButtonPressed:(id)sender;
- (IBAction)onDisconnectButtonPressed:(id)sender;
- (IBAction)onNextTrackButtonPressed:(id)sender;
- (IBAction)onPreviousTrackPressed:(id)sender;

+ (TSPlaySongViewController *) sharedInstance;
- (void)activate;

- (id)initWithNibName:(NSString *)nibNameOrNil withSongDetails:(NSDictionary*)dict bundle:(NSBundle *)nibBundleOrNil;
@end
