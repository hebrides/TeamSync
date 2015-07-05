//
//  BaseViewController.m
//  TeamSync
//
//  Created for SMG Mobile on 3/14/12.
//  
//

#import "BaseViewController.h"

@interface BaseViewController ()
@end

@implementation BaseViewController
@synthesize activityIndicatorVisible;
@synthesize activityIndicatorOnTop;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor darkGrayColor];

    UIBarButtonItem *back;
    back = [[UIBarButtonItem alloc] initWithTitle:@"Back" 
                                            style:UIBarButtonItemStyleBordered 
                                           target:nil 
                                           action:nil];
    self.navigationItem.backBarButtonItem = back;
    
    
    activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.view addSubview:activityIndicatorView];
    activityIndicatorView.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateData];
}

- (void)setactivityIndicatorOnTop:(BOOL)onTop {
    activityIndicatorOnTop = onTop;
    if (activityIndicatorOnTop) {
        activityIndicatorView.center = CGPointMake(self.view.frame.size.width / 2, 115);
    } else {
        activityIndicatorView.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    }
}

- (void)setactivityIndicatorVisible:(BOOL)visible {
    activityIndicatorVisible = visible;
    if (activityIndicatorVisible == YES) {
        [self.view bringSubviewToFront:activityIndicatorView];
        [activityIndicatorView startAnimating];
    } else {
        [activityIndicatorView stopAnimating];
    }
}

#pragma mark - server
- (void) serverRequest:(ServerRequest)serverRequest 
      didFailWithError:(NSError*)error 
              userInfo:(NSDictionary*)userInfo {
    [[AppServer sharedInstance] removeDelegate:self];
    
    self.activityIndicatorVisible = NO;
}
- (void) serverRequestDidFinish:(ServerRequest)serverRequest 
                         result:(id)result 
                       userInfo:(NSDictionary*)userInfo {    
    self.activityIndicatorVisible = NO;
    [self updateData];
    [[AppServer sharedInstance] removeDelegate:self];
}

//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    self.activityIndicatorOnTop = YES;
//    self.activityIndicatorVisible = YES;
//}
- (void)updateData {}

@end
