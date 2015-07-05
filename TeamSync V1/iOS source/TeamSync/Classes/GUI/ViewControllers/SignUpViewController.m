//
//  SignUpViewController.m
//  TeamSync
//
//  Created for SMG Mobile on 3/26/12.
//  
//

#import "SignUpViewController.h"
#import "LoginTextField.h"
#import "PlaylistsViewController.h"
#import "AppDelegate.h"
#import "NSURL+Common.h"

@interface SignUpViewController ()

@end

NSString *const username = @"USERNAME";
NSString *const email = @"EMAIL";
NSString *const password = @"PASSWORD";
NSString *const confirmPassword = @"CONFIRM PASSWORD";

const int tagUsername = 100;
const int tagEmail = 101;
const int tagPassword = 102;
const int tagConfirmPassword = 103;

@implementation SignUpViewController {
    UIScrollView *_contentScrollView;
    UIButton *cancelButton;
    UIButton *doneButton;

    CGFloat _contentOffsetHeight;    
}

- (UILabel*)createLabelWithRect:(CGRect)rect text:(NSString*)text {
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.text = text;
    label.font = [UIFont boldSystemFontOfSize:12.0];
    [_contentScrollView addSubview:label];
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
    [_contentScrollView addSubview:button];
    return button;
}

- (LoginTextField*)createTextFieldWith:(CGRect)rect placeholder:(NSString*)placeholder {
    LoginTextField *textField = [[LoginTextField alloc] initWithFrame:rect];
    textField.delegate = self;
    textField.placeholder = placeholder;
    textField.textColor = [UIColor whiteColor];    
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textField.background = [[UIImage imageNamed:@"fieldEditing.png"] stretchableImageWithLeftCapWidth:9.0f topCapHeight:7.0f];
    textField.clearButtonMode = UITextFieldViewModeAlways;
    
    if ([placeholder isEqualToString:username]) {
        textField.returnKeyType = UIReturnKeyNext;
        textField.tag = tagUsername;
//        textField.text = @"name";
    }
    else if ([placeholder isEqualToString:email]) {
        textField.returnKeyType = UIReturnKeyNext;
        textField.tag = tagEmail;        
//        textField.text = @"name@mail.com";
    }
    else if ([placeholder isEqualToString:password]) {
        textField.returnKeyType = UIReturnKeyNext;
        textField.tag = tagPassword; 
//        textField.text = @"1";
    }
    else if ([placeholder isEqualToString:confirmPassword]) {
        textField.returnKeyType = UIReturnKeyDone;
        textField.tag = tagConfirmPassword;
//        textField.text = @"1";
    }
    
    [_contentScrollView addSubview:textField];
    return textField;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _contentOffsetHeight = 0.0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];    
    
    UIView *background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginBg.png"]];
    [self.view addSubview:background];
    background.frame = self.view.bounds;
    background.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    _contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 440.0)];
    _contentScrollView.contentSize = CGSizeMake(320.0, 440.0);
    [self.view addSubview:_contentScrollView];
    
    float curOY = 110; 
    
    [self createLabelWithRect:CGRectMake(35.0, curOY, 250.0, 20.0) text:username];
    [self createTextFieldWith:CGRectMake(35.0, curOY + 20, 250.0, 30.0) placeholder:username];

    curOY += 55;
    
    [self createLabelWithRect:CGRectMake(35.0, curOY, 250.0, 20.0) text:email];
    [self createTextFieldWith:CGRectMake(35.0, curOY + 20, 250.0, 30.0) placeholder:email];

    curOY += 55;
    
    [self createLabelWithRect:CGRectMake(35.0, curOY, 250.0, 20.0) text:password];
    UITextField *pass1 = [self createTextFieldWith:CGRectMake(35.0, curOY + 20, 250.0, 30.0) placeholder:password];
    pass1.secureTextEntry = YES;

    curOY += 55;
    
    [self createLabelWithRect:CGRectMake(35.0, curOY, 250.0, 20.0) text:confirmPassword];
    UITextField *pass2 = [self createTextFieldWith:CGRectMake(35.0, curOY + 20, 250.0, 30.0) placeholder:confirmPassword];
    pass2.secureTextEntry = YES;
    
    curOY += 90;
    cancelButton = [self createButtonWithOX:CGPointMake(35.0, curOY) title:@"CANCEL" selector:@selector(cancelAction)];
    doneButton = [self createButtonWithOX:CGPointMake(171.0, curOY) title:@"DONE" selector:@selector(doneAction)];
    doneButton.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[AppServer sharedInstance] removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == tagUsername) {
        [[self.view viewWithTag:tagEmail] becomeFirstResponder];
        _contentOffsetHeight = 0.0;        
    } 
    else if (textField.tag == tagEmail) {
        [[self.view viewWithTag:tagPassword] becomeFirstResponder];
        _contentOffsetHeight = 50.0;        
    }
    else if (textField.tag == tagPassword) {
        [[self.view viewWithTag:tagConfirmPassword] becomeFirstResponder];
        _contentOffsetHeight = 100.0;                
    }    
    else {
        [textField resignFirstResponder];
        _contentOffsetHeight = 0.0;
        return NO;
    }
    
    [_contentScrollView setContentOffset:CGPointMake(0.0, _contentOffsetHeight) animated:YES];            
    
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.tag == tagUsername) {
        _contentOffsetHeight = 0.0;
    }
    else if (textField.tag == tagEmail) {
        _contentOffsetHeight = 50.0;
    }        
    else if (textField.tag == tagPassword) {
        _contentOffsetHeight = 100.0;
    }    
    else if (textField.tag == tagConfirmPassword) {
        _contentOffsetHeight = 160.0;
    }
    else {
        _contentOffsetHeight = 0.0;                
    }
    
    [_contentScrollView setContentOffset:CGPointMake(0.0, _contentOffsetHeight) animated:YES];            
    
    textField.background = [[UIImage imageNamed:@"fieldEditing.png"] stretchableImageWithLeftCapWidth:9.0f topCapHeight:7.0f];
    textField.textColor = [UIColor blackColor];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    if (textField.tag == tagEmail && ![textField.text isValidEmail]) {
        NSString *alertMessage = @"Wrong e-mail";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:alertMessage 
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];            
        [alert show];
    }
    else if (textField.tag == tagConfirmPassword) {
        UITextField *passwordTextField = (UITextField *)[self.view viewWithTag:tagPassword];
        if (![passwordTextField.text isEqualToString:textField.text]) {
            NSString *alertMessage = @"Wrong confirmation of password";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:alertMessage 
                                              delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];            
            [alert show];
        }
    }       
    
    textField.background = [[UIImage imageNamed:@"fieldEditing.png"] stretchableImageWithLeftCapWidth:9.0f topCapHeight:7.0f];
    textField.textColor = [UIColor whiteColor];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {   
    NSString *currentTextFieldText = [textField.text stringByReplacingCharactersInRange:range withString:string];

    if ([string isEqualToString:@" "]) {
        return NO;
    }
    
    UITextField *userNameField = (UITextField *)[self.view viewWithTag:tagUsername];
    UITextField *emailField = (UITextField *)[self.view viewWithTag:tagEmail];
    UITextField *passwordField = (UITextField *)[self.view viewWithTag:tagPassword];
    UITextField *confirmPasswordField = (UITextField *)[self.view viewWithTag:tagConfirmPassword];    
    
    // set text of textfields to temporarry strings
    NSString *userNameTextFieldText = [userNameField text];
    NSString *emailTextFieldText = [emailField text];
    NSString *passwordTextFieldText = [passwordField text];
    NSString *confirmPasswordTextFieldText = [confirmPasswordField text]; 
        
    // set current text to current field
    if (textField == userNameField) {
        userNameTextFieldText = currentTextFieldText;
    }
    else if (textField == emailField) {
        emailTextFieldText = currentTextFieldText;        
    }
    else if (textField == passwordField) {
        passwordTextFieldText = currentTextFieldText;        
    }
    else if (textField == confirmPasswordField) {
        confirmPasswordTextFieldText = currentTextFieldText;        
    }    
    
    BOOL enabled = NO;    
    if ([userNameTextFieldText length] > 0 && 
        [emailTextFieldText isValidEmail] && 
        [passwordTextFieldText length] > 0 &&
        [confirmPasswordTextFieldText length] > 0 &&
        [passwordTextFieldText isEqualToString:confirmPasswordTextFieldText]) {
        enabled = YES;
    }
    else {
        enabled = NO;
    }
    
    doneButton.enabled = enabled;
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    doneButton.enabled = NO;
    return YES;
}

#pragma mark - Keyboard Notifications

- (void) keyboardWillShow:(NSNotification*) notification {
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:[[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    [_contentScrollView setFrame:CGRectMake(0.0, 0.0, 320.0, 244.0)];
    
    [UIView commitAnimations];
}

- (void) keyboardDidHide:(NSNotification*) notification {
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:[[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];

    [_contentScrollView setFrame:CGRectMake(0.0, 0.0, 320.0, 440.0)];    
    
    [UIView commitAnimations];        
}


#pragma - mark Actions
- (void)cancelAction {
//    NSLog(@"vc: %@", [self.presentingViewController class]);
//    NSLog(@"parentViewController: %@", NSStringFromClass([self.presentedViewController class]));

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneAction {
    UITextField *userNameField = (UITextField *)[self.view viewWithTag:tagUsername];
    UITextField *emailField = (UITextField *)[self.view viewWithTag:tagEmail];
    UITextField *passwordField = (UITextField *)[self.view viewWithTag:tagPassword];
    
    NSString *username = [userNameField text];
    NSString *email = [emailField text];
    NSString *password = [passwordField text];

    [AppServerHelper signUpUsername:username email:email 
                           password:password withlistener:self];

    [AppLogicManager setActiveUsername:username password:password isMaster:YES];
    self.view.userInteractionEnabled = NO;
    self.activityIndicatorVisible = YES;
}


#pragma - mark Server delegates
- (void) serverRequest:(ServerRequest)serverRequest didFailWithError:(NSError*)error userInfo:(NSDictionary*)userInfo {
    self.view.userInteractionEnabled = YES;
    self.activityIndicatorVisible = NO;
    [[AppServer sharedInstance] removeDelegate:self];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Sign up Error" 
                                                     message:nil
                                                    delegate:nil 
                                           cancelButtonTitle:@"Try Again"
                                           otherButtonTitles:nil];
    [alert show];
}

- (void) serverRequestDidFinish:(ServerRequest)serverRequest result:(id)result userInfo:(NSDictionary*)userInfo {
    self.view.userInteractionEnabled = YES;
    self.activityIndicatorVisible = NO;
    [[AppServer sharedInstance] removeDelegate:self];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Registration was successful" 
                                                     message:nil
                                                    delegate:self 
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
    [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5) {
        [self.parentViewController viewWillAppear:YES];
    } else {
        [self.presentingViewController viewWillAppear:YES];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
