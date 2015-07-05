//
//  AppDatePicker.h
//  TeamSync
//
//  Created for SMG Mobile on 4/3/12.
//  
//

#import <UIKit/UIKit.h>

@class AppDatePicker;
@protocol AppDatePickerDelegate <NSObject>
- (void)appPicketView:(AppDatePicker*)pickerView didSelectedDate:(NSDate*)date;
@end

@interface AppDatePicker : UIView {
    UIDatePicker *pickerView;
    //	id <AppDatePickerDelegate>delegate;
}
@property (nonatomic, unsafe_unretained) id <AppDatePickerDelegate>delegate;

- (AppDatePicker*)initWithContentView:(UIView*)contentView 
							 delegate:(id<AppDatePickerDelegate>)delegate;
- (void)show;
- (void)drop;

@end

