//
//  TeamListViewController.m
//  TeamSync
//
//  Created for SMG Mobile on 29.03.12.
//  
//

#import "TeamListViewController.h"

@interface TeamListViewController ()
@end

@implementation TeamListViewController



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.tableView.frame = CGRectMake(0, 0, 320, 366);

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserlist) 
                                                 name:SyncNotificationUserlistChanged object:nil];
    [self updateUserlist];    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateUserlist {

    [self.itemsArray removeAllObjects];
    [self.itemsArray addObjectsFromArray:[[SyncWrapper sharedInstance].messagehandler userlist]];
    if ([self.itemsArray count] == 0) {
        [self.itemsArray addObject:@"Waiting for users"];
    }
    [self.tableView reloadData];
    
//    [self.itemsArray removeAllObjects];
//    [self.itemsArray addObjectsFromArray:[[SyncWrapper sharedInstance].messagehandler userlist]];
//    [self.tableView reloadData];
    
    //self.activityIndicatorVisible = ([self.itemsArray count] == 0);
}


@end
