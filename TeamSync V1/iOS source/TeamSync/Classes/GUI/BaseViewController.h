//
//  BaseViewController.h
//  TeamSync
//
//  Created for SMG Mobile on 3/14/12.
//  
//

#import "Common.h"
#import "Managers.h"
#import "AppServer.h"


@interface BaseViewController : UIViewController <ServerRequestDelegate, UIAlertViewDelegate> {
    __strong UIActivityIndicatorView *activityIndicatorView;
}

@property (nonatomic, assign) BOOL activityIndicatorVisible;
@property (nonatomic, assign) BOOL activityIndicatorOnTop;

- (void)updateData;

@end
