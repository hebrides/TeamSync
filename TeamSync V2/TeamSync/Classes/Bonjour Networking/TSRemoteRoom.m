//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSRemoteRoom
// Description		:	TSRemoteRoom class Implementation.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import "TSRemoteRoom.h"

// Private properties
@interface TSRemoteRoom ()
@property(nonatomic,retain) TSConnection* connection;
@end

@implementation TSRemoteRoom
@synthesize connection;

// Setup connection but don't connect yet
- (id)initWithHost:(NSString*)host andPort:(int)port
{
  connection = [[TSConnection alloc] initWithHostAddress:host andPort:port];
  return self;
}


// Initialize and connect to a net service
- (id)initWithNetService:(NSNetService*)netService
{
  connection = [[TSConnection alloc] initWithNetService:netService];
  return self;
}


// Cleanup
- (void)dealloc
{
  self.connection = nil;
  [super dealloc];
}


// Start everything up, connect to server
- (BOOL)start
{
  if ( connection == nil )
  {
    return NO;
  }
  
  // We are the delegate
  connection.delegate = self;
  
  return [connection connect];
}


// Stop everything, disconnect from server
- (void)stop
{
  if ( connection == nil )
  {
    return;
  }
  
  [connection close];
  self.connection = nil;
}


// Send chat message to the server
- (void)broadcastChatMessage:(NSString*)message andDetails:(NSDictionary*)dict fromUser:(NSString*)name selectedView:(NSString *)currentView
{
  // Create network packet to be sent to all clients
  NSDictionary* packet = [NSDictionary dictionaryWithObjectsAndKeys:message, COMM_MESSAGE, name, MASTER_NAME, currentView, SELECTED_VIEWTAG, dict, MESSAGE_DETAILS, nil];

  // Send it out
  [connection sendNetworkPacket:packet];
}


#pragma mark -
#pragma mark TSConnectionDelegate Method Implementations

- (void)connectionAttemptFailed:(TSConnection*)connection
{
  [delegate roomTerminated:self reason:@"Wasn't able to connect to server"];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"JoinRequestRejected" object:self];
}

- (void)connectionTerminated:(TSConnection*)connection
{
    [delegate roomTerminated:self reason:@"Connection to server closed"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"JoinRequestRejected" object:self];
}


- (void)receivedNetworkPacket:(NSDictionary*)packet viaConnection:(TSConnection*)connection
{
    // Display message locally
    
//    NSLog(@"Counting....");

    if([packet objectForKey:SONGLIST_VIEW_UNIQUE_ID] && ![packet objectForKey:@"Playstatus"]) // SongList Screen
    {
        [delegate displayChatMessage:@"" andDetails:packet fromUser:@"" forView:kSongListView];
    }
    else if([packet objectForKey:SONGDETAILS_VIEW_UNIQUE_ID])
    {
        [delegate displayChatMessage:@"" andDetails:packet fromUser:@"" forView:kSongDetailsView];
    }
    else if([packet objectForKey:DUMMY_INFO])
    {
        
    }
    else
    {
        NSString *packetMessage = @"";
        if([packet objectForKey:@"message"])
        {
            packetMessage = [packet objectForKey:@"message"];
        }

        if([packetMessage isEqualToString:@"Connection_Success"] || [packetMessage isEqualToString:@"ConnectionAccepted"])
        {
            [delegate displayChatMessage:[packet objectForKey:COMM_MESSAGE] andDetails:packet fromUser:[packet objectForKey:MASTER_NAME] forView:[packet objectForKey:SELECTED_VIEWTAG]];
        }
        else
            [delegate displayChatMessage:[packet objectForKey:COMM_MESSAGE] andDetails:[packet objectForKey:MESSAGE_DETAILS] fromUser:[packet objectForKey:MASTER_NAME] forView:[packet objectForKey:SELECTED_VIEWTAG]];
        
        if([[packet objectForKey:COMM_MESSAGE] isEqualToString:@"Connection_Success"])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"JoinRequestApproval" object:self];
        }
    }

   

}


@end
