
#import "XMLCollector.h"
#import "XMLCollectorPrivate.h"
#import "IndexedDictionary.h"

@implementation XMLCollector

@synthesize	xmlDocument;
@synthesize xmlContext;
@synthesize knownTypes;
@synthesize attributesKey;
@synthesize typeAtrributeName;
@synthesize storeElementParameters;
@synthesize useIndexedDictionaries;
@synthesize readDateFormatter;
@synthesize defaultOptions;
@synthesize errors;
@synthesize nodeNamesRequireArray;

-(id)init{
	if (self = [super init]){
		xmlDocument = nil;
		typeAtrributeName = [[NSMutableString alloc] initWithString:@"type"];
		attributesKey = [[NSMutableString alloc] initWithString:@"Attributes"];
		storeElementParameters = NO;
		useIndexedDictionaries = NO;
		knownTypes = [[NSMutableArray alloc] initWithObjects: @"", XMLItemType_Array, XMLItemType_String,
																XMLItemType_Boolean, XMLItemType_Integer,
																XMLItemType_Datetime,
																nil];
		defaultOptions = XML_PARSE_NOERROR | XML_PARSE_NOWARNING | XML_PARSE_NOBLANKS;
		readDateFormatter = nil;
		errors = [[NSMutableArray alloc] init];
	}  
	return self;
}

- (void)dealloc{
	[errors release];
	[readDateFormatter release];
	[knownTypes release];
	self.nodeNamesRequireArray = nil;
    if (xmlDocument){
		xmlFreeDoc(xmlDocument);
		xmlCleanupParser();
	}
	[typeAtrributeName release];
	[attributesKey release];
	[super dealloc];
}

-(BOOL)docCreated{
	xmlError * libxmlError = xmlGetLastError();
	if (libxmlError){
			NSString * libxmlErrorDomain = [NSString stringWithFormat:@"%@ #%d", LIBXMLErrorDomain,libxmlError->domain]; 
			[errors addObject:[NSError errorWithDomain:libxmlErrorDomain code:libxmlError->code userInfo:nil]];
		}
	if (xmlDocument == NULL){
		[errors addObject:[NSError errorWithDomain:XMLCollectorErrorDomain code:XMLCollectorErrors_DocNotCreated userInfo:nil]];
		return NO;
	}
	return YES;
}

-(id)parseAndCollectData:(NSData *)data URL:(NSString *)url Encoding:(NSString *)encoding Options:(int)options{ 
	if ([self parseData:data URL:url Encoding:encoding Options:options]){
		return [self collectTree];
	}
	return nil;
}

-(id)parseAndCollectData:(NSData *)data{
	if ([self parseData:data]){
		return [self collectTree];
	}
	return nil;
}

-(id)parseAndCollectFile:(NSString *)fileName Encoding:(NSString *)encoding Options:(int)options{
	if ([self parseFile:fileName Encoding:encoding Options:options]){
		return [self collectTree];
	}
	return nil;
}

-(id)parseAndCollectFile:(NSString *)fileName{
	if ([self parseFile:fileName]){
		return [self collectTree];
	}
	return nil;
}

-(BOOL)parseFile:(NSString *)fileName Encoding:(NSString *)encoding Options:(int)options{
	[self resetDocument];
	xmlDocument = xmlReadFile([fileName UTF8String], [encoding UTF8String], options);
	return [self docCreated];
}

-(BOOL)parseFile:(NSString *)fileName{
	[self resetDocument];
	xmlDocument = xmlReadFile([fileName UTF8String], NULL, defaultOptions);
	return [self docCreated];
}

-(BOOL)parseData:(NSData *)data URL:(NSString *)url Encoding:(NSString *)encoding Options:(int)options{
	[self resetDocument];
	xmlDocument = xmlReadMemory((const char *)[data bytes], [data length],[url UTF8String], [encoding UTF8String], options);
	return [self docCreated];
}

-(BOOL) parseData:(NSData *)data{
    [self resetDocument];
	xmlDocument = xmlReadMemory((const char *)[data bytes], [data length],NULL, NULL, defaultOptions);
	return [self docCreated];
}

-(void)resetDocument{
	if (xmlDocument){
		xmlFreeDoc(xmlDocument);
		[errors removeAllObjects];
	}
}

-(BOOL) beginParseChunks:(NSData *)firstChunk{
	if (xmlContext){
		xmlFreeParserCtxt(xmlContext);
	}
	xmlContext = xmlCreatePushParserCtxt(NULL, NULL, (const char *)[firstChunk bytes], [firstChunk length], NULL); 
	xmlCtxtUseOptions(xmlContext, defaultOptions);
	return xmlContext != NULL;
}

-(id) parseNextChunk:(NSData *)nextChunk AndCollectOnEnd:(BOOL)end{
	if (!xmlContext){
		[self addError:XMLCollectorErrors_NoContext];
		return nil;
	}
	xmlParseChunk(xmlContext, [nextChunk bytes], [nextChunk length], end);
	if (end){
		xmlDocument = xmlContext->myDoc;
		if (![self docCreated]){
			return nil;
		}
		if (!xmlContext->wellFormed){
			[self addError:XMLCollectorErrors_DocNotWellFormed];
			return nil;
		}
		//DbgInfo(@"parsed");
		xmlFreeParserCtxt(xmlContext);
		return [self collectTree];
	}
	return nil;
}

-(void)addError:(int)errorCode{
	[errors addObject:[NSError errorWithDomain:XMLCollectorErrorDomain code:errorCode userInfo:nil]];
}

-(id)collectTree{
	NSMutableDictionary * treeResult = nil;
	xmlNode * root = xmlDocGetRootElement(xmlDocument);
	if (root){
		id rootResult = [self collectNode:xmlDocGetRootElement(xmlDocument)];
		if (rootResult){
			treeResult = [NSMutableDictionary dictionaryWithObject:rootResult 
															forKey:[NSString stringWithUTF8String:(char *)root->name]];
			
		}
	}
	return treeResult;
}

-(id)collectNode:(xmlNode * )node{
	id nodeResult = nil;
	NSMutableDictionary * attributes = [self attributesOfNode:node];
	xmlNode * chNode = node->children;
	if (chNode){
		if (chNode->type == XML_CDATA_SECTION_NODE){
			// CDATA node	
			nodeResult = [NSString stringWithUTF8String:(char *)chNode->content];
		}
		else if (!chNode->next && chNode->type == XML_TEXT_NODE){
			
			nodeResult = [self simpleObjectNode:chNode withAttributes:attributes];
		}
		else {
			// complex data
			NSMutableDictionary * chirdrenResult = [self complexObjectNode:chNode];
			nodeResult = [self formatCollectedChildren:chirdrenResult OfNode:node withAttributes:attributes];
		}
	}
	else{
		if ([self isAttribute:attributes OfType:XMLNodeDataType_Array]){//empty array
			nodeResult = [NSArray  array];
		}
		else{
			nodeResult = @"";//[NSDictionary dictionaryWithObject:@"" forKey:[NSString stringWithUTF8String:(char*)node->name]];
			return [self extendedObject:nodeResult forNode:node withAttributes:attributes];
		}
	}
	return nodeResult;
}
	
-(id)simpleObjectNode:(xmlNode *)node withAttributes:(NSMutableDictionary *)nodeAttributes{
	NSString * typeName = [nodeAttributes objectForKey:typeAtrributeName];
	
	NSString * strData = [[NSString alloc] initWithUTF8String:(char *)node->content];	
	id nodeResult = strData;
	if (typeName){
		if ([typeName isEqualToString:[knownTypes objectAtIndex:XMLNodeDataType_Integer]]){
			NSInteger intData = [strData integerValue] ;
			nodeResult = [NSNumber numberWithInteger:intData];
		}
		else if([typeName isEqualToString:[knownTypes objectAtIndex:XMLNodeDataType_Boolean]]){
			BOOL boolData = [strData boolValue];
			nodeResult = [NSNumber numberWithBool:boolData];
		}
		else if([typeName isEqualToString:[knownTypes objectAtIndex:XMLNodeDataType_Datetime]] && readDateFormatter){
			NSDate * dateData = [readDateFormatter dateFromString:strData];
			if (readDateFormatter){
				nodeResult = dateData;
			}
		}
	}

	if ( nodeResult != strData ) {
		[strData release];
	} else {
		[strData autorelease];
	}
	//DbgInfo(@"simple node %s", node->name );
	//if (node->ns) DbgInfo(@"simple node ns");
	return [self extendedObject:nodeResult forNode:node withAttributes:nodeAttributes];
}

-(id)complexObjectNode:(xmlNode *)node{
	//DbgInfo(@"complex node name %s", node->name );
	id collectedChildren;
	if (useIndexedDictionaries){
		collectedChildren = [[[IndexedDictionary alloc] init] autorelease];
	}
	else{
		collectedChildren = [NSMutableDictionary dictionary];
	}
	
	NSString * chKey;
	xmlNode * nextNode;	
	for (nextNode=node; nextNode; nextNode = nextNode->next) {
		if (!nextNode->name || nextNode->type != XML_ELEMENT_NODE ){
			[errors addObject:[NSError errorWithDomain:XMLCollectorErrorDomain code:XMLCollectorErrors_MixedData userInfo:nil]];  
		}
		else{
			chKey = [[NSString alloc] initWithUTF8String:(char *)nextNode->name];
			id curArray = [collectedChildren objectForKey:chKey];
			if (!curArray){
				curArray = [NSMutableArray array];
				[collectedChildren setObject:curArray forKey:chKey];
			}
			id chResult=[self collectNode:nextNode];
			[curArray addObject:chResult];
			[chKey release];
		}
	}
	return collectedChildren;
}
	
-(id) formatCollectedChildren:(id)children OfNode:(xmlNode *)node withAttributes:(NSMutableDictionary *)nodeAttributes{
	id nodeResult;
	BOOL isArray = [self isAttribute:nodeAttributes OfType:XMLNodeDataType_Array];
	
//	if (!isArray) {
//		isArray = [self isArrayForNode:node];
//	}
	if (useIndexedDictionaries){
		nodeResult = [[[IndexedDictionary alloc] init] autorelease];
		for (int i = 0; i < [children count]; i++){
			NSMutableArray * keyArr = [children objectAtIndex:i];
			id obj;
			if ([keyArr count] > 1 || isArray){
				obj = keyArr;
			}
			else{
				if ([keyArr count])
					obj = [keyArr objectAtIndex:0];
				else{
					obj = nil;
				}
			}
			if (obj)
				[nodeResult addObject:obj forKey:[children keyAtIndex:i]];
		}	
	}
	else{
		nodeResult = [NSMutableDictionary dictionary];
		for (id key in children){
			NSMutableArray * keyArr = [children objectForKey:key];
			id obj;
			if ([keyArr count] > 1 || [self isArrayTag:key]){
				obj = keyArr;
			}
			else{
				if ([keyArr count])
					obj = [keyArr objectAtIndex:0];
				else{
					obj = nil;
				}
			}
			if (obj)
				[nodeResult setObject:obj forKey:key];
			
		}
	}
	return [self extendedObject:nodeResult forNode:node withAttributes:nodeAttributes];
	
}

-(id) extendedObject:(id)object forNode:(xmlNode *)node withAttributes:(NSDictionary *)attributes{
	if (object && storeElementParameters){
		if (attributes && [attributes count]){
			id content = object;
			object = [NSMutableDictionary dictionary];
			if ([content isKindOfClass:[NSDictionary class]] && [[content allKeys] count]) {
				[object addEntriesFromDictionary:content];
			}
			
			if (attributes && [attributes count]) {
				if ([attributes isKindOfClass:[NSDictionary class]]) {
					[object addEntriesFromDictionary:attributes];
				}
			}
		}
	}
	
	return object;
}


-(NSMutableDictionary *)attributesOfNode:(xmlNode *)node{
    xmlAttr * nodeAttr;
	NSMutableDictionary * attibutes = [NSMutableDictionary dictionary];
	NSString * attrName = [NSString string];
	NSString * attrValue = [NSString string];
	for(nodeAttr=node->properties; nodeAttr; nodeAttr = nodeAttr->next){
		attrName = [NSString stringWithUTF8String:(char *)nodeAttr->name];
		if (nodeAttr->children){
			attrValue = [NSString stringWithUTF8String:(char *)nodeAttr->children->content];
		}
		[attibutes setObject:attrValue forKey:attrName];
	}
	return attibutes;
}

-(BOOL)isAttribute:(NSMutableDictionary *)attributes OfType:(XMLNodeDataType)type{
	
	NSString * typeAttr = [attributes objectForKey:typeAtrributeName];
	if (typeAttr){
		if ([typeAttr isEqualToString:[knownTypes objectAtIndex:type]]){
			return YES;
		}
	}
	return NO;
}
-(BOOL)isArrayTag:(NSString*)key {
	if (key == nil) {
		return NO;
	}
	for (NSString *requireName in nodeNamesRequireArray) {
		if ([requireName isEqualToString:key]) {
			return YES;
		}
	}
	return NO;
}
@end









