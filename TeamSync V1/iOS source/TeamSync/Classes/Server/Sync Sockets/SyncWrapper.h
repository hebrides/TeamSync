//
//  SyncWrapper.h
//  TeamSync
//
//  Created for SMG Mobile on 3/28/12.
//  
//


#import <Foundation/Foundation.h>
#import "SyncMessagehandler.h"


#import "WebSocket10.h"

@interface SyncWrapper : NSObject <WebSocket10Delegate>  {
    
    __strong NSTimer *pingTimer;
}
+ (SyncWrapper*) sharedInstance;
@property (nonatomic, readonly) BOOL serviceStarted;
@property (nonatomic, strong) SyncMessagehandler *messagehandler;

- (void)startServiceWithServiseIP:(NSString*)address port:(int)port;
- (void)stopService;

- (void)sendTextMessage:(NSString*)message;

- (void)sendTrackIndex:(int)index;
- (void)sendPlayMessage;
- (void)sendStopMessage;

- (void)sendPlaybackSyncInfo:(NSDictionary*)info;
- (void)sendVolumeSincInfo:(NSDictionary*)info;

@end