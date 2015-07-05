//
//  TracksSearchViewController.m
//  TeamSync
//
//  Created for SMG Mobile on 3/20/12.
//  
//

#import "TracksSearchViewController.h"


@interface TracksSearchViewController () {
//    BOOL isDoneButtonPressed;
}
@property (nonatomic, assign) BOOL keyboardVisible;
@end

@implementation TracksSearchViewController
@synthesize playlist;
@synthesize keyboardVisible;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Search";
        
    
    
    UIBarButtonItem *doneButtonItem;
    doneButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" 
                                                      style:UIBarButtonItemStyleBordered 
                                                     target:self
                                                     action:@selector(doneButtonAction)];
    self.navigationItem.leftBarButtonItem = doneButtonItem;

    
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
	[self.view addSubview:searchBar];
	searchBar.delegate = self;
	searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	searchBar.showsCancelButton = NO;
	searchBar.tintColor = [UIColor darkGrayColor];
	searchBar.placeholder = @"Your search here...";

    self.tableView.autoresizingMask = UIViewAutoresizingNone;
    self.tableView.frame = CGRectMake(0, 44, 320, self.view.bounds.size.height - 44);
    
    //self.activityIndicatorOnTop = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.playlist != nil) {
        NSString *title = [NSString stringWithFormat:@"Add tracks to: %@", self.playlist.title];
        self.navigationItem.title = title;        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self.tableView
                                             selector:@selector(reloadData) 
                                                 name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [searchBar becomeFirstResponder];
    
    //[[DataManager sharedInstance] save];
    //isDoneButtonPressed = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self.tableView];
    [[AppServer sharedInstance] removeDelegate:self];
//    if (isDoneButtonPressed == NO) {
//        [[DataManager sharedInstance] revertChanges];
//    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[AppServer sharedInstance] removeDelegate:self];
}

- (void)doneButtonAction {
//    isDoneButtonPressed = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setKeyboardVisible:(BOOL)visible {
    keyboardVisible = visible;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    if (keyboardVisible) {
        self.tableView.frame = CGRectMake(0, 44, 320, self.view.bounds.size.height - (44 + 214));
    } else {
        self.tableView.frame = CGRectMake(0, 44, 320, self.view.bounds.size.height - 44);
    }
    [UIView commitAnimations];
}


- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"PlaylistIdentifier";
    TrackCell *cell = (TrackCell*)[table dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[TrackCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.delegate = self;
    }
    
    Track *track = [self.itemsArray objectAtIndex:indexPath.row];
    cell.trackTitle.text = track.title;
    
    NSString *desc = [NSString stringWithFormat:@"%@ (%@ - %.2f min)", 
                      track.artistName, track.genreName, [track.length floatValue]];
    
    cell.trackSubtitle.text = desc;
    
    if (track.playlist != nil) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark.png"]];
    } else {
        cell.accessoryView = nil;
    }
    
    if ([[PlaybackManager sharedInstance] isItCurrentPlayingTrack:track]) {
        if ([PlaybackManager sharedInstance].playbackState == PlaybackStateLoading) {
            cell.trackState = TRACK_STATE_LOADING;
        } else {
            cell.trackState = TRACK_STATE_PLAYING;
        }
    } else {
        cell.trackState = TRACK_STATE_POUSED;
    }
    
    return cell;
}



- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
    Track *track = [self.itemsArray objectAtIndex:indexPath.row];

    if (track.playlist == nil) {
        [self.playlist addTracksObject:track];
        track.playlist = self.playlist;
        
        NSArray *tracks = [DataProvider arraySortedByKey:kCDOPropertyOrder from:self.playlist.tracks];
        for (int i = 0; i < [tracks count]; i++) {
            Track *savedTrack = [tracks objectAtIndex:i];
            savedTrack.order = [NSNumber numberWithInt:i];
        }
        
        track.order = [NSNumber numberWithInt:[tracks count]];

    } else {
        [self.playlist removeTracksObject:track];
        track.playlist = nil;
    }
    
    [table reloadData];
    [table selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [table deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)trackCellPlayButtonPressedAtIndexPath:(NSIndexPath*)indexPath {
    Track *track = [self.itemsArray objectAtIndex:indexPath.row];
    if ([[PlaybackManager sharedInstance] isItCurrentPlayingTrack:track]) {
        [[PlaybackManager sharedInstance] stopPlaying];
    } else {
        [[PlaybackManager sharedInstance] playTrack:track];
    }
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark Search Bar
- (void)searchBarTextDidBeginEditing:(UISearchBar *)bar {
	[bar setShowsCancelButton:YES animated:YES];
    self.keyboardVisible = YES;
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    self.keyboardVisible = NO;
    return YES;
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)bar {
	[bar setShowsCancelButton:NO animated:YES];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)bar {
	[bar resignFirstResponder];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)bar {
	[bar resignFirstResponder];
    // search here
    
    NSString *keyword = bar.text;
    
    if ([keyword length] == 0) {
        keyword = @"";
    }
//        [AppServerHelper searchRequestFor:bar.text withlistener:self];

    self.activityIndicatorVisible = YES;
        
    [[IPodDataManager sharedInstance] updateDetectedTracksWithKeyword:keyword];
        
    [self.itemsArray removeAllObjects];
    [self.itemsArray addObjectsFromArray:[DataProvider allDetectedTracks]];
    [self.tableView reloadData];
    
    self.activityIndicatorVisible = NO;

}

#pragma mark - Server Search
//- (void) serverRequest:(ServerRequest)serverRequest 
//      didFailWithError:(NSError*)error 
//              userInfo:(NSDictionary*)userInfo {
//    [[AppServer sharedInstance] removeDelegate:self];
//    self.activityIndicatorVisible = NO;
//}
//- (void) serverRequestDidFinish:(ServerRequest)serverRequest 
//                         result:(id)result 
//                       userInfo:(NSDictionary*)userInfo {
//    [self.itemsArray removeAllObjects];
//    [self.itemsArray addObjectsFromArray:[DataProvider allDetectedTracks]];
//    [self.tableView reloadData];
//    
//    [[AppServer sharedInstance] removeDelegate:self];
//    self.activityIndicatorVisible = NO;
//}

@end
