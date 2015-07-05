//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSAppConfig.m
// Description		:	TSCommTSAppConfig class Implementation.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import "TSAppConfig.h"

static TSAppConfig* instance;

@implementation TSAppConfig
@synthesize name;
@synthesize type;
@synthesize songInformationDict;
@synthesize isEnteredBackGround;

// Initialization
- (id) init
{
    self.name = @"unknown";
    self.type = @"";
    self.songInformationDict = nil;
    return self;
}

// Automatically initialize if called for the first time
+ (TSAppConfig*) getInstance
{
    @synchronized([TSAppConfig class])
    {
        if ( instance == nil )
        {
            instance = [[TSAppConfig alloc] init];
        }
    }
    
    return instance;
}

@end
