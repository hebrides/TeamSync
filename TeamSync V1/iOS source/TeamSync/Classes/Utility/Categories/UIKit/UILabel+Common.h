
#import <Foundation/Foundation.h>


@interface UILabel (Common)

- (void) cropFrameByText;
- (void) cropHeightByText;

- (CGSize) contentSizeForWidth:(CGFloat)width height:(CGFloat)height;
- (CGSize) contentSizeForHeight: (CGFloat) height;
- (CGSize) contentSizeForWidth: (CGFloat) width;

@end

