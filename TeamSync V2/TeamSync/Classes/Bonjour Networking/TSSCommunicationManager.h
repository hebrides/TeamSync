//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSSCommunicationManager
// Description		:	TSSCommunicationManager class Declaration.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>
#import "TSRoom.h"
#import "TSRoomDelegate.h"
#import "TSLocalRoom.h"
#import "TSCommon.h"
#import "TSProtocols.h"
#import "TSAppController.h"

@interface TSSCommunicationManager : NSObject <TSRoomDelegate>
{
    id<TSSCommunicationManagerDelegate> __unsafe_unretained delegate;
    TSAppController                     *appController;
}

@property(unsafe_unretained) id<TSSCommunicationManagerDelegate> delegate;
@property(nonatomic,retain) TSRoom* chatRoom;
@property(nonatomic,retain) TSLocalRoom *localChatRoom;

- (void)activate;
+ (TSSCommunicationManager *) sharedInstance;

@end
