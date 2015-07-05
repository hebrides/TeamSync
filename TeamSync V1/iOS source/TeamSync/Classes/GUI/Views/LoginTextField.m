//
//  LoginTextField.m
//  SMG Mobile
//
//  Created for SMG Mobile on 06.06.11.
//  
//

#import "LoginTextField.h"

static const CGFloat kHorizontalMargin = 5.0f;

@implementation LoginTextField

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(kHorizontalMargin, 0.0f, bounds.size.width - 2 * kHorizontalMargin, bounds.size.height);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

@end
