
#import <Foundation/Foundation.h>


@interface UIWebView (Common)

- (NSString*) selectedText;
- (void) deselect;
- (CGSize) windowSize;
- (CGPoint) scrollOffset;
- (NSInteger) highlightAllOccurencesOfString:(NSString*) str;
- (NSInteger) highlightAllOccurencesOfStrings:(NSSet*) strs;
- (void) removeAllHighlights;

@end

