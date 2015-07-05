//
//  TracksSearchViewController.h
//  TeamSync
//
//  Created for SMG Mobile on 3/20/12.
//  
//

#import "BaseTableViewController.h"
#import "TrackCell.h"
#import "IPodDataManager.h"

@interface TracksSearchViewController : BaseTableViewController <UISearchBarDelegate, TrackCellDelegate> {
    __strong UISearchBar *searchBar;
}
@property (nonatomic, strong) Playlist *playlist;

@end
