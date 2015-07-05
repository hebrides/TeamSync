//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSServerBrowser
// Description		:	TSServerBrowser class Declaration.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>

@class TSServerBrowserDelegate;

@interface TSServerBrowser : NSObject <NSNetServiceBrowserDelegate>
{
  NSNetServiceBrowser* netServiceBrowser;
  NSMutableArray* servers;
  id<TSServerBrowserDelegate> delegate;
}

@property(nonatomic,readonly) NSArray* servers;
@property(nonatomic,retain) id<TSServerBrowserDelegate> delegate;

// Start browsing for Bonjour services
- (BOOL)start;

// Stop everything
- (void)stop;

@end
