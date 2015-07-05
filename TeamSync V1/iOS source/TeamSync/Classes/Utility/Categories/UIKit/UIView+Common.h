
#import <UIKit/UIKit.h>


@interface UIView (Common)



- (void) removeSubviewsWithTag:(NSInteger) tag;
- (void) centerViewByX:(BOOL) centerByX byY:(BOOL) centerByY;
- (void) setOrigin:(CGPoint)aPoint;
- (void) setSize:(CGSize)aSize;
- (CGPoint) bottomRightPoint;
//- (void) setBottomRightPoint;
- (void) placeInSuperViewMode:(UIViewContentMode)aMode offset:(CGPoint)aOffset;
- (void) placeInRectOfSize:(CGSize)aSize mode:(UIViewContentMode)aMode offset:(CGPoint)aOffset;
- (void) printSubviews;
- (UIView*) findSuperviewWithClass:(Class) superViewClass;
- (UIViewController*)viewController;
- (void)setTestBackground;


@end

