//
//  TrackCell.h
//  TeamSync
//
//  Created for SMG Mobile on 20.03.12.
//  
//

#import <UIKit/UIKit.h>
@class TrackCell;
@protocol TrackCellDelegate <NSObject>
- (void)trackCellPlayButtonPressedAtIndexPath:(NSIndexPath*)indexPath;
@end

typedef enum {
    TRACK_STATE_INITIALIZED = 0,
    TRACK_STATE_LOADING,
    TRACK_STATE_PLAYING,
    TRACK_STATE_POUSED,
} TrackState;

@interface TrackCell : UITableViewCell
@property (nonatomic, assign) id <TrackCellDelegate> delegate;
@property (nonatomic, retain) UILabel *trackTitle;
@property (nonatomic, retain) UILabel *trackSubtitle;
@property (nonatomic, assign) TrackState trackState;
@property (nonatomic, readonly) UIButton *playButton;


@end
