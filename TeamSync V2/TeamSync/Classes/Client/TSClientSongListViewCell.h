//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSClientSongListViewCell.h
// Description		:	TSClientSongListViewCell class Declaration.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import <UIKit/UIKit.h>
#import "TSProtocols.h"

@interface TSClientSongListViewCell : UITableViewCell
{
    __unsafe_unretained id<TSClientSongListViewCellDelegate> delegate;
}
@property (weak, nonatomic) IBOutlet UILabel *songNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *notAvailableLabel;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UILabel *downloadLabel;
@property (strong, nonatomic) IBOutlet UIImageView *bgImageView;


@property(nonatomic, assign) id<TSClientSongListViewCellDelegate> delegate;

- (IBAction)onDownloadButtonPressed:(id)sender;

@end
