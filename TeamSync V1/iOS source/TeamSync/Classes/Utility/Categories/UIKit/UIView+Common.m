
#import "UIView+Common.h"


@interface UIView (Common_Private) 

+ (void) printChildsForView:(UIView*) view withInd:(NSUInteger) ind;

@end

@implementation UIView (Common)

- (void) removeSubviewsWithTag:(NSInteger) tag {
	
	UIView *viewToRemove = nil;
	while ( (viewToRemove = [self viewWithTag:tag]) ) {
		[viewToRemove removeFromSuperview];
	}
	
}

- (void)setTestBackground{
	self.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5];  
}

- (void) centerViewByX:(BOOL) centerByX byY:(BOOL) centerByY {
	
	if ( !centerByX && !centerByY  ) {
		return;
	}
	
	CGRect viewFrame = self.frame;
	CGRect superviewBounds = [self superview].bounds;
	
	if ( centerByX ) {
		viewFrame.origin.x = roundf((superviewBounds.size.width / 2.0f - viewFrame.size.width / 2.0f));
	}

	if ( centerByY ) {
		viewFrame.origin.y = roundf((superviewBounds.size.height / 2.0f - viewFrame.size.height / 2.0f));		
	}

	self.frame = viewFrame;
	
}



- (void) setOrigin:(CGPoint)aPoint{
	self.frame = CGRectMake(aPoint.x, aPoint.y, self.frame.size.width, self.frame.size.height);
}

- (void) setSize:(CGSize)aSize{
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, aSize.width, aSize.height);
}

- (void) setWidth:(float)aWidth{
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, aWidth, self.frame.size.height);
}

- (void) setHeight:(float)aHeight{
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,  self.frame.size.width, aHeight);
}

- (void) placeInSuperViewMode:(UIViewContentMode)aMode offset:(CGPoint)aOffset{
	[self placeInRectOfSize:self.superview.frame.size mode:aMode offset:aOffset];
}

- (void) placeInRectOfSize:(CGSize)aSize mode:(UIViewContentMode)aMode offset:(CGPoint)aOffset{
	CGPoint viewPoint = CGPointZero;
	CGSize viewSize = self.bounds.size;
	if (aMode < UIViewContentModeCenter || aMode > UIViewContentModeBottomRight){
		return;
	}
	if (aMode == UIViewContentModeCenter || aMode == UIViewContentModeTop || aMode == UIViewContentModeBottom){
		viewPoint.x = aSize.width/2.0 - viewSize.width / 2.0; 
	}
	else if (aMode == UIViewContentModeRight || aMode == UIViewContentModeTopRight || aMode == UIViewContentModeBottomRight){
		viewPoint.x = aSize.width - viewSize.width; 
	}
	
	if (aMode == UIViewContentModeCenter || aMode == UIViewContentModeLeft || aMode == UIViewContentModeRight){
		viewPoint.y = aSize.height /2.0 - viewSize.height / 2.0; 
	}
	else if (aMode == UIViewContentModeBottomRight || aMode == UIViewContentModeBottom || aMode == UIViewContentModeBottomLeft){
		viewPoint.y = aSize.height - viewSize.height;  
	}
	self.center = CGPointMake(viewPoint.x + viewSize.width / 2.0 + aOffset.x, viewPoint.y + viewSize.height / 2.0 + aOffset.y);
}

- (void) printSubviews {
	[UIView printChildsForView:self withInd:0];
}

- (UIView*) findSuperviewWithClass:(Class) superViewClass {
	
	UIView *currentSuperView = self.superview;
	while ( currentSuperView != nil && ![currentSuperView isKindOfClass:superViewClass] ) {
		currentSuperView = currentSuperView.superview;
	}
	
	return currentSuperView;
}

- (UIViewController*)viewController {
	for (UIView* next = self; next; next = next.superview) {
		UIResponder* nextResponder = [next nextResponder];
		if ([nextResponder isKindOfClass:[UIViewController class]]) {
			return (UIViewController*)nextResponder;
		}
	}
	return nil;
}



- (CGPoint) bottomRightPoint {
    return CGPointMake(self.frame.origin.x + self.frame.size.width, self.frame.origin.y + self.frame.size.height);
}

//- (void) setBottomRightPoint:(CGPoint)aPoint {
//    [self setOrigin:CGPointMake(aPoint.x - self.frame.size.width, aPoint.y - self.frame.size.height)];
//}

#pragma mark -
#pragma mark Private

+ (void) printChildsForView:(UIView*) view withInd:(NSUInteger) ind {
	NSString *indText = @"";
	int i;
	for (i = 0; i < ind; i++) {
		indText = [indText stringByAppendingString:@"-"];
	}
	NSLog(@"%@ [%@]", indText, [view class]);
	for (UIView *child in view.subviews) {
		[[self class] printChildsForView:child withInd: ind + 1];
	}
}

@end

