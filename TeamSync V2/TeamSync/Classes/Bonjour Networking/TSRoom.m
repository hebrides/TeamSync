//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSRoom
// Description		:	TSRoom class Implementation.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import "TSRoomDelegate.h"
#import "TSRoom.h"


@implementation TSRoom
@synthesize delegate;

// Cleanup
- (void)dealloc
{
  self.delegate = nil;
  [super dealloc];
}


// "Abstract" methods
- (BOOL)start
{
  // Crude way to emulate "abstract" class
  [self doesNotRecognizeSelector:_cmd];
  return NO;
}

- (void)stop
{
  // Crude way to emulate "abstract" class
  [self doesNotRecognizeSelector:_cmd];
}

- (void)broadcastChatMessage:(NSString*)message andDetails:(NSDictionary*)dict fromUser:(NSString*)name selectedView:(NSString *)currentView
{
  // Crude way to emulate "abstract" class
  [self doesNotRecognizeSelector:_cmd];
}

@end
