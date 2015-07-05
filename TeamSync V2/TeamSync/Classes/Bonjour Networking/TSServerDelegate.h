//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSServerDelegate
// Description		:	TSServerDelegate class Declaration.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>

@class TSServer, TSConnection;

@protocol TSServerDelegate

// Server has been terminated because of an error
- (void) serverFailed:(TSServer*)server reason:(NSString*)reason;

// Server has accepted a new connection and it needs to be processed
- (void) handleNewConnection:(TSConnection*)connection;

@end
