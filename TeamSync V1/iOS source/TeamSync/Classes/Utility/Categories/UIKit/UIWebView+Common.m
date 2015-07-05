
#import "UIWebView+Common.h"
#import "NSMutableArray+Common.h"

@implementation UIWebView (Common)

- (NSString*) selectedText {
	return [self stringByEvaluatingJavaScriptFromString:@"document.getSelection().toString();"];
}

- (void) deselect {
	self.userInteractionEnabled = NO;
	self.userInteractionEnabled = YES;
}

- (CGSize) windowSize {
	CGSize size;
	size.width = [[self stringByEvaluatingJavaScriptFromString:@"window.innerWidth"] integerValue];
	size.height = [[self stringByEvaluatingJavaScriptFromString:@"window.innerHeight"] integerValue];
	return size;
}

- (CGPoint) scrollOffset {
	CGPoint pt;
	pt.x = [[self stringByEvaluatingJavaScriptFromString:@"window.pageXOffset"] integerValue];
	pt.y = [[self stringByEvaluatingJavaScriptFromString:@"window.pageYOffset"] integerValue];
	return pt;
}

- (NSInteger) highlightAllOccurencesOfString:(NSString*) str {
	return [self highlightAllOccurencesOfStrings:[NSSet setWithObject:str]];
}

- (NSInteger) highlightAllOccurencesOfStrings:(NSSet*) strs {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Search" ofType:@"" inDirectory:@"Common.bundle"];
    NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self stringByEvaluatingJavaScriptFromString:jsCode];
	
	NSMutableArray *stringList = [NSMutableArray arrayWithArray:[strs allObjects]];
	[stringList sortUsingSelector:@selector(compare:)];
	[stringList reverse];
	
    NSString *startSearch = [NSString stringWithFormat:@"MyApp_HighlightAllOccurencesOfStrings(new Array(\"%@\"))", [stringList componentsJoinedByString:@"\", \""]];
    [self stringByEvaluatingJavaScriptFromString:startSearch];
	
    NSString *result = [self stringByEvaluatingJavaScriptFromString:@"MyApp_SearchResultCount"];
    return [result integerValue];
}

- (void) removeAllHighlights {
    [self stringByEvaluatingJavaScriptFromString:@"MyApp_RemoveAllHighlights()"];
}


@end

