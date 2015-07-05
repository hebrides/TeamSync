//
//  PlaybackViewController.h
//  TeamSync
//
//  Created for SMG Mobile on 26.03.12.
//  
//

#import "BaseViewController.h"

#import "CurrentPlaylistViewController.h"
#import "ChatViewController.h"
#import "TeamListViewController.h"
#import "AppDatePicker.h"


@interface PlaybackViewController : BaseViewController <AppDatePickerDelegate> {
    __strong NSTimer *scheduleTimer;
}

@property (nonatomic, strong) CurrentPlaylistViewController *currentPlaylistVC;
@property (nonatomic, strong) ChatViewController *chatVC;
@property (nonatomic, strong) TeamListViewController *teamListVC;

@property (nonatomic, strong) Master *master;

- (void)selectScreenAtIndex:(int)screenIndex;

@end
