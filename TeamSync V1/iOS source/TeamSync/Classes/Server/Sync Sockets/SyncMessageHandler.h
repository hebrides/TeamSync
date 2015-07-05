//
//  SyncMessagehandler.h
//  TeamSync
//
//  Created for SMG Mobile on 3/28/12.
//  
//

#import <UIKit/UIKit.h>
#import "Common.h"

#define SyncNotificationConnectingClosedWithError @"SyncNotificationConnectingClosedWithError"
#define SyncNotificationServiceStarted @"SyncNotificationServiceStarted"

#define SyncNotificationNewMessage @"SyncNotificationNewMessage"
#define SyncNotificationUserlistChanged @"SyncNotificationNewMessage"

#define SyncNotificationTrackIndexChanged @"SyncNotificationTrackIndexChanged"
#define SyncNotificationPlayTrack @"SyncNotificationPlayTrack"
#define SyncNotificationStopPlaying @"SyncNotificationStopPlaying"

#define SyncNotificationPlaybackSyncing @"SyncNotificationPlaybackSyncing"
#define SyncNotificationVolumeSyncing @"SyncNotificationVolumeSyncing"

@interface SyncMessagehandler : NSObject {
    __strong NSMutableArray *userlistArray;
    __strong NSMutableArray *messagesArray;
}

- (void)resetSession;

- (void)handleTextMessage:(NSString*)message;

- (NSArray*)userlist;
- (NSArray*)messages;


@end
