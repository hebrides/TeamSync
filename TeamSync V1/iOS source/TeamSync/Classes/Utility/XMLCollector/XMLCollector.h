
#import <Foundation/Foundation.h>
#import <libxml/tree.h>


#define XMLCollectorErrorDomain @"XMLCollector"
#define LIBXMLErrorDomain @"LIBXMLErrorDomain"

#define XMLItemType_Array @"array"
#define XMLItemType_String @"string"
#define XMLItemType_Boolean @"boolean"
#define XMLItemType_Integer @"integer"
#define XMLItemType_Datetime @"datetime"

#define XML_Tag @"XML_Tag"
#define XML_Tag_Extended @"XML_Tag_Extended"


typedef enum {
    XMLNodeDataType_None = 0,
	XMLNodeDataType_Array = 1,
	XMLNodeDataType_String = 2,
	XMLNodeDataType_Boolean = 3,
	XMLNodeDataType_Integer = 4, 
	XMLNodeDataType_Datetime = 5
	//XMLNodeDataType_Data = 6
} XMLNodeDataType;

typedef enum {
    XMLCollectorErrors_Unknown = 0,
	XMLCollectorErrors_BadXML = 1,
	XMLCollectorErrors_DocNotCreated = 2,
	XMLCollectorErrors_DocNotWellFormed = 3,
	XMLCollectorErrors_NoContext = 4,
	XMLCollectorErrors_MixedData = 101
} XMLCollectorErrors;

/*! XMLCollector allows parse
XML document to c-struct tree
and then translate this tree into
NSFoundation dictionary/array tree */
@interface XMLCollector : NSObject {
	//todo possible hanling of attributes key conflict with tags

	xmlDocPtr xmlDocument;
	xmlParserCtxtPtr xmlContext;
	NSMutableArray * knownTypes;
	NSMutableString * attributesKey;
	BOOL storeElementParameters;
	NSMutableString * typeAtrributeName;
	NSDateFormatter * readDateFormatter; 
	NSMutableArray * errors;
	NSInteger defaultOptions;
	BOOL useIndexedDictionaries;
	NSArray *nodeNamesRequireArray;
}

@property (nonatomic, readonly)	xmlDocPtr xmlDocument;
@property (nonatomic, readonly)	xmlParserCtxtPtr xmlContext;
@property (nonatomic, readonly)	NSMutableArray * knownTypes;
@property (nonatomic, readonly)	NSMutableString * attributesKey;
@property (nonatomic, readonly)	NSMutableString * typeAtrributeName;
@property (nonatomic, readonly)	NSDateFormatter * readDateFormatter;
 
//! contains list of all errors occured during parse or collect process
@property (nonatomic, readonly)	NSMutableArray * errors;


//! nodes named like names in this array will be Arrays in result tree
@property (nonatomic, retain) NSArray *nodeNamesRequireArray;
//! if this flag YES each node will be a dictionary with attributes, namespace and content subobjects
//! otherwise only contente of node will be stored in node object itself
@property (nonatomic) BOOL storeElementParameters;

//! if this flag YES each dictionary-type node will be stored in IndexedDictionaries object
@property (nonatomic) BOOL useIndexedDictionaries;

@property (nonatomic) NSInteger defaultOptions;

//@{
/*! Parse and collect xml document to dictionary.
If critical error occure return nil. Using XML */
//! from file "fileName", with specified encoding and options 
-(id)parseAndCollectFile:(NSString *)fileName Encoding:(NSString *)encoding Options:(int)options;

//! from file "fileName", with UTF-8 encoding and default options
-(id)parseAndCollectFile:(NSString *)fileName;

//! from "data", with specified URL, encoding and options 
-(id)parseAndCollectData:(NSData *)data URL:(NSString *)url Encoding:(NSString *)encoding Options:(int)options;

//! from "data", with UTF-8 encoding and default options
-(id)parseAndCollectData:(NSData*)data;
//@{

-(BOOL) beginParseChunks:(NSData *)firstChunk; 
-(id) parseNextChunk:(NSData *)nextChunk AndCollectOnEnd:(BOOL)end;

@end

