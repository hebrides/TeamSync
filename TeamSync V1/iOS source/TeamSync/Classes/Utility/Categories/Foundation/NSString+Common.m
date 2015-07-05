
#import "NSString+Common.h"


@implementation NSString (Common)

static char base64EncodingTable[64] = {
	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
	'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
	'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
	'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
};


+ (NSString *) base64StringFromData:(NSData*)data {
	int lentext = [data length]; 
	if (lentext < 1) return @"";
	
	char *outbuf = malloc(lentext*4/3+4); // add 4 to be sure
	
	if ( !outbuf ) return nil;
	
	const unsigned char *raw = [data bytes];
	
	int inp = 0;
	int outp = 0;
	int do_now = lentext - (lentext%3);
	
	for ( outp = 0, inp = 0; inp < do_now; inp += 3 )
	{
		outbuf[outp++] = base64EncodingTable[(raw[inp] & 0xFC) >> 2];
		outbuf[outp++] = base64EncodingTable[((raw[inp] & 0x03) << 4) | ((raw[inp+1] & 0xF0) >> 4)];
		outbuf[outp++] = base64EncodingTable[((raw[inp+1] & 0x0F) << 2) | ((raw[inp+2] & 0xC0) >> 6)];
		outbuf[outp++] = base64EncodingTable[raw[inp+2] & 0x3F];
	}
	
	if ( do_now < lentext )
	{
		unsigned char tmpbuf[2] = {0,0};
		int left = lentext%3;
		for ( int i=0; i < left; i++ )
		{
			tmpbuf[i] = raw[do_now+i];
		}
		raw = tmpbuf;
		outbuf[outp++] = base64EncodingTable[(raw[inp] & 0xFC) >> 2];
		outbuf[outp++] = base64EncodingTable[((raw[inp] & 0x03) << 4) | ((raw[inp+1] & 0xF0) >> 4)];
		if ( left == 2 ) outbuf[outp++] = base64EncodingTable[((raw[inp+1] & 0x0F) << 2) | ((raw[inp+2] & 0xC0) >> 6)];
	}
	
	NSString *ret = [[[NSString alloc] initWithBytes:outbuf length:outp encoding:NSASCIIStringEncoding] autorelease];
	free(outbuf);
	
	return ret;
}

+ (id)stringWithUUID {
	CFUUIDRef uuid = CFUUIDCreate(NULL);
	NSString *uString = (NSString *)CFUUIDCreateString(NULL, uuid);
	CFRelease(uuid);
	return [uString autorelease];
}

- (NSString *)stringWithBundlePath{
	return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:self];
}

+ (id)pathToBundleFile:(NSString *)aFileName{
	return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:aFileName];
}

+ (id)stringFromBundleFile:(NSString *)aFileName{
	return [NSString stringWithContentsOfFile:[NSString pathToBundleFile:aFileName] encoding:NSUTF8StringEncoding error:nil];
}

- (BOOL)isNotEmpty {
	return [self length] > 0;
}

- (BOOL)isEmpty {
    return [self length] <= 0;
}

#ifdef __IPHONE_3_0

- (BOOL) isValidEmail {

	// E-mail regex complete verification of RFC 2822. :-)
	static NSString *emailRegEx =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
	
	// Always return YES, just check if the e-mailaddress is valid yet
	// so we can enable the Send button.
	NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
	return [regExPredicate evaluateWithObject:[self lowercaseString]];
}


#endif

- (NSComparisonResult) compareNumbers:(NSString*) right {
    
	static NSCharacterSet *charSet = nil;
    if ( charSet == nil ) {
        charSet = [[[NSCharacterSet characterSetWithCharactersInString:@"0123456789.,"] invertedSet] retain];
    }
	
	return [[self stringByTrimmingCharactersInSet:charSet] 
            compare:[right stringByTrimmingCharactersInSet:charSet] 
			options:NSCaseInsensitiveSearch | NSNumericSearch];
}

@end

