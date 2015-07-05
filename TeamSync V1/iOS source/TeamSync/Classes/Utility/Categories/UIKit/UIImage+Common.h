
#import <UIKit/UIKit.h>

@interface UIImage (Common)

+ (id) imageMaskWithContentSize:(CGSize) innerSize maskWidth:(CGFloat) frameWidth colors:(NSArray*) colors 
				   cornerRadius:(CGFloat) cornerRadius fillContent:(BOOL) needFillColor;

@end

