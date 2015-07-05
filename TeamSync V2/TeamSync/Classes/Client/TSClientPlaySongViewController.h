//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSClientPlaySongViewController.h
// Description		:	TSClientPlaySongViewController class Declaration.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MediaPlayer/MPVolumeView.h>
#import "TSRoom.h"
#import "TSRoomDelegate.h"
#import "TSLocalRoom.h"
#import "TSProtocols.h"
#import "TSAppController.h"
#import "TSSCommunicationManager.h"

@interface TSClientPlaySongViewController : UIViewController <TSRoomDelegate, TSClientSongPlayViewControllerDelegate>
{
    __weak IBOutlet UISlider *seekSlider;
    __weak IBOutlet UIImageView *bgImageView;
    __weak IBOutlet UIImageView *artworkImageview;
    __weak IBOutlet UILabel *minLabel;
    __weak IBOutlet UILabel *maxLabel;
    __weak IBOutlet UIImageView *forwardButton;
    __weak IBOutlet UIImageView *backwardButton;
    __weak IBOutlet UIImageView *playButton;
    
    MPMediaItemCollection	*_userMediaItemCollection;
	NSURLConnection         *theConnection;
    TSAppController         *appController;
    TSSCommunicationManager *commManager;
}
@property (weak, nonatomic) IBOutlet UISlider *durationSlider;
@property (weak, nonatomic) IBOutlet UISlider *seekSlider;
@property(nonatomic, readwrite) NSInteger currentItemIndex;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) NSDictionary *infoDict;
@property (nonatomic,retain) MPMediaPlaylist *playListItems;
@property (nonatomic,retain) NSNumber *trackDuration;
@property(nonatomic,retain) TSRoom* chatRoom;
@property(nonatomic,retain) NSString* selectedSongTitle;
@property (retain, nonatomic) NSMutableArray *songNameArray;
@property (retain, nonatomic) NSMutableArray *artistNameArray;

- (IBAction)onDisconnectButtonPressed:(id)sender;

+ (TSClientPlaySongViewController *) sharedInstance;
- (void)activate;
- (void)customizeDurationSlider;
- (id)initWithNibName:(NSString *)nibNameOrNil withSongDetails:(NSDictionary*)dict bundle:(NSBundle *)nibBundleOrNil;
@end
