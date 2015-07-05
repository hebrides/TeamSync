//
//  CurrentPlaylistViewController.h
//  TeamSync
//
//  Created for SMG Mobile on 27.03.12.
//  
//

#import "BaseTableViewController.h"
#import "TrackCell.h"


@interface CurrentPlaylistViewController : BaseTableViewController <TrackCellDelegate> {
    NSInteger currentTrackIndex;
}
@property (nonatomic, strong) Playlist *playlist;
@property (nonatomic, readonly) NSInteger currentTrackIndex;

- (void)updateNavigationButtons;

@end
