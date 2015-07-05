//
//  SelectMasterViewControllerViewController.m
//  TeamSync
//
//  Created for SMG Mobile on 3/26/12.
//  
//

#import "SelectMasterViewControllerViewController.h"
#import "LoginViewController.h"
#import "AppDelegate.h"
#import "PlaybackViewController.h"

@interface SelectMasterViewControllerViewController ()
- (void)updateMasters;
@end

@implementation SelectMasterViewControllerViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Select Master";

    UIBarButtonItem *logoutButtonItem;
    logoutButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Log out" 
                                                        style:UIBarButtonItemStyleBordered 
                                                       target:self 
                                                       action:@selector(logoutAction)];
    self.navigationItem.leftBarButtonItem = logoutButtonItem;
    
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 372, 320, 44)];
    bottomBorder.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
    [self.view addSubview:bottomBorder];
    
    UIButton *collectGroup = [UIButton buttonWithType:UIButtonTypeCustom];
    [collectGroup setBackgroundImage:[UIImage imageNamed:@"buttonUnpressed.png"] forState:UIControlStateNormal];
    [collectGroup addTarget:self action:@selector(updateMasters) forControlEvents:UIControlEventTouchUpInside];
    [collectGroup setTitle:@"Update" forState:UIControlStateNormal];
    collectGroup.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    [collectGroup setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.5f] forState:UIControlStateDisabled];
    collectGroup.frame = CGRectMake(6, 378, 308, 32);    
    [self.view addSubview:collectGroup];    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    
    [self updateMasters];
}



- (void)logoutAction {
    [[PlaybackManager sharedInstance] stopPlaying];
    [[AppDelegate sharedAppDelegate] showLoginScreen];    
}

- (void)joinAction {
    
    Master *master = [self.itemsArray objectAtIndex:currentSelectedMaster];    
    PlaybackViewController *viewController = [PlaybackViewController new];
    viewController.master = master;
    [self.navigationController pushViewController:viewController animated:YES];    
}

- (void)updateData {
    currentSelectedMaster = NSNotFound;
    self.navigationItem.rightBarButtonItem = nil;
    [self.itemsArray removeAllObjects];
    [self.itemsArray addObjectsFromArray:[DataProvider allMasters]];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:table cellForRowAtIndexPath:indexPath];
    
    Master *master = [self.itemsArray objectAtIndex:indexPath.row];
        
    cell.textLabel.text = master.login;
      
    if (indexPath.row == currentSelectedMaster) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark.png"]];
    } else {
        cell.accessoryView = nil;
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
    if (indexPath.row == currentSelectedMaster) {
        currentSelectedMaster = NSNotFound;
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
    } else {
        currentSelectedMaster = indexPath.row;
        if (self.navigationItem.rightBarButtonItem == nil) {
            UIBarButtonItem *joinButtonItem;
            joinButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Join" 
                                                              style:UIBarButtonItemStyleBordered 
                                                             target:self 
                                                             action:@selector(joinAction)];
            [self.navigationItem setRightBarButtonItem:joinButtonItem animated:YES];
        }
    }
    [table reloadData];
    [table selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [table deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Actions 

- (void)updateMasters {
    self.activityIndicatorVisible = YES;
    [AppServerHelper updateMastersListWithlistener:self];    
}

@end
