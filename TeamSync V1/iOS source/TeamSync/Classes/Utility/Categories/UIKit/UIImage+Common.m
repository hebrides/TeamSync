
#import "UIImage+Common.h"


@implementation UIImage (Common)

+ (id) imageMaskWithContentSize:(CGSize) innerSize maskWidth:(CGFloat) frameWidth colors:(NSArray*) colors 
					cornerRadius:(CGFloat) cornerRadius fillContent:(BOOL) needFillColor {
	
	innerSize.width -= cornerRadius * 2;
	innerSize.height -= cornerRadius * 2;
	frameWidth += cornerRadius;
	
	CGSize resultSize = CGSizeMake(innerSize.width + frameWidth * 2, innerSize.height + frameWidth * 2);
	
	UIGraphicsBeginImageContext( resultSize );
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
	
	NSMutableArray *cgColors = [NSMutableArray arrayWithCapacity:[colors count]];
	for (UIColor *color in colors) {
		[cgColors addObject:(id)color.CGColor];
	}
	
	CGFloat *locs = NULL;
	int count = [cgColors count];
	if ( cornerRadius != 0.0f && count > 1) {
		locs = calloc(sizeof(CGFloat), (needFillColor) ? count : count + 2);
		CGFloat maxLoc = 1.0f - cornerRadius / frameWidth;
		CGFloat shift = maxLoc / (count - 1);
		CGFloat curLoc = 0.0f;
		for (int i = 0; i < count; i++, curLoc += shift) {
			locs[i] = curLoc;
		}
		
		if ( !needFillColor ) {
			count += 2;
			
			locs[count - 2] = locs[count - 3];
			locs[count - 1] = 1.0f;
			CGColorRef clearColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f].CGColor;
			[cgColors addObject:(__bridge id)clearColor];
			[cgColors addObject:(__bridge id)clearColor];
		}
		
	}
	
	CGGradientRef gradient = CGGradientCreateWithColors(rgb, (__bridge CFArrayRef)cgColors, locs);
	CGColorSpaceRelease(rgb);
	
	if ( locs != NULL ) {
		free(locs);
		locs = NULL;
	}
	
	CGPoint start, end;
	
	// Filling contet with last color;
	if ( needFillColor ) {
		CGRect fillRect = CGRectMake(frameWidth, frameWidth, innerSize.width, innerSize.height);
		CGContextSetFillColorWithColor(context, (__bridge CGColorRef)[cgColors lastObject]);
		CGContextFillRect(context, fillRect);
	}
	
	// Top left corner
	CGContextSaveGState(context);
	CGContextClipToRect(context, CGRectMake(0.0f, 0.0f, frameWidth, frameWidth));
	start = end = CGPointMake(frameWidth, frameWidth);
	CGContextDrawRadialGradient(context, gradient, start, frameWidth, end, 0, 0);
	CGContextRestoreGState(context);
	
	// Top right corner
	CGContextSaveGState(context);
	CGContextClipToRect(context, CGRectMake(frameWidth + innerSize.width, 0.0f, frameWidth, frameWidth));
	start = end = CGPointMake(frameWidth + innerSize.width, frameWidth);
	CGContextDrawRadialGradient(context, gradient, start, frameWidth, end, 0, 0);
	CGContextRestoreGState(context);
	
	// Bottom left corner
	CGContextSaveGState(context);
	CGContextClipToRect(context, CGRectMake(0.0, frameWidth + innerSize.height, frameWidth, frameWidth));
	start = end = CGPointMake(frameWidth, frameWidth + innerSize.height);
	CGContextDrawRadialGradient(context, gradient, start, frameWidth, end, 0, 0);
	CGContextRestoreGState(context);
	
	// Bottom right corner
	CGContextSaveGState(context);
	CGContextClipToRect(context, CGRectMake(frameWidth + innerSize.width, frameWidth + innerSize.height, frameWidth, frameWidth));
	start = end = CGPointMake(frameWidth + innerSize.width, frameWidth + innerSize.height);
	CGContextDrawRadialGradient(context, gradient, start, frameWidth, end, 0, 0);
	CGContextRestoreGState(context);
	
	// Left border
	CGContextSaveGState(context);
	CGContextClipToRect(context, CGRectMake(0.0f, frameWidth, frameWidth, innerSize.height));
	start = CGPointMake(0.0f, 0.0f);
	end = CGPointMake(frameWidth, 0.0f);
	CGContextDrawLinearGradient(context, gradient, start, end, 0);
	CGContextRestoreGState(context);
	
	// Top border
	CGContextSaveGState(context);
	CGContextClipToRect(context, CGRectMake(frameWidth, 0.0f, innerSize.width, frameWidth));
	start = CGPointMake(0.0f, 0.0f);
	end = CGPointMake(0.0f, frameWidth);
	CGContextDrawLinearGradient(context, gradient, start, end, 0);
	CGContextRestoreGState(context);
	
	// Right border
	CGContextSaveGState(context);
	CGContextClipToRect(context, CGRectMake(frameWidth + innerSize.width, frameWidth, frameWidth, innerSize.height));
	start = CGPointMake(resultSize.width, 0.0f);
	end = CGPointMake(frameWidth + innerSize.width, 0.0f);
	CGContextDrawLinearGradient(context, gradient, start, end, 0);
	CGContextRestoreGState(context);
	
	// Bottom border
	CGContextSaveGState(context);
	CGContextClipToRect(context, CGRectMake(frameWidth, frameWidth + innerSize.height, innerSize.width, frameWidth));
	start = CGPointMake(0.0f, resultSize.height);
	end = CGPointMake(0.0f, frameWidth + innerSize.height);
	CGContextDrawLinearGradient(context, gradient, start, end, 0);
	CGContextRestoreGState(context);
	
	CGGradientRelease(gradient);
	
	UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return resultImage;
}




@end




