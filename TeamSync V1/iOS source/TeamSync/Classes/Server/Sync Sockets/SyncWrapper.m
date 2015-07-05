//
//  SyncWrapper.m
//  TeamSync
//
//  Created for SMG Mobile on 3/28/12.
//  
//

#import "SyncWrapper.h"
#import "DataProvider.h"

@interface SyncWrapper ()
@property (nonatomic, readwrite) BOOL serviceStarted;
@property (nonatomic, retain) WebSocket10 *webSocket;

@end

@implementation SyncWrapper
@synthesize serviceStarted;

@synthesize webSocket;

@synthesize messagehandler;

+ (SyncWrapper*) sharedInstance {
    
	static SyncWrapper *sharedSyncWrapper = nil;
	if (sharedSyncWrapper == nil) {
		sharedSyncWrapper = [[SyncWrapper alloc] init];
	}
	return sharedSyncWrapper;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.messagehandler = [SyncMessagehandler new];
    }
    return self;
}

- (void)startServiceWithServiseIP:(NSString*)address port:(int)port {

    
    if (serviceStarted == NO) {
        //http://test.mobile2morrow.com/teamsync/Demo/
        //NSString *url = @"ws://test.mobile2morrow.com:8090/teamsync/Demo/";
        //NSString *url = @"ws://test.mobile2morrow.com:8090";
        
        NSString *url = [NSString stringWithFormat:@"ws://%@:%d", address, port];
        
        NSLog(@"url: %@", url);
        
        self.webSocket = [WebSocket10 webSocketWithURLString:url
                                               delegate:self origin:nil protocols:nil tlsSettings:nil verifyHandshake:true];
        [self.webSocket open];
    }
}

#pragma --------------
-(void)stopService {
    if (serviceStarted) {
        User *user = [DataProvider currentActiveUser];
        if ([user.isMaster boolValue] == NO) {
            [self.webSocket sendText:@"CLOSE"];
        }
        
        [self.webSocket close];
    }
}

- (void)sendPing {
    int length = 16;
    char *bytes = (char *)malloc(length);
    NSData *data = [NSData dataWithBytes:bytes length:length];
    [self.webSocket sendPing:data];
}
- (void)sendTextMessage:(NSString*)message {
    if (serviceStarted) {
        NSString *str = [NSString stringWithFormat:@"MESSAGE %@", message];
        [self.webSocket sendText:str];
    }    
}

- (void)sendTrackIndex:(int)index {
    NSString *command = [NSString stringWithFormat:@"%@ %d", SyncNotificationTrackIndexChanged, index];
    [self sendTextMessage:command];
}
- (void)sendPlayMessage {
    [self sendTextMessage:SyncNotificationPlayTrack];
}
- (void)sendStopMessage {
    [self sendTextMessage:SyncNotificationStopPlaying];
}

- (void)sendPlaybackSyncInfo:(NSDictionary*)info {
    NSString *infoString = [info JSONString];
    NSString *command = [NSString stringWithFormat:@"%@ %@", SyncNotificationPlaybackSyncing, infoString];
    [self sendTextMessage:command];
}

- (void)sendVolumeSincInfo:(NSDictionary*)info {
    NSString *infoString = [info JSONString];
    NSString *command = [NSString stringWithFormat:@"%@ %@", SyncNotificationVolumeSyncing, infoString];
    [self sendTextMessage:command];
}
#pragma --------------

- (void) didOpen {
    NSLog(@"didOpen");
    serviceStarted = YES;
    
    if (pingTimer == nil) {
        pingTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self
                                                   selector:@selector(sendPing) 
                                                   userInfo:nil repeats:YES];
    }
    [self.messagehandler resetSession];
    
    User *user = [DataProvider currentActiveUser];
    NSString *nickname = [NSString stringWithFormat:@"NICKCHANGE %@", user.username];
    [self.webSocket sendText:nickname];
    
}
- (void) didClose:(NSUInteger) aStatusCode message:(NSString*) aMessage error:(NSError*) aError {
    
    serviceStarted = NO;
    self.webSocket = nil;

    [pingTimer invalidate];
    pingTimer = nil;
}

- (void) didReceiveError:(NSError*) aError {
    NSLog(@"didReceiveError");
    [[NSNotificationCenter defaultCenter] postNotificationName:SyncNotificationConnectingClosedWithError
                                                        object:nil];
}
- (void) didReceiveTextMessage:(NSString*) aMessage {
    [self.messagehandler handleTextMessage:aMessage];
}

- (void) didReceiveBinaryMessage:(NSData*) aMessage {
    NSLog(@"didReceiveBinaryMessage");
}

- (void) didSendPong:(NSData*) aMessage {
    NSLog(@"didSendPong");
}

@end
