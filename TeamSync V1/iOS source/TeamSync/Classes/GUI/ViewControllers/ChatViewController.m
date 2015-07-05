//
//  ChatViewController.m
//  TeamSync
//
//  Created for SMG Mobile on 28.03.12.
//  
//

#import "ChatViewController.h"
#import "LoginTextField.h"

@interface ChatViewController ()
- (CGFloat)calculateRowHeigthForText:(NSString *)text;
@end

@implementation ChatViewController {
    UIView *_textFieldBackgroundView;
    LoginTextField *_textField;
    UIButton *_cancelButton;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.tableView.frame = CGRectMake(0.0, 0.0, 320.0, 420.0);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;    

    _textFieldBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 320.0, 320.0, 45)];
    _textFieldBackgroundView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1];
    [self.view addSubview:_textFieldBackgroundView];    
    
    _textField = [[LoginTextField alloc] initWithFrame:CGRectMake(5.0, 5.0, 309.0, 35.0)];        
    _textField.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    _textField.clearButtonMode = UITextFieldViewModeAlways;
    _textField.delegate = self;
    _textField.placeholder = @"Your message";
    _textField.returnKeyType = UIReturnKeySend;
    _textField.textColor = [UIColor blackColor];    
    _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _textField.autocorrectionType = UITextAutocorrectionTypeNo;
    _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _textField.background = [[UIImage imageNamed:@"fieldEditing.png"] stretchableImageWithLeftCapWidth:9.0f topCapHeight:7.0f];
    _textField.clearButtonMode = UITextFieldViewModeAlways;
    [_textFieldBackgroundView addSubview:_textField];    
    
    _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cancelButton.frame = CGRectMake(316.0, 8.0, 58.0, 29.0);    
    _cancelButton.alpha = 0.0;
    _cancelButton.backgroundColor = [UIColor darkGrayColor];
    _cancelButton.layer.cornerRadius = 7.0;
    _cancelButton.layer.borderColor = [UIColor blackColor].CGColor;
    _cancelButton.layer.borderWidth = 1.0;
    [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
    [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(cancelKeyboard:) forControlEvents:UIControlEventTouchUpInside];
    [_textFieldBackgroundView addSubview:_cancelButton];
}
#pragma mark - Appears
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateChatMessages) 
                                                 name:SyncNotificationNewMessage object:nil];        
    [self updateChatMessages];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField.text length] > 0) {
        [[SyncWrapper sharedInstance] sendTextMessage:textField.text];
    }

    textField.text = @"";    
    
    [textField resignFirstResponder];
    
    return YES;
}

- (void)updateChatMessages {
    [self.itemsArray removeAllObjects];
    [self.itemsArray addObjectsFromArray:[[SyncWrapper sharedInstance].messagehandler messages]];
    [self.tableView reloadData];
    
    int count = [self.itemsArray count] - 1;
    if (count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:count inSection:0]
                              atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}
#pragma mark - UITableViewDataSource 

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"PlaylistIdentifier";
    UITableViewCell *cell = (UITableViewCell*)[table dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
        
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0];
        cell.detailTextLabel.numberOfLines = 100;
    }
    
    
    NSDictionary *message = [self.itemsArray objectAtIndex:indexPath.row];    
    cell.textLabel.text = [message objectForKey:@"nickname"];
    cell.detailTextLabel.text = [message objectForKey:@"text"];

    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    User *user = [DataProvider currentActiveUser];
    NSDictionary *message = [self.itemsArray objectAtIndex:indexPath.row];
    if ([user.username isEqualToString:[message objectForKey:@"nickname"]]) {
        cell.backgroundColor = [UIColor colorWithRed:130.0/255.0 green:130.0/255.0 blue:130.0/255.0 alpha:1.0];
    } else {
        cell.backgroundColor = [UIColor clearColor];
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *message = [self.itemsArray objectAtIndex:indexPath.row];    
    NSString *rowText = [message objectForKey:@"text"];
    return [self calculateRowHeigthForText:rowText];
}


#pragma mark - Keyboard Notifications

- (void) keyboardWillShow:(NSNotification*) notification {
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:[[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];

    self.tableView.frame = CGRectMake(0.0, 0.0, 320.0, 420.0 - 316 ); 
    
    _textFieldBackgroundView.frame = CGRectMake(0.0, 320.0 - 216.0, 320.0, 45);
    
    _textField.frame = CGRectMake(5.0, 5.0, 250.0, 35.0);
    _cancelButton.frame = CGRectMake(260.0, 8.0, 55.0, 29.0);
    _cancelButton.alpha = 1.0;
    
    [UIView commitAnimations];
}

- (void) keyboardWillHide:(NSNotification*) notification {
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:[[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    
    self.tableView.frame = CGRectMake(0.0, 0.0, 320.0, 322.0);    
    
    _textFieldBackgroundView.frame = CGRectMake(0.0, 320.0, 320.0, 45);

    _textField.frame = CGRectMake(5.0, 5.0, 309.0, 35.0);
    _cancelButton.frame = CGRectMake(320.0, 8.0, 49.0, 29.0);    
    _cancelButton.alpha = 0.0;    
    
    [UIView commitAnimations];    
}


#pragma mark - Private methods

- (CGFloat)calculateRowHeigthForText:(NSString *)text {
    // get size of text
    UIFont *font = [UIFont boldSystemFontOfSize:16.0];
    CGSize size = [text sizeWithFont:font];
    
    // calculate heigth of row
    CGFloat i = size.width / 300.0;
    
    CGFloat heigth = 44.0;
    while (i > 1.0) {
        heigth += 14;
        i -= 1.0;
    }
    
    return heigth;
}


#pragma mark - Actions

- (void)cancelKeyboard:(UIButton *)button {
    [_textField resignFirstResponder];
}
     
@end
