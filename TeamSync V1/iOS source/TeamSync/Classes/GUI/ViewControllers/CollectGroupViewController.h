//
//  CollectGroupViewController.h
//  TeamSync
//
//  Created for SMG Mobile on 3/21/12.
//  
//

#import "BaseTableViewController.h"

@interface CollectGroupViewController : BaseTableViewController

@property (nonatomic, strong) Playlist *playlist;

- (void)updateUserlist;

- (void)startPlyaback;

@end
