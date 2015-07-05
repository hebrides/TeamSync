
#import "UILabel+Common.h"


@implementation UILabel (Common)

- (void) cropFrameByText {
	
	CGSize size = [self.text sizeWithFont:self.font];
	CGRect labelFrame = self.frame;
	labelFrame.size.width = roundf(size.width);
	labelFrame.size.height = roundf(size.height);
	self.frame = labelFrame;
	
}

- (void) cropHeightByText {
	
    CGSize size = [self.text sizeWithFont:self.font 
				   constrainedToSize:CGSizeMake(self.frame.size.width, CGFLOAT_MAX) 
				   lineBreakMode:self.lineBreakMode];
	
	CGRect labelFrame = self.frame;
	labelFrame.size.height = roundf(size.height);
	self.frame = labelFrame;
	
}

- (CGSize) contentSizeForWidth:(CGFloat)width height:(CGFloat)height
{
	CGSize size = CGSizeZero;
	
	if (self.text != nil)
	{
		size = [self.text sizeWithFont: self.font 
		             constrainedToSize: CGSizeMake(width, height) 
		                 lineBreakMode: self.lineBreakMode];
		
		size.width  = ceilf(size.width);
		size.height = ceilf(size.height);
	}
	
	return size;
}

- (CGSize) contentSizeForWidth: (CGFloat) width
{
	return [self contentSizeForWidth:width height:CGFLOAT_MAX];
}

- (CGSize) contentSizeForHeight: (CGFloat) height
{
	return [self contentSizeForWidth:CGFLOAT_MAX height:height];
}
@end

