//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSSCommunicationManager.m
// Description		:	TSSCommunicationManager class Implementation.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import "TSSCommunicationManager.h"
#import "TSClientSongListViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation TSSCommunicationManager
@synthesize chatRoom;
@synthesize localChatRoom;
@synthesize delegate;

static TSSCommunicationManager * instance = nil;


+ (TSSCommunicationManager *) sharedInstance
{
    if( instance == nil )
    {
        instance = [[TSSCommunicationManager alloc] init];
    }
    return instance;
}

- (void)activate
{
    if ( chatRoom != nil )
    {
        chatRoom.delegate = self;
        [chatRoom start];
    }
}
//
//- (void)displayChatMessage:(NSString*)message andDetails:(NSDictionary*)dict fromUser:(NSString*)userName forView:(NSString*)viewTag
//{
//    if([viewTag isEqualToString:kConnectionStatus])
//    {
//        if(![message isEqualToString:@""] && [message isEqualToString:@"Connection_Success"])
//        {
//            NSString *displayAlert = [NSString stringWithFormat:@"You are now joined to %@",userName];
//            if([[TSAppConfig getInstance].type isEqualToString:@"Client"])
//            {
//                [TSCommon showAlert:displayAlert];
//                [delegate showDisconnectButton];
//            }
//            
//        }
//        else if(![message isEqualToString:@""] && [message isEqualToString:@"Connection_Failed"])
//        {
//            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:APP_NAME message:(NSString *)dict delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//            [alert show];
//            [delegate hideProgressView];
//        }
//        else if(![message isEqualToString:@""] && ![message isEqualToString:@"Connection_Success"])
//        {
//            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:APP_NAME message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//            [alert show];
//        }
//    }
//    else if([viewTag isEqualToString:kSongListView])
- (void)displayChatMessage:(NSString*)message andDetails:(NSDictionary*)dict fromUser:(NSString*)userName forView:(NSString*)viewTag
{
    appController = [TSAppController sharedAppController];
    
    if([viewTag isEqualToString:kConnectionAcceptance])
    {
        NSDictionary *devicetimeInfo = dict;
        appController.deviceTime = [devicetimeInfo objectForKey:MASTER_DEVICE_TIME];
        
        NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
        [dateFormatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss +0000"];
        NSDate *Masterdate = [dateFormatter1 dateFromString:appController.deviceTime];
        
        NSDate *systemTime = [NSDate date];
        NSString *clientDeviceTime = [NSString stringWithFormat:@"%@", systemTime];
        NSDate *Clientdate = [dateFormatter1 dateFromString:clientDeviceTime];
        
        NSTimeInterval timeDiff = [Clientdate timeIntervalSinceDate:Masterdate];
        
        if(Masterdate != nil)
            appController.deviceTimeDiff = timeDiff;
        
//        if(timeDiff > 0 && Masterdate != nil)
//            appController.deviceTimeDiff = timeDiff;
//        
//        else if(timeDiff < 0 && Masterdate != nil)
//            appController.deviceTimeDiff = fabs(timeDiff);
        
        NSLog(@"appController.deviceTimeDiff = %f", appController.deviceTimeDiff);
    }
    else if([viewTag isEqualToString:kConnectionStatus])
    {
        NSDictionary *devicetimeInfo = dict;
        appController.deviceTime = [devicetimeInfo objectForKey:MASTER_DEVICE_TIME];
        
        NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
        [dateFormatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss +0000"];
        NSDate *Masterdate = [dateFormatter1 dateFromString:appController.deviceTime];
        
        NSDate *systemTime = [NSDate date];
        NSString *clientDeviceTime = [NSString stringWithFormat:@"%@", systemTime];
        NSDate *Clientdate = [dateFormatter1 dateFromString:clientDeviceTime];
        
        NSTimeInterval timeDiff = [Clientdate timeIntervalSinceDate:Masterdate];
        
        if(Masterdate != nil)
            appController.deviceTimeDiff = timeDiff;
        
//        if(timeDiff > 0 && Masterdate != nil)
//            appController.deviceTimeDiff = timeDiff;
//        
//        else if(timeDiff < 0)
//            appController.deviceTimeDiff = fabs(timeDiff);
        
        NSLog(@"appController.deviceTimeDiff = %f", appController.deviceTimeDiff);
        
        if(![message isEqualToString:@""] && [message isEqualToString:@"Connection_Success"])
        {
            NSString *displayAlert = [NSString stringWithFormat:@"You are now joined to %@",userName];
            if([[TSAppConfig getInstance].type isEqualToString:@"Client"])
            {
                [TSCommon showAlert:displayAlert];
                [delegate showDisconnectButton];
            }
        }
        else if(![message isEqualToString:@""] && [message isEqualToString:@"Connection_Failed"])
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:APP_NAME message:(NSString *)dict delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            [delegate hideProgressView];
        }
        else if(![message isEqualToString:@""] && ![message isEqualToString:@"Connection_Success"])
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:APP_NAME message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
        }
    }
    else if([viewTag isEqualToString:kSongListView])
    {
        if([[TSAppConfig getInstance].type isEqualToString:@"Client"])
        {
            [delegate showSongList:dict];
        }
    }
    else if([viewTag isEqualToString:kSongDetailsView])
    {
        if([[TSAppConfig getInstance].type isEqualToString:@"Client"])
        {
            [delegate showSongDetailsScreen:dict];
        }
    }
    else if([viewTag isEqualToString:kSongStateChanges])
    {
        if([[TSAppConfig getInstance].type isEqualToString:@"Client"])
            [delegate didChangedPlayState:dict];
    }
    else if([viewTag isEqualToString:kSongVolumeChanges])
    {
        if([[TSAppConfig getInstance].type isEqualToString:@"Client"])
            [delegate didChangedSongvolume:message];
    }
    else if([viewTag isEqualToString:kSongDurationChanges])
    {
        if([[TSAppConfig getInstance].type isEqualToString:@"Client"])
            [delegate didChangedSongDuration:dict];
    }
    else if([viewTag isEqualToString:kSongDetailsInSongList])
    {
        if([[TSAppConfig getInstance].type isEqualToString:@"Client"])
            [delegate showSongListWithMusic:dict];
    }
    else if([viewTag isEqualToString:kSongDetailsResetSlider])
    {
        if([[TSAppConfig getInstance].type isEqualToString:@"Client"])
            [delegate showSongListWithMusic:dict];
    }
    
}

- (void)roomTerminated:(id)room reason:(NSString*)reason
{
    // Explain what happened
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:APP_NAME message:reason delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
    
    appController = [TSAppController sharedAppController];
    if(appController.musicPlayer != nil)
    {
        if(appController.musicPlayer.playbackState == MPMusicPlaybackStatePlaying)
        {
            [appController.musicPlayer pause];
        }
    }

    if([reason isEqualToString:@"Master with same name already exists."])
    {
        [appController showSignInScreen];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ConnectionTerminatedNotification" object:self];
    }
}

- (void) removeClientFromArray
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ClientArrayModifiedNotification" object:self];
}

@end
