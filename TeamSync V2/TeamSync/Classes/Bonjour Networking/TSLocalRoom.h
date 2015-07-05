//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSLocalRoom
// Description		:	TSLocalRoom class Declaration.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>
#import "TSRoom.h"
#import "TSServer.h"
#import "TSServerDelegate.h"
#import "TSConnectionDelegate.h"
#import "TSCommon.h"
#import "TSAppController.h"

@interface TSLocalRoom : TSRoom <TSServerDelegate, TSConnectionDelegate>
{
    // We accept connections from other clients using an instance of the Server class
    TSServer* server;
    
    // Container for all connected clients
    NSMutableSet* clients;
    TSAppController *appController;
}
@property (nonatomic,retain) NSMutableArray *connectionArray;
@property (nonatomic,retain) TSConnection *tempConnection;
@property (nonatomic,retain) NSMutableOrderedSet *clientSet;
@property (nonatomic,retain) NSMutableArray *clientArr;
@property (nonatomic,retain) NSMutableArray *tempclientArr;
@property (nonatomic,retain) NSMutableArray *tempConnectionArr;

// Initialize everything
- (id)init;

@end
