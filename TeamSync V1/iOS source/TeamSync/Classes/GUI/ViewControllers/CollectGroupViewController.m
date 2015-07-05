//
//  CollectGroupViewController.m
//  TeamSync
//
//  Created for SMG Mobile on 3/21/12.
//  
//

#import "CollectGroupViewController.h"
#import "PlaybackViewController.h"

@interface CollectGroupViewController ()
@end

@implementation CollectGroupViewController
@synthesize playlist;

//- (void)disconnect {
//    [self.navigationController popViewControllerAnimated:YES];
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [[SyncWrapper sharedInstance] stopService];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Team";
    
//    UIBarButtonItem *addButtonItem;
//    addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
//                                                                  target:self action:@selector(startPlyaback)];
//    self.navigationItem.rightBarButtonItem = addButtonItem;
//
// 
//    UIBarButtonItem *disconnectItem = [[UIBarButtonItem alloc] initWithTitle:@"Disconect" 
//                                                                       style:UIBarButtonItemStyleBordered 
//                                                                      target:self action:@selector(disconnect)];
//    self.navigationItem.leftBarButtonItem = disconnectItem;

}

//- (void)startPlyaback {
//    PlaybackViewController *playback = [PlaybackViewController new];
//    [self.navigationController pushViewController:playback animated:YES];
//    
//    playback.currentPlaylistVC.playlist = self.playlist;
//    [playback.currentPlaylistVC updateData];
//}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
//    if (self.playlist != nil) {
//        self.navigationItem.title = self.playlist.title;
//    }    
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserlist) 
//                                                 name:SyncNotificationUserlistChanged object:nil];
    
//    [self updateUserlist];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
    
- (void)updateUserlist {
//    [self.itemsArray removeAllObjects];
//    [self.itemsArray addObjectsFromArray:[[SyncWrapper sharedInstance].messageHendler userlist]];
//    if ([self.itemsArray count] == 0) {
//        [self.itemsArray addObject:@"Waiting for users"];
//    }
//    [self.tableView reloadData];
//    
//    self.activeIndicatorVisible = ([self.itemsArray count] == 0);
}

#pragma mark - UITableViewDataSource 

#pragma mark - Actions

#pragma mark - Server 
- (void) serverRequest:(ServerRequest)serverRequest 
      didFailWithError:(NSError*)error 
              userInfo:(NSDictionary*)userInfo {

    [[AppServer sharedInstance] removeDelegate:self];
    
    NSString *errorStr = [NSString stringWithFormat:@"%@", error];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"ERROR" 
                                                     message:errorStr
                                                    delegate:self 
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
    [alert show];

}

- (void) serverRequestDidFinish:(ServerRequest)serverRequest 
                         result:(id)result 
                       userInfo:(NSDictionary*)userInfo {
    [[AppServer sharedInstance] removeDelegate:self];
    
    NSLog(@"result: %@", result);
    NSDictionary *connectionInfo = [result objectForKey:@"connection"];    

    NSString *serviseIP = [connectionInfo objectForKey:@"ip"];
    int port = [[connectionInfo objectForKey:@"port"] intValue];
    
    [[SyncWrapper sharedInstance] startServiceWithServiseIP:serviseIP port:port];
    
//    NSString *str = [NSString stringWithFormat:@"data from server - [%@]", result];
//    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"PA6OTAET :)" 
//                                                     message:str
//                                                    delegate:self 
//                                           cancelButtonTitle:@"OK"
//                                           otherButtonTitles:nil];
//    [alert show];
}
@end
