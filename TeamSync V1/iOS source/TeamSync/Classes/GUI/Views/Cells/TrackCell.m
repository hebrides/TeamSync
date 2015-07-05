//
//  TrackCell.m
//  TeamSync
//
//  Created for SMG Mobile on 20.03.12.
//  
//

#import "TrackCell.h"

@implementation TrackCell {
    UIActivityIndicatorView *_activityIndicator;
    UIButton *_playButton;
}
@synthesize delegate;
@synthesize trackTitle = _trackTitle;
@synthesize trackSubtitle = _trackSubtitle;
@synthesize trackState = _trackState;
@synthesize playButton = _playButton;


- (UILabel*)labelWithFrame:(CGRect)rect font:(UIFont*)font {
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.backgroundColor = [UIColor clearColor];
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    label.textAlignment =   NSTextAlignmentLeft;
    label.font = font;
    label.textColor = [UIColor blackColor];
    label.highlightedTextColor = [UIColor redColor];
    label.userInteractionEnabled = NO;
    [self.contentView addSubview:label];
    return label;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _trackTitle = [self labelWithFrame:CGRectMake(43.0, 0.0, 223.0, 21.0) font:[UIFont boldSystemFontOfSize:14]];

        _trackSubtitle = [self labelWithFrame:CGRectMake(43.0, 20.0, 223.0, 21.0) font:[UIFont systemFontOfSize:14]];

        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.frame = CGRectMake(5.0, 5.0, 35.0, 35.0);
        [_playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_playButton];
        
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityIndicator.frame = CGRectMake(22.0, 22.0, 0.0, 0.0);
        [self.contentView addSubview:_activityIndicator];
        
        _trackState = TRACK_STATE_INITIALIZED;
    }
    return self;
}


- (void)setTrackState:(TrackState)trackState {
    if (trackState == TRACK_STATE_INITIALIZED) {
        [_activityIndicator stopAnimating];
        _playButton.hidden = YES;
    }
    else if (trackState == TRACK_STATE_LOADING) {
        [_activityIndicator startAnimating];
        _playButton.hidden = YES;        
    } 
    else if (trackState == TRACK_STATE_POUSED) {
        [_activityIndicator stopAnimating];        
        _playButton.hidden = NO;
        [_playButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];        
    } 
    else if (trackState == TRACK_STATE_PLAYING) {
        [_activityIndicator stopAnimating];
        _playButton.hidden = NO;        
        [_playButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    }
    
    _trackState = trackState;
}

#pragma mark - Actions

- (void)play {
    UITableView *table = (UITableView*)self.superview;
    [self.delegate trackCellPlayButtonPressedAtIndexPath:[table indexPathForCell:self]];
}



@end
