//
//  AddPlaylistViewController.m
//  TeamSync
//
//  Created for SMG Mobile on 20.03.12.
//  
//

#import "AddPlaylistViewController.h"
#import "TracksSearchViewController.h"

@interface AddPlaylistViewController ()

@end

@implementation AddPlaylistViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"Add new playlist";
    
    _playlistField = [[UITextField alloc] initWithFrame:CGRectMake(35.0, 80.0, 250.0, 38.0)];
    _playlistField.delegate = self;
    _playlistField.borderStyle = UITextBorderStyleRoundedRect;
    _playlistField.placeholder = @"Playlist name";
    _playlistField.textColor = [UIColor blackColor];
    _playlistField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _playlistField.autocorrectionType = UITextAutocorrectionTypeNo;
    _playlistField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _playlistField.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:_playlistField];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_playlistField becomeFirstResponder];
    
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    
    if ([textField.text length] == 0) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"You can't add playlist" 
                                                         message:@"Enter playlist name before"
                                                        delegate:self 
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil];
        [alert show];
    } else {
        
        Playlist *playlist = [[StoreManager sharedInstance] createPlaylistWithTitle:textField.text deacription:@""];
        
        /// Navigation
        [textField resignFirstResponder];
        
        UINavigationController *nav = self.navigationController;
        
        TracksSearchViewController *tracksSearch = [TracksSearchViewController new];
        tracksSearch.playlist = playlist;
        
        [nav popViewControllerAnimated:NO];
        [nav pushViewController:tracksSearch animated:YES];
        
//        NSMutableArray *arr = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
//        [arr removeObject:self];
//        nav.viewControllers = arr;
    }
    
    return YES;
}



@end
