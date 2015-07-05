
#import <Foundation/Foundation.h>
#import "WebRequestObject.h"

typedef enum {
	WebRequestResponseTypeJSON,
	WebRequestResponseTypeXML,
	WebRequestResponseTypeBinary,
	WebRequestResponseTypeText
} WebRequestResponseType;

typedef enum {
	WebRequestResponseModeData,
	WebRequestResponseModeFileStream,
    WebRequestResponseModeDynamicParsing
} WebRequestResponseMode;

typedef enum {
	WebRequestPriorityLow,
	WebRequestPriorityNormal,
	WebRequestPriorityHigh
} WebRequestPriority;



@class WebRequest;

@protocol WebRequestParserProtocol <NSObject>

- (id) webRequest:(WebRequest*) request parseDataChunk:(NSData*) data error:(NSError**) error;

@end

@protocol WebRequestOAuthSignProtocol <NSObject>

- (BOOL) webRequestShouldSign:(WebRequest*) request;

@end



@interface WebRequest : WebRequestObject <WebRequestObjectProtocol>  {
	
    // Setup URL
    NSURL           *url;
    // or custom 
	NSString		*scheme;
	NSString		*serverAddress;
	NSString		*path;
	NSDictionary	*queryDict;
	NSMutableArray	*pathElements;
    
    
	NSDictionary	*headersDict;
	NSData			*requestBody;
	NSString		*method;
	NSInteger		port;
	NSString		*streamFilePath;
	NSInteger		resumeRange;
	long long		startFileSize;
	BOOL			useGZIP;
	BOOL			resumeLastDownload;
	
	NSOutputStream	*fileStream;
	
    id<WebRequestParserProtocol> dataParser;
    id<WebRequestOAuthSignProtocol> oauthSigner;
    
	WebRequestResponseType	responseType;
	WebRequestResponseMode	responseMode;
	WebRequestPriority		priority;
} 


@property (nonatomic, retain)	NSURL           *url;
@property (nonatomic, retain)	NSString		*serverAddress;
@property (nonatomic, retain)	NSString		*scheme;
@property (nonatomic)			NSInteger		port;
@property (nonatomic, retain)	NSString		*path;
@property (nonatomic, retain)	NSDictionary	*queryDict;
@property (nonatomic, readonly)	NSMutableArray	*pathElements;
@property (nonatomic, retain)	NSDictionary	*headersDict;
@property (nonatomic, retain)	NSData			*requestBody;
@property (nonatomic, retain)	NSString		*streamFilePath;
@property (nonatomic, retain)	NSString		*method;
@property (nonatomic)			NSInteger		resumeRange;
@property (nonatomic, readonly)	long long		startFileSize;


@property (nonatomic)			WebRequestResponseType	responseType;
@property (nonatomic)			WebRequestResponseMode	responseMode;
@property (nonatomic)			WebRequestPriority		priority;
@property (nonatomic)			BOOL useGZIP;
@property (nonatomic)			BOOL resumeLastDownload;
@property (nonatomic, retain)	id<WebRequestParserProtocol> dataParser;
@property (nonatomic, retain)	id<WebRequestOAuthSignProtocol> oauthSigner;


- (BOOL) flushMemoryToStream;
+ (NSString*) createQueryFromDict:(NSDictionary*) querySource;
+ (NSString*) createPathFromArr:(NSArray*) pathElements;

@end


@interface NSObject(StreamedFileDownloadRequest)

//! Initialize a download request
- (void) WebRequest:(WebRequest*) streamedFileDownloadRequest didFailedWithStreamError:(NSError*) error;

@end 

