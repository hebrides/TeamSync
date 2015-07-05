//
//  LoginViewController.m
//  TeamSync
//
//  Created for SMG Mobile on 3/14/12.
//  
//

#import "LoginViewController.h"
#import "LoginTextField.h"


#import "SignUpViewController.h"
#import "AppDelegate.h"

@interface LoginViewController ()

@end

@implementation LoginViewController {
    UIView *_contentView;

    UISegmentedControl *roleSegmentedControl;
    
    LoginTextField *_usernameField;
    LoginTextField *_passwordField;
    
    UIButton *_loginButton;
    UIButton *_signUpButton;
    UIButton *_cancelButton;    
}




//- (UILabel*)la {}
- (UILabel*)createLabelWithRect:(CGRect)rect text:(NSString*)text {
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.text = text;
    label.font = [UIFont boldSystemFontOfSize:12.0];
    [_contentView addSubview:label];
    return label;
}

- (UIButton*)createButtonWithOX:(CGPoint)oxPoint title:(NSString*)title selector:(SEL)selector {
    UIImage *anImage = [UIImage imageNamed:@"buttonUnpressed.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(oxPoint.x, oxPoint.y, 115, 38);
    [button setBackgroundImage:anImage forState:UIControlStateNormal];
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    [button setTitleColor:[UIColor colorWithWhite:1.0f alpha:0.5f] forState:UIControlStateDisabled];
    [_contentView addSubview:button];
    return button;
}

- (LoginTextField*)createTextFieldWith:(CGRect)rect placeholder:(NSString*)placeholder {
    LoginTextField *textField = [[LoginTextField alloc] initWithFrame:rect];
    textField.delegate = self;
    textField.placeholder = placeholder;
    textField.textColor = [UIColor redColor];
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.background = [[UIImage imageNamed:@"fieldEditing.png"] stretchableImageWithLeftCapWidth:9.0f topCapHeight:7.0f];
    textField.clearButtonMode = UITextFieldViewModeAlways;
    [_contentView addSubview:textField];
    return textField;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    
    
    
    UIView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginBg.png"]];
    [self.view addSubview:background];
    background.frame = self.view.bounds;
    background.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;


    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 80.0, 320.0, 360.0)];
    [self.view addSubview:_contentView];
    
    
    roleSegmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"LEADER", @"FOLLOWER", nil]];
    [_contentView addSubview:roleSegmentedControl];
    roleSegmentedControl.frame = CGRectMake(35.0, 10.0, 250.0, 30.0);
    roleSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    roleSegmentedControl.selectedSegmentIndex = 0;
    roleSegmentedControl.backgroundColor = [UIColor clearColor];
    roleSegmentedControl.tintColor = [UIColor whiteColor];

    

    
    
    [self createLabelWithRect:CGRectMake(35.0, 60.0, 250.0, 20.0) text:@"EMAIL"];
    _usernameField = [self createTextFieldWith:CGRectMake(35.0, 80.0, 250.0, 30.0) placeholder:@"EMAIL"];
    _usernameField.returnKeyType = UIReturnKeyNext;


    [self createLabelWithRect:CGRectMake(35.0, 115.0, 250.0, 20.0) text:@"PASSWORD"];
    _passwordField = [self createTextFieldWith:CGRectMake(35.0, 135.0, 250.0, 30.0) placeholder:@"PASSWORD"];
    _passwordField.secureTextEntry = YES;
    _passwordField.returnKeyType = UIReturnKeyDone;
    
    
    _loginButton = [self createButtonWithOX:CGPointMake(35.0, 190.0) title:@"LOG IN" selector:@selector(clickLogin)];
    _loginButton.enabled = NO;
    

    _signUpButton = [self createButtonWithOX:CGPointMake(171.0, 190.0) title:@"SIGN UP" selector:@selector(clickSignup)];

    _cancelButton = [self createButtonWithOX:CGPointMake(171.0, 190.0) title:@"CANCEL" selector:@selector(clickCancel)];
    _cancelButton.alpha = 0.0f;
    
    
//    _usernameField.text = @"master";
//    _passwordField.text = @"password";
//    _loginButton.enabled = YES;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Get Current User if available
    User *user = [DataProvider currentActiveUser];
    if (user != nil) {
        _usernameField.text = user.username;
        _passwordField.text = user.password;
        roleSegmentedControl.selectedSegmentIndex = ! [user.isMaster boolValue];
    }
    
//    _usernameField.text = @"user";
//    _passwordField.text = @"user";

    
    if ([_usernameField.text length] > 0 && [_passwordField.text length] > 0) {
        _loginButton.enabled = YES;
    }
    
    //[AppLogicManager logoutActiveUser];
}
- (void)viewDidAppear:(BOOL)animated {


}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[AppServer sharedInstance] removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == _usernameField) {
        [_passwordField becomeFirstResponder];
        return NO;
    } else {
        [textField resignFirstResponder];
    }
    
    return YES;
}

// highlights textField when clicked into
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    textField.background = [[UIImage imageNamed:@"fieldEditing.png"] stretchableImageWithLeftCapWidth:9.0f topCapHeight:7.0f];
    textField.textColor = [UIColor blackColor];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    textField.background = [[UIImage imageNamed:@"fieldEditing.png"] stretchableImageWithLeftCapWidth:9.0f topCapHeight:7.0f];
    textField.textColor = [UIColor redColor];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {   
    
    // Makes it so pressing space does nothing in textfield?
    if ([string rangeOfString:@" "].location != NSNotFound) {
        return NO; // If no blanks found replace nothing
    }
    NSString *otherTextFieldText = nil;
    NSString *currentTextFieldText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if(textField == _usernameField) {
        otherTextFieldText = _passwordField.text;
    }
    else if(textField == _passwordField) {
        otherTextFieldText = _usernameField.text;
    }
    
    _loginButton.enabled = [currentTextFieldText length] > 0 && [otherTextFieldText length] > 0;
    return YES;
}


#pragma mark - Keyboard Notifications

- (void) keyboardWillShow:(NSNotification*) notification {
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:[[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    [_contentView setFrame:CGRectMake(0.0, 5.0, 320.0, 360.0)];
    _signUpButton.alpha = 0.0f;
    _cancelButton.alpha = 1.0f;    
    
    [UIView commitAnimations];
}

- (void) keyboardWillHide:(NSNotification*) notification {
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:[[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];

    [_contentView setFrame:CGRectMake(0.0, 80.0, 320.0, 300.0)];
    _signUpButton.alpha = 1.0f;
    _cancelButton.alpha = 0.0f;
    
    [UIView commitAnimations];    
}


#pragma - mark Actions
- (void) clickSignup {
    SignUpViewController *controller = [SignUpViewController new];
    controller.modalTransitionStyle = UIModalTransitionStylePartialCurl;
    [self presentViewController: controller animated:YES completion: nil];
}

- (void)clickCancel {
    [_usernameField resignFirstResponder];
    [_passwordField resignFirstResponder];
}

- (void) clickLogin {    
    NSString *username = _usernameField.text;
    NSString *password = _passwordField.text;
    if ([username length] == 0 || [password length] == 0) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Incorrect Login or password." 
                                                         message:nil
                                                        delegate:self 
                                               cancelButtonTitle:@"Ok"
                                               otherButtonTitles:nil];
        [alert show];
    }
    BOOL isMaster = (roleSegmentedControl.selectedSegmentIndex == 0);
    self.activityIndicatorVisible = YES;
    
    [AppLogicManager setActiveUsername:username password:password isMaster:isMaster];
    [AppServerHelper loginWithUsername:username password:password role:isMaster withlistener:self];
}


#pragma - mark Server delegates
- (void) serverRequest:(ServerRequest)serverRequest didFailWithError:(NSError*)error userInfo:(NSDictionary*)userInfo {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Login Error" 
                                                     message:nil
                                                    delegate:self 
                                           cancelButtonTitle:@"Try Again"
                                           otherButtonTitles:nil];
    [alert show];
    [[AppServer sharedInstance] removeDelegate:self];
    self.activityIndicatorVisible = NO;
}

- (void) serverRequestDidFinish:(ServerRequest)serverRequest result:(id)result userInfo:(NSDictionary*)userInfo {
    [[AppServer sharedInstance] removeDelegate:self];
    self.activityIndicatorVisible = NO;
    BOOL isMaster = [[DataProvider currentActiveUser].isMaster boolValue];
    [[AppDelegate sharedAppDelegate] loginWithMasterRole:isMaster];
    [self dismissViewControllerAnimated: YES completion: nil];
}




@end
