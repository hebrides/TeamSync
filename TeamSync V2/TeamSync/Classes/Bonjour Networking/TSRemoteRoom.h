//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSRemoteRoom
// Description		:	TSRemoteRoom class Declaration.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>
#import "TSRoom.h"
#import "TSConnection.h"
#import "TSCommon.h"

@interface TSRemoteRoom : TSRoom <TSConnectionDelegate>
{
  // Our connection to the chat server
  TSConnection* connection;
}

// Initialize with host address and port
- (id)initWithHost:(NSString*)host andPort:(int)port;

// Initialize with a reference to a net service discovered via Bonjour
- (id)initWithNetService:(NSNetService*)netService;

@end
