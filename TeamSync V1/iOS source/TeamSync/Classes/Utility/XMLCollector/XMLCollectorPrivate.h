/*
 *  XMLCollectorPrivate.h
 *  Animoto
 *
 */
#import "XMLCollector.h"


//!private functions of XMLCollector
@interface XMLCollector (Private)

-(BOOL)parseFile:(NSString *)fileName Encoding:(NSString *)encoding Options:(int)options;
-(BOOL)parseFile:(NSString *)fileName;
-(BOOL)parseData:(NSData *)data URL:(NSString *)url Encoding:(NSString *)encoding Options:(int)options;
-(BOOL)parseData:(NSData *)data; 
-(void)resetDocument;
-(id)collectTree;
-(id)collectNode:(xmlNode * )node;
-(id)simpleObjectNode:(xmlNode *)node withAttributes:(NSMutableDictionary *)nodeAttributes;
-(id)complexObjectNode:(xmlNode *)node;
-(id) extendedObject:(id)object forNode:(xmlNode *)node withAttributes:(NSDictionary *)attributes;
-(id) formatCollectedChildren:(id)children OfNode:(xmlNode *)node withAttributes:(NSMutableDictionary *)nodeAttributes;
-(NSMutableDictionary *)attributesOfNode:(xmlNode *)node;
-(BOOL)isAttribute:(NSMutableDictionary *)attributes OfType:(XMLNodeDataType)type;
-(BOOL)isArrayTag:(NSString*)key;
-(void)addError:(int)errCode;


@end

