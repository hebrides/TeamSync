//
//  PlaylistsViewController.m
//  TeamSync
//
//  Created for SMG Mobile on 3/20/12.
//  
//

#import "PlaylistsViewController.h"
#import "LoginViewController.h"
#import "PlaylistViewController.h"
#import "AddPlaylistViewController.h"

#import "AppDelegate.h"

@interface PlaylistsViewController ()
@property (nonatomic, strong) NSArray *iPodPLaylists;

@end

@implementation PlaylistsViewController
@synthesize iPodPLaylists;

- (void)dealloc {
    self.iPodPLaylists = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Playlists";
    
    UIBarButtonItem *addButtonItem;
    addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                   target:self
                                                                                   action:@selector(addNewPlaylistAction)];
    self.navigationItem.rightBarButtonItem = addButtonItem;
    
    UIBarButtonItem *logoutButtonItem;
    logoutButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Log out" 
                                                     style:UIBarButtonItemStyleBordered 
                                                    target:self 
                                                    action:@selector(logoutAction)];
    self.navigationItem.leftBarButtonItem = logoutButtonItem;
}

- (void)updateData {
        
    [self.itemsArray removeAllObjects];
    [self.itemsArray addObjectsFromArray:[DataProvider allPlaylistsForCurrentActiveUser]];
    
    self.iPodPLaylists = [DataProvider allPlaylistsFromIPod];
    
    [self.tableView reloadData];
}

- (void)addNewPlaylistAction {
    AddPlaylistViewController *viewController = [AddPlaylistViewController new];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)logoutAction {
    [[PlaybackManager sharedInstance] stopPlaying];
    [[AppDelegate sharedAppDelegate] showLoginScreen];    
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int num = 0;
    num += [self.itemsArray count] ? 1 : 0;
    num += [self.iPodPLaylists count] ? 1 : 0;
    return num;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 && [self.itemsArray count]) {
        return [self.itemsArray count];
    }
    return [self.iPodPLaylists count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0 && [self.itemsArray count]) {
        return @"Custom playlists";
    }
    return @"iPod";
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    UITableViewCell *cell = [super tableView:table cellForRowAtIndexPath:indexPath];
    cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_right.png"]];
    
    
    Playlist *playlist = nil;
    if (indexPath.section == 0 && [self.itemsArray count]) {
        playlist = [self.itemsArray objectAtIndex:indexPath.row];
    } else {
        playlist = [self.iPodPLaylists objectAtIndex:indexPath.row];
    }
    cell.textLabel.text = playlist.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [playlist.tracks count]];
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[table deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *playlists = nil;
    if (indexPath.section == 0 && [self.itemsArray count]) {
        playlists = self.itemsArray;
    } else {
        playlists = self.iPodPLaylists;
    }
    
    Playlist *playlist = [playlists objectAtIndex:indexPath.row];
    
    PlaylistViewController *playlistVC = [PlaylistViewController new];
    playlistVC.playlist = playlist;
    [self.navigationController pushViewController:playlistVC animated:YES];
    
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && [self.itemsArray count]) {
        return YES;
    }
    return NO;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 || [self.itemsArray count] == 0) {
        return;
    }
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Playlist *playlist = [self.itemsArray objectAtIndex:indexPath.row];
        [self.itemsArray removeObject:playlist];
        [playlist deleteObject];
        if ([self.itemsArray count] > 0) {
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
        } else {
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationRight];
        }
    }
}



@end
