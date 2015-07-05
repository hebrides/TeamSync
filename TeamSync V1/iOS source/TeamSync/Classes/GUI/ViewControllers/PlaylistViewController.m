//
//  PlaylistViewController.m
//  TeamSync
//
//  Created for SMG Mobile on 3/20/12.
//  
//

#import "PlaylistViewController.h"
#import "TracksSearchViewController.h"
#import "PlaybackViewController.h"

@interface PlaylistViewController ()
- (BOOL)canEditCurrentPlaylist;
@end

@implementation PlaylistViewController
@synthesize playlist;

- (void)viewDidLoad {
    [super viewDidLoad];
        
    
    self.tableView.autoresizingMask = UIViewAutoresizingNone;
    [self.tableView setFrame:CGRectMake(0.0, 0.0, 320.0, 372)];
    self.tableView.allowsSelectionDuringEditing = YES;
    
    UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 372, 320, 44)];
    [self.view addSubview:bottomBorder];
    bottomBorder.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
    
    UIImage *anImage = [UIImage imageNamed:@"buttonUnpressed.png"];
    UIButton *collectGroup = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:collectGroup];
    [collectGroup setBackgroundImage:anImage forState:UIControlStateNormal];
    [collectGroup addTarget:self action:@selector(startAction) forControlEvents:UIControlEventTouchUpInside];
    [collectGroup setTitle:@"Start" forState:UIControlStateNormal];
    collectGroup.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    [collectGroup setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.5f] forState:UIControlStateDisabled];
    collectGroup.frame = CGRectMake(6, 378, 308, 32);
}

#pragma -
- (void)editButtonAction {
    [self.tableView setEditing: ! self.tableView.editing animated:YES];
    
    UIBarButtonItem *editButtonItem;
    editButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.tableView.editing ? @"Done" : @"Edit" 
                                                      style:UIBarButtonItemStyleBordered 
                                                     target:self action:@selector(editButtonAction)];
    [self.navigationItem setRightBarButtonItem:editButtonItem animated:YES];
}

- (void)addNewTrackAction {
    TracksSearchViewController *tracksSearch = [TracksSearchViewController new];
    tracksSearch.playlist = self.playlist;
    [self.navigationController pushViewController:tracksSearch animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.itemsArray removeAllObjects];

    if (self.playlist != nil) {
        self.navigationItem.title = self.playlist.title;
        
        [self.itemsArray addObjectsFromArray:[DataProvider arraySortedByKey:kCDOPropertyOrder 
                                                                       from:self.playlist.tracks]];        
    }    
    
    if ([self.itemsArray count] > 0 && [self canEditCurrentPlaylist]) {
        UIBarButtonItem *editButtonItem;
        editButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.tableView.editing ? @"Done" : @"Edit" 
                                                          style:UIBarButtonItemStyleBordered 
                                                         target:self action:@selector(editButtonAction)];
        [self.navigationItem setRightBarButtonItem:editButtonItem animated:YES];
    }
    
    [self.tableView reloadData];    
    [[NSNotificationCenter defaultCenter] addObserver:self.tableView
                                             selector:@selector(reloadData) 
                                                 name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)canEditCurrentPlaylist {
    return ! [self.playlist.isIPodOwner boolValue];
}

#pragma mark - UITableViewDataSource 
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if ([self canEditCurrentPlaylist] == NO) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor clearColor];
        return view;
    }
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    footer.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
    
    UIImage *anImage = [UIImage imageNamed:@"buttonUnpressed.png"];
    UIButton *addTrackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [footer addSubview:addTrackButton];
    [addTrackButton setBackgroundImage:anImage forState:UIControlStateNormal];
    [addTrackButton addTarget:self action:@selector(addNewTrackAction) forControlEvents:UIControlEventTouchUpInside];
    [addTrackButton setTitle:@"Add tracks" forState:UIControlStateNormal];
    addTrackButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    [addTrackButton setTitleColor:[UIColor colorWithWhite:0.0f alpha:0.5f] forState:UIControlStateDisabled];
    addTrackButton.frame = CGRectMake(6, 6, 308, 32);
    
    return footer;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 44;
}
- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellIdentifier = @"cellIdentifier";
    TrackCell *cell = (TrackCell*)[table dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[TrackCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.delegate = self;
    }
    
    Track *track = [self.itemsArray objectAtIndex:indexPath.row];
    cell.trackTitle.text = track.title;
    
    NSString *desc = [NSString stringWithFormat:@"%@ (%@ - %.2f min)", 
                      track.artistName, track.genreName, [track.length floatValue]];
    
    cell.trackSubtitle.text = desc;

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
    [table deselectRowAtIndexPath:indexPath animated:YES];
    [self trackCellPlayButtonPressedAtIndexPath:indexPath];
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


- (void)tableView:(UITableView *)table moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    [self.itemsArray exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
	for (int i = 0; i < [self.itemsArray count]; i++) {
		Track *track = [self.itemsArray objectAtIndex:i];
		track.order = [NSNumber numberWithInt:i];
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self canEditCurrentPlaylist];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Track *track = [self.itemsArray objectAtIndex:indexPath.row];
        [self.itemsArray removeObject:track];
        [self.playlist removeTracksObject:track];
        [track deleteObject];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }
}

#pragma mark - Actions

- (void)startAction {
    if ([self.playlist.tracks count] == 0) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Playlist Empty!"
                                                         message:@"Add tracks before playing."
                                                        delegate:self 
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [alert show];
    } else {
        PlaybackViewController *playback = [PlaybackViewController new];        
        playback.currentPlaylistVC.playlist = self.playlist;
        //[playback.currentPlaylistVC updateData];
        [AppServerHelper sendPlaylist:self.playlist toStartSessionWithlistener:playback];
        
        [self.navigationController pushViewController:playback animated:YES];
        playback.view.userInteractionEnabled = NO;
        playback.activityIndicatorVisible = YES;
    }
}

@end
