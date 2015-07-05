//
//  BaseTableViewController.h
//  TeamSync
//
//  Created for SMG Mobile on 3/20/12.
//  
//

#import "BaseViewController.h"


@interface BaseTableViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource> {
	
}
@property (strong, nonatomic) NSMutableArray *itemsArray;
@property (strong, nonatomic) UITableView *tableView;

@end