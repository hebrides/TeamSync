//
//  SyncMessagehandler.m
//  TeamSync
//
//  Created for SMG Mobile on 3/28/12.
//  
//

#import "SyncMessagehandler.h"
#import "DataProvider.h"

@implementation SyncMessagehandler

- (id)init
{
    self = [super init];
    if (self) {
        [self resetSession];
    }
    return self;
}

- (void)resetSession {
    userlistArray = [NSMutableArray new];
    messagesArray = [NSMutableArray new];
}


- (void)handleTextMessage:(NSString*)message {
    
    NSLog(@"SyncMessagehandler message: %@", message);
    
    if ([message length] == 0) {
        return;
    }
    
    NSInteger comLocation = [message rangeOfString:@" "].location;
    
    if (comLocation == NSNotFound) {
        return;
    }
    
    NSString *command = [message substringToIndex:comLocation];
    NSString *body = [message substringFromIndex:comLocation + 1];
    
    if ([command isEqualToString:@"USERLIST"]) {
        NSArray *userlist = [body componentsSeparatedByString:@","];
                
        [userlistArray removeAllObjects];
        
        
        User *user = [DataProvider currentActiveUser];
        
        for (NSString *nickname in userlist) {
            if ([nickname isEqualToString:user.username] == NO &&
                [nickname rangeOfString:@"waite_for_update_nickname"].location == NSNotFound) {
                [userlistArray addObject:nickname];
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SyncNotificationUserlistChanged object:nil];

    } else if ([command isEqualToString:@"MESSAGE"]) {
        
        NSInteger nickLocation = [body rangeOfString:@" "].location;
        NSString *nickname = [body substringToIndex:nickLocation];
        NSString *text = [body substringFromIndex:nickLocation + 1];
        
        if ([text rangeOfString:SyncNotificationTrackIndexChanged].location == 0) {
            NSString *num = [text substringFromIndex:[text rangeOfString:@" "].location];
            [[NSNotificationCenter defaultCenter] postNotificationName:SyncNotificationTrackIndexChanged object:num];
        
        } else if([text rangeOfString:SyncNotificationPlayTrack].location == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SyncNotificationPlayTrack object:nil];
        
        } else if([text rangeOfString:SyncNotificationStopPlaying].location == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SyncNotificationStopPlaying object:nil];
        
        } else if ([text rangeOfString:SyncNotificationPlaybackSyncing].location == 0) {
            NSString *syncInfoString = [text substringFromIndex:[text rangeOfString:@" "].location];
            NSDictionary *syncInfo = [syncInfoString objectFromJSONString];
            [[NSNotificationCenter defaultCenter] postNotificationName:SyncNotificationPlaybackSyncing object:syncInfo];
            
        } else if ([text rangeOfString:SyncNotificationVolumeSyncing].location == 0) {
            NSString *syncInfoString = [text substringFromIndex:[text rangeOfString:@" "].location];
            NSDictionary *syncInfo = [syncInfoString objectFromJSONString];
            [[NSNotificationCenter defaultCenter] postNotificationName:SyncNotificationVolumeSyncing object:syncInfo];
            
        } else {
            NSMutableDictionary *message = [NSMutableDictionary dictionaryWithCapacity:2];
            [message setObject:nickname forKey:@"nickname"];
            [message setObject:text forKey:@"text"];
            
            [messagesArray addObject:message];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:SyncNotificationNewMessage object:nil];
        }
    }    
}
//- (void)sendTrackIndex:(int)index {
//    NSString *command = [NSString stringWithFormat:@"%@ %d", SyncNotificationTrackIndexChanged, index];
//    [self sendTextMessage:command];
//}
//- (void)sendPlayMessage {
//    [self sendTextMessage:SyncNotificationPlayTrack];
//}
//- (void)sendStopMessage {
//    [self sendTextMessage:SyncNotificationStopPlaying];
//}

- (NSArray*)userlist {
    return userlistArray;
}
- (NSArray*)messages {
    return messagesArray;
}

@end
