//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSAppConfig.h
// Description		:	TSAppConfig class Declaration.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>

@interface TSAppConfig : NSObject
{
    NSString* name;
    NSString* type;
    BOOL isEnteredBackGround;
}

@property (retain) NSString* name;
@property (retain) NSString* type;
@property (retain) NSDictionary *songInformationDict;
@property (assign) BOOL isEnteredBackGround;

// Singleton - one instance for the whole app
+ (TSAppConfig*)getInstance;

@end
