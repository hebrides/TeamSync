//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSLocalRoom
// Description		:	TSLocalRoom class Implementation.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import "TSLocalRoom.h"
#import "TSConnection.h"
#import "TSCommon.h"

// Private properties
@interface TSLocalRoom ()
@property(nonatomic,retain) TSServer* server;
@property(nonatomic,retain) NSMutableSet* clients;
@end


@implementation TSLocalRoom
@synthesize server, clients,tempConnection;
@synthesize clientSet;
@synthesize clientArr;
@synthesize connectionArray,tempConnectionArr;

// Initialization
- (id)init
{
    //clients = [[NSMutableSet alloc] init];
    self.clientSet = [[NSMutableOrderedSet alloc] init];
    self.clientArr = [[NSMutableArray alloc]init];
    self.connectionArray = [[NSMutableArray alloc]init];
    self.tempConnectionArr = [[NSMutableArray alloc]init];
    self.tempclientArr = [[NSMutableArray alloc]init];
    return self;
}


// Cleanup
- (void)dealloc
{
    self.clients = nil;
    self.server = nil;
    self.tempConnection = nil;
    self.clientSet = nil;
    self.clientArr = nil;
    self.connectionArray = nil;
    self.tempConnectionArr = nil;
    self.tempclientArr = nil;
    [super dealloc];
}


// Start the server and announce self
- (BOOL)start
{
    // Create new instance of the server and start it up
    server = [[TSServer alloc] init];
    
    // We will be processing server events
    server.delegate = self;
    
    // Try to start it up
    if ( ! [server start] )
    {
        self.server = nil;
        return NO;
    }
    
    return YES;
}


// Stop everything
- (void)stop
{
    // Destroy server
    [server stop];
    self.server = nil;
    
    // Close all connections
    //[clients makeObjectsPerformSelector:@selector(close)];
    for(id connection in [clients allObjects])
    {
        [connection close];
    }
}


// Send chat message to all connected clients
- (void)broadcastChatMessage:(NSString*)message andDetails:(NSDictionary*)dict fromUser:(NSString*)name selectedView:(NSString *)currentView
{
    
   NSString *tablePos = @"";
    if([dict objectForKey:@"YPosition"])
    {
        tablePos = [dict objectForKey:@"YPosition"];
         
    }
     NSDictionary *packet = [NSDictionary dictionaryWithObjectsAndKeys:message, COMM_MESSAGE, name, MASTER_NAME, currentView, SELECTED_VIEWTAG, dict, MESSAGE_DETAILS, tablePos, TABLE_YPOS, nil];

  // Create network packet to be sent to all clients
 
    
    for(id connection in [clients allObjects])
    {
        [connection sendNetworkPacket:packet];
    }
}


#pragma mark -
#pragma mark ServerDelegate Method Implementations

// Server has failed. Stop the world.
- (void) serverFailed:(TSServer*)server reason:(NSString*)reason
{
    // Stop everything and let our delegate know
    [self stop];
    [delegate roomTerminated:self reason:reason];
}


// New client connected to our server. Add it.
- (void) handleNewConnection:(TSConnection*)connection
{
    // Delegate everything to us
    //connection.delegate = self;
    //  // Add to our list of clients
    //  [clients addObject:connection];
    
    [self.tempConnectionArr addObject:connection];
    self.tempConnection = [self.tempConnectionArr objectAtIndex:self.tempConnectionArr.count - 1];
    self.tempConnection.delegate = self;
}

#pragma mark -
#pragma mark UIAlertView Method

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    appController = [TSAppController sharedAppController];
    
    NSDate *systemTime = [NSDate date];
    NSString *devicetime = [NSString stringWithFormat:@"%@", systemTime];
    
    NSInteger rowCount = 0;
    if(self.connectionArray && self.connectionArray.count > 0)
    {
        rowCount = self.connectionArray.count - 1;
        if(buttonIndex == 1)
        {
            [self.clientSet addObject:[self.connectionArray objectAtIndex:rowCount]];
            [self.clientArr addObject:[self.tempclientArr objectAtIndex:rowCount]];
            
            NSInteger clientsAvailable = self.clientArr.count;
            appController.clientCount = clientsAvailable;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"changeConnectButton" object:self];
            
            NSString *masterName = [TSAppConfig getInstance].name;
            TSConnection *objConnection = [self.connectionArray objectAtIndex:rowCount];
            NSDictionary* packet = [NSDictionary dictionaryWithObjectsAndKeys:@"ConnectionAccepted", @"message", masterName, @"from", kConnectionAcceptance ,SELECTED_VIEWTAG, devicetime, MASTER_DEVICE_TIME, nil];
            [objConnection sendNetworkPacket:packet];
            
            appController = [TSAppController sharedAppController];
            if(appController.isBroadcasted)
            {
                appController.isCalledSongView = YES;
                float volumeData = appController.musicPlayer.volume;
                NSString *volumeInfo = [NSString stringWithFormat:@"%f",volumeData];
                
                double newInterval = appController.musicPlayer.currentPlaybackTime;
                newInterval = newInterval + 0.09;
                NSString *intervalString = [NSString stringWithFormat:@"%f", newInterval];
                
                NSString *info = [NSString stringWithFormat: @"%02d:%02d",
                                  (int) newInterval/60,
                                  (int) newInterval%60];
                NSLog(@"duration = %@", info);
                
                [[TSAppConfig getInstance].songInformationDict setValue:volumeInfo forKey:PLAYER_VOLUME];
                [[TSAppConfig getInstance].songInformationDict setValue:intervalString forKey:PLAY_DURATION];
                [[TSAppConfig getInstance].songInformationDict setValue:devicetime forKey:MASTER_DEVICE_TIME];
                
 //               NSDictionary *ads = [TSAppConfig getInstance].songInformationDict;
                [objConnection sendNetworkPacket:[TSAppConfig getInstance].songInformationDict];
            }
            
        }
        else
        {
            TSConnection *tmpConnection = [self.connectionArray objectAtIndex:rowCount];
            [tmpConnection close];
        }
        [self.tempclientArr removeObjectAtIndex:rowCount];
        [delegate removeClientFromArray];
        
        self.clients =(NSMutableSet *) self.clientSet;
        
        NSString *masterName = [TSAppConfig getInstance].name;
        
        TSConnection *objConnection = [self.connectionArray objectAtIndex:rowCount];
        NSDictionary* packet = [NSDictionary dictionaryWithObjectsAndKeys:@"Connection_Success", COMM_MESSAGE, masterName, MASTER_NAME, kConnectionStatus ,SELECTED_VIEWTAG, @"", MESSAGE_DETAILS, devicetime, MASTER_DEVICE_TIME, nil];
        [objConnection sendNetworkPacket:packet];
        
//        if(appController.isCalledSongView)
//        {
//            if(appController.isBroadcasted)
//            {
//                float volumeData = appController.musicPlayer.volume;
//                NSString *volumeInfo = [NSString stringWithFormat:@"%f",volumeData];
//                NSString *intervalString = [NSString stringWithFormat:@"%f", appController.musicPlayer.currentPlaybackTime];
//                
//                [[TSAppConfig getInstance].songInformationDict setValue:volumeInfo forKey:PLAYER_VOLUME];
//                [[TSAppConfig getInstance].songInformationDict setValue:intervalString forKey:PLAY_DURATION];
//                [[TSAppConfig getInstance].songInformationDict setValue:devicetime forKey:MASTER_DEVICE_TIME];
//                
//                //               NSDictionary *ads = [TSAppConfig getInstance].songInformationDict;
//                [objConnection sendNetworkPacket:[TSAppConfig getInstance].songInformationDict];
//            }
//        }

        
        //Cleaning the objects in connectionarr and tempconnectionarr
        for(TSConnection *objConn in self.tempConnectionArr)
        {
            if(objConn == [self.connectionArray objectAtIndex:rowCount])
            {
                [self.tempConnectionArr removeObject:objConn];
                break;
            }
        }
        
        [self.connectionArray removeObjectAtIndex:rowCount];
    }
}

#pragma mark -
#pragma mark ConnectionDelegate Method Implementations

// We won't be initiating connections, so this is not important
- (void) connectionAttemptFailed:(TSConnection*)connection
{
}


// One of the clients disconnected, remove it from our list
- (void) connectionTerminated:(TSConnection*)connection
{
    
    int i = 0;
    for(TSConnection *conn in clients)
    {
        if(conn == connection)
        {
            [clients removeObject:conn];
            [self.clientArr removeObjectAtIndex:i];
            break;
        }
        i++;
    }
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ClientArrayModifiedNotification" object:self];
}


// One of connected clients sent a chat message. Propagate it further.
- (void) receivedNetworkPacket:(NSDictionary*)packet viaConnection:(TSConnection*)connection
{
    if([packet objectForKey:@"SelectedView"] && [[packet objectForKey:@"SelectedView"] isEqualToString:kConnectionStatus])
    {
        TSAppConfig *objConfig = [TSAppConfig getInstance];
        if(!objConfig.isEnteredBackGround)
        {
            if(self.tempConnectionArr && self.tempConnectionArr.count > 0)
            {
                for(TSConnection *conn in self.tempConnectionArr)
                {
                    if(connection == conn)
                    {
                        [self.connectionArray addObject:connection];
                    }
                }
            }
            
            [self.tempclientArr addObject:[packet objectForKey:MASTER_NAME]];
            [delegate displayChatMessage:[packet objectForKey:COMM_MESSAGE] andDetails:[packet objectForKey:MESSAGE_DETAILS]  fromUser:[packet objectForKey:MASTER_NAME] forView:[packet objectForKey:SELECTED_VIEWTAG]];
            
            for(id connection in [clients allObjects])
            {
                [connection sendNetworkPacket:packet];
            }
            
            NSString *alertMessage = [NSString stringWithFormat:@"'%@' wants to join you!",[self.tempclientArr objectAtIndex:self.tempclientArr.count - 1]];
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:APP_NAME
                                                            message:alertMessage
                                                           delegate:self
                                                  cancelButtonTitle:@"Decline"
                                                  otherButtonTitles:@"Allow", nil];
            [alert show];
            [alert release];
        }
        else
        {
            NSDictionary* packet = [NSDictionary dictionaryWithObjectsAndKeys:@"Connection_Failed", COMM_MESSAGE, [TSAppConfig getInstance].name, MASTER_NAME, kConnectionStatus ,SELECTED_VIEWTAG, [NSString stringWithFormat:@"%@ is not active, Please try later!",[TSAppConfig getInstance].name], MESSAGE_DETAILS, nil];
            [connection sendNetworkPacket:packet];
        }
    }
}

@end
