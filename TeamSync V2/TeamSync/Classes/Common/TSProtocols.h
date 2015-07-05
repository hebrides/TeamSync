//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSProtocols.h
// Description		:	TSProtocols class Declaration.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#ifndef TeamSync_TSProtocols_h
#define TeamSync_TSProtocols_h

#endif

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@protocol TSPlayListViewDelegate <NSObject>
- (void)selectedPlayList:(MPMediaPlaylist*)playlist;
@end

@protocol TSSigninViewDelegate <NSObject>
- (void)didSelectedLogoutButton;
@end

@protocol TSSCommunicationManagerDelegate <NSObject>
@optional
- (void)updateDeviceListTableView;
- (void)showDisconnectButton;
- (void)showSongList:(NSDictionary*)songDict;
- (void)showSongListWithMusic:(NSDictionary*)songDict;
- (void)showSongDetailsScreen:(NSDictionary*)songDict;
- (void)didChangedPlayState:(NSDictionary*)songDict;
- (void)didChangedSongvolume:(NSString*)volume;
- (void)didChangedSongDuration:(NSDictionary*)durationDict;
- (void)resetDurationSliderinPlaySongView;
- (void) hideProgressView;
@end

@class TSClientSongListViewCell;
@protocol TSClientSongListViewCellDelegate <NSObject>
@optional
- (void)onDownloadBtnPressed:(NSInteger)btnTag;
- (void)setIndexpath:(NSIndexPath *)indexPath;
@end


@protocol TSSongPlayViewControllerDelegate <NSObject>
@optional
- (void)didChangedToNextSong;
@end

@protocol TSClientSongPlayViewControllerDelegate <NSObject>
@optional
- (void)didChangedVolumnInMaster;
- (void)didChangedSongInMaster;
- (void)didChangedDurationInMaster;
- (void)didChangedPlayStateInMaster;
- (void)didResetDurationInMaster;
- (void)changePlayStateMaster;
@end