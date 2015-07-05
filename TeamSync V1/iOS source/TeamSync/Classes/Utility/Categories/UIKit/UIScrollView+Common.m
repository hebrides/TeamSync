
#import "UIScrollView+Common.h"


@implementation UIScrollView (Common)

- (void) stopDeceleration
{
	// Ugly hack to stop scroll deceleration

	// Hide scroll indicators before because they
	// flash in the wrong position
	
	BOOL showsHorzIndicator = self.showsHorizontalScrollIndicator;
	
	if (showsHorzIndicator)
		self.showsHorizontalScrollIndicator = NO;

	BOOL showsVertIndicator = self.showsVerticalScrollIndicator;
	
	if (showsVertIndicator)
		self.showsVerticalScrollIndicator   = NO;

	// Now it is one solution to stop deceleration
	[self setContentOffset: self.contentOffset animated: NO];

	// Restore indicators if necessary
	self.showsHorizontalScrollIndicator = showsHorzIndicator;
	self.showsVerticalScrollIndicator   = showsVertIndicator;
}

@end

