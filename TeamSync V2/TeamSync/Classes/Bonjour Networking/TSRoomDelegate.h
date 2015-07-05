//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSRoomDelegate
// Description		:	TSRoomDelegate class Declaration.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>

@class TSRoom;

@protocol TSRoomDelegate
@optional
- (void) displayChatMessage:(NSString*)message andDetails:(NSDictionary*)dict fromUser:(NSString*)userName forView:(NSString*)viewTag;
- (void) roomTerminated:(id)room reason:(NSString*)string;
- (void) removeClientFromArray;
@end
