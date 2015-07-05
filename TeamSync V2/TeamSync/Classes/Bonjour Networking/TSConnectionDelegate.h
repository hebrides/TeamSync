//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSConnectionDelegate
// Description		:	TSConnectionDelegate class Declaration.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>

@class TSConnection;

@protocol TSConnectionDelegate

- (void) connectionAttemptFailed:(TSConnection*)connection;
- (void) connectionTerminated:(TSConnection*)connection;
- (void) receivedNetworkPacket:(NSDictionary*)message viaConnection:(TSConnection*)connection;

@end
