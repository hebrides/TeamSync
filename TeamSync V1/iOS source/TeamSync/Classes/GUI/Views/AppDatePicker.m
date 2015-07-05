//
//  AppDatePicker.m
//  TeamSync
//
//  Created for SMG Mobile on 4/3/12.
//  
//

#import "AppDatePicker.h"

@interface AppDatePicker ()
- (NSDate *)pickerDate;
- (NSDate *)miniumumDate;
@end

@implementation AppDatePicker {
    NSDate *_mininumDate;
    NSTimer *_timer;
}

@synthesize delegate;

- (void)dealloc
{
    [_timer invalidate];
}

- (AppDatePicker*)initWithContentView:(UIView*)contentView 
							 delegate:(id<AppDatePickerDelegate>)del {
    
	if (contentView == nil) {
		return nil;
	}

	_timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(setMinimumDate:) userInfo:nil repeats:YES];
    
	CGRect frame = CGRectMake(0, contentView.frame.size.height, 320, contentView.frame.size.height);
    
    self = [super initWithFrame:frame];
    if (self) {
		[contentView addSubview:self];
		self.delegate = del;
        self.backgroundColor = [UIColor clearColor];
		
		
		float pickerHeight = 216;
		pickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, frame.size.height - pickerHeight, 
																	320, pickerHeight)];
		[self addSubview:pickerView];

        _mininumDate = [self miniumumDate];
        
        pickerView.minimumDate = _mininumDate;
        pickerView.datePickerMode = UIDatePickerModeTime;
		
		// Init toolbar
		
		NSMutableArray *toolButtons = [NSMutableArray arrayWithCapacity:3];		
		
		UIBarButtonItem *btn;
		// Cancel
        btn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                            target:self action:@selector(cancelAction)];
        [toolButtons addObject:btn];
        
		// empty
		btn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
															target:nil action:nil];
		[toolButtons addObject:btn];
		
		// Ok
		btn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
															target:self action:@selector(doneAction)];
		[toolButtons addObject:btn];
		
        
		float toolBarHeight = 44;
		UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, pickerView.frame.origin.y - toolBarHeight, 
																		 320, toolBarHeight)];
		[self addSubview:toolBar];
		
		toolBar.items = toolButtons;
		toolBar.barStyle = UIBarStyleBlackOpaque;
		
		
    }
    return self;
}



- (void)show {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.30];
	[UIView setAnimationBeginsFromCurrentState:YES];
	CGRect rect = CGRectMake(0,//self.frame.origin.x, 
                             0,//self.superview.frame.size.height - self.frame.size.height, 
                             self.frame.size.width, self.frame.size.height);
    self.frame = rect;
	[UIView commitAnimations];
}
- (void)drop {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.30];
	[UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
	self.frame = CGRectMake(self.frame.origin.x, 
							self.superview.frame.size.height, 
							self.frame.size.width, self.frame.size.height);
	[UIView commitAnimations];
}

//- (void)layoutSubviews {
//	[super layoutSubviews];
//	NSLog(@"pickerView: %@", NSStringFromCGRect(pickerView.frame));
//}

- (void)cancelAction {
	[self drop];
}
- (void)doneAction {    
	[self.delegate appPicketView:self didSelectedDate:[self pickerDate]];
	[self drop];
}

- (void)setMinimumDate:(NSDate *)date {
    pickerView.minimumDate = [self miniumumDate];        
}

- (NSDate *)pickerDate {
    NSDate *currentDate = pickerView.date;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar components:(kCFCalendarUnitYear | kCFCalendarUnitMonth | kCFCalendarUnitDay | NSHourCalendarUnit | NSMinuteCalendarUnit | kCFCalendarUnitSecond) fromDate:currentDate];
    [components setSecond:0.0];
    
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

- (NSDate *)miniumumDate {
    NSDate *currentDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar components:(kCFCalendarUnitYear | kCFCalendarUnitMonth | kCFCalendarUnitDay | NSHourCalendarUnit | NSMinuteCalendarUnit | kCFCalendarUnitSecond) fromDate:currentDate];
    [components setMinute:components.minute + 1];
    
    return [[NSCalendar currentCalendar] dateFromComponents:components];
}

@end
