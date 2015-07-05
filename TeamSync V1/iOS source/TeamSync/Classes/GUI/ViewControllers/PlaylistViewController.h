//
//  PlaylistViewController.h
//  TeamSync
//
//  Created for SMG Mobile on 3/20/12.
//  
//

#import "BaseTableViewController.h"
#import "TrackCell.h"

@interface PlaylistViewController : BaseTableViewController <TrackCellDelegate>

@property (nonatomic, strong) Playlist *playlist;

- (void)addNewTrackAction;

- (void)startAction;

@end
