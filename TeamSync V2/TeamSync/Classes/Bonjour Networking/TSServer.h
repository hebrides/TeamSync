//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSServer
// Description		:	TSServer class Declaration.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>
#import "TSServerDelegate.h"
#import "TSAppConfig.h"
#import "TSCommon.h"

@interface TSServer : NSObject <NSNetServiceDelegate>
{
    uint16_t port;
    CFSocketRef listeningSocket;
    id<TSServerDelegate> delegate;
    NSNetService* netService;
}

// Initialize and start listening for connections
- (BOOL)start;
- (void)stop;

// Delegate receives various notifications about the state of our server
@property(nonatomic,retain) id<TSServerDelegate> delegate;

@end
