//
//  BaseTableViewController.m
//  TeamSync
//
//  Created for SMG Mobile on 3/20/12.
//  
//

#import "BaseTableViewController.h"

@interface BaseTableViewController ()

@end

@implementation BaseTableViewController
@synthesize tableView, itemsArray;



- (id)init {
	self = [super init];
    if (self) {
		self.itemsArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {

    [super viewDidLoad];
	
	self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
	[self.view addSubview:self.tableView];

    self.tableView.delegate = self; 
	self.tableView.dataSource = self;
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.separatorColor = [UIColor lightGrayColor];
    self.tableView.rowHeight = 47;
    
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
}

- (void)updateData {
    [self.tableView reloadData];
}

#pragma mark Table
- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [table dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.textColor = [UIColor redColor];
        cell.detailTextLabel.textColor = [UIColor redColor];
    }
    
	if ([self.itemsArray count] > indexPath.row) {
		NSString *item = [self.itemsArray objectAtIndex:indexPath.row];
		if ([item isKindOfClass:[NSString class]]) {
			cell.textLabel.text = item;
		}
	}
    return cell;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	return [self.itemsArray count];
}



- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[table deselectRowAtIndexPath:indexPath animated:YES];
}


@end
