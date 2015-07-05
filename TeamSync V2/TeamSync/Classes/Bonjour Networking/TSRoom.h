//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSRoom
// Description		:	TSRoom class Declaration.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>
#import "TSRoomDelegate.h"
#import "TSCommon.h"

@interface TSRoom : NSObject
{
  id<TSRoomDelegate> delegate;
}

@property(nonatomic,retain) id<TSRoomDelegate> delegate;

- (BOOL)start;
- (void)stop;
- (void)broadcastChatMessage:(NSString*)message andDetails:(NSDictionary*)dict fromUser:(NSString*)name selectedView:(NSString *)currentView;

@end
