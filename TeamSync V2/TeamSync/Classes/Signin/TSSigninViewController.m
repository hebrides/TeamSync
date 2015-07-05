//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSSigninViewController.m
// Description		:	TSSigninViewController class Implementation.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import "TSSigninViewController.h"
#import "TSCommon.h"
#import "TSPlayListViewController.h"
#import "TSDeviceListViewController.h"
#import "TSSCommunicationManager.h"
#import "AppDelegate.h"

@interface TSSigninViewController ()
- (void)setLayoutOfRetina4;
- (void)connectAllClients;
@end

@implementation TSSigninViewController
@synthesize serverBrowser;
@synthesize chatRoom;
@synthesize nameTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [TSAppConfig getInstance].type = @"Master";
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView.frame           = CGRectMake(0, 0, 320, 460);
    self.scrollView.contentSize     = CGSizeMake(320, 650);
    self.scrollView.scrollEnabled   = NO;
    [self.scrollView setContentOffset:CGPointMake(0,0) animated:YES];
    
    [self setLayoutOfRetina4];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UITextField Delegate
#pragma mark -

/********************************************************************************************
 @Method Name  : textFieldShouldReturn
 @Param        : UITextField
 @Return       : BOOL
 @Description  :
 ********************************************************************************************/
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self.scrollView setContentOffset:CGPointMake(0,0) animated:YES];
    
	return NO;
}

/********************************************************************************************
 @Method Name  : textFieldShouldEndEditing
 @Param        : UITextField
 @Return       : BOOL
 @Description  :
 ********************************************************************************************/
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{    
	return YES;
}

/********************************************************************************************
 @Method Name  : textFieldShouldBeginEditing
 @Param        : UITextField
 @Return       : BOOL
 @Description  :
 ********************************************************************************************/
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [textField setKeyboardType:UIKeyboardTypeDefault];
    [self.scrollView setContentOffset:CGPointMake(0,100) animated:YES];
    
    return YES;
}

/********************************************************************************************
 @Method Name  : shouldChangeCharactersInRange
 @Param        : NSRange, NSString
 @Return       : BOOL
 @Description  :
 ********************************************************************************************/
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length >= MAX_CHAR_COUNT && range.length == 0)
    {
        [TSCommon showAlert:MESSAGE_MAX_CHARACTER_EXCEEDED];
        return NO;
    }
    
    if(textField.text.length < MAX_CHAR_COUNT && range.length == 0)
    {
        if([TSCommon validateString:string withStringType:NAME_DATA_TYPE] == YES)
        {
            NSString *msg = MESSAGE_INVALID_CHARACTER;
            [TSCommon showAlert:msg];
            return NO;
        }
    }
    
    return !(range.location > 0 &&
             [string length] > 0 &&
             [[NSCharacterSet whitespaceCharacterSet] characterIsMember:[string characterAtIndex:0]] &&
             [[NSCharacterSet whitespaceCharacterSet] characterIsMember:[[textField text] characterAtIndex:range.location - 1]]);

}

- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setNameTextField:nil];
    [self setClientButton:nil];
    [self setMasterButton:nil];
    bgImageView = nil;
    [super viewDidUnload];
}

- (void)loadPlayListView
{
    [TSCommon dismissProcessView];
    
    TSPlayListViewController *viewController = [[TSPlayListViewController alloc]initWithNibName:@"TSPlayListViewController" bundle:nil];
    viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:viewController animated:YES];

}

- (IBAction)onMasterButtonPressed:(id)sender
{
    [self.masterButton setImage:[UIImage imageNamed:@"RadioBtnSelected"] forState:UIControlStateNormal];
    [self.clientButton setImage:[UIImage imageNamed:@"RadioBtn"] forState:UIControlStateNormal];
    [TSAppConfig getInstance].type = @"Master";
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:@"Master" forKey:kKeyLoggedUser];
}

- (IBAction)onClientButtonPressed:(id)sender
{
    [self.clientButton setImage:[UIImage imageNamed:@"RadioBtnSelected"] forState:UIControlStateNormal];
    [self.masterButton setImage:[UIImage imageNamed:@"RadioBtn"] forState:UIControlStateNormal];
    [TSAppConfig getInstance].type = @"Client";
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:@"Client" forKey:kKeyLoggedUser];
}

- (IBAction)onEnterPressed:(id)sender
{
    if([TSCommon isEmptyString:nameTextField.text])
    {
        [TSCommon showAlert:@"Specify Name."];
        [self.nameTextField becomeFirstResponder];
    }
    else
    {
        TSAppController *objAppController = [TSAppController sharedAppController];
        
        objAppController._currentIndex = -1;
        [self.nameTextField resignFirstResponder];
        [self.scrollView setContentOffset:CGPointMake(0,0) animated:YES];
        
        [TSAppConfig getInstance].name = [TSCommon trimWhiteSpaces:self.nameTextField.text];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iPodLibraryDidChange) name: MPMediaLibraryDidChangeNotification object:nil];
        [[MPMediaLibrary defaultMediaLibrary] beginGeneratingLibraryChangeNotifications];
        
        if([[TSAppConfig getInstance].type isEqualToString:@"Master"])
        {
            [self connectAllClients];
            
            CGRect _frame = CGRectMake(0, 0, 100, 100);
            [TSCommon showProcessViewWithFrame:_frame andMessage:@"Loading..."];
            
            [self performSelector:@selector(loadPlayListView) withObject:nil afterDelay:2.0f];
        }
        else
        {
            TSDeviceListViewController *viewController = [[TSDeviceListViewController alloc]initWithNibName:@"TSDeviceListViewController" bundle:nil modifyTableInteraction:NO];
            viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentModalViewController:viewController animated:YES];
        }
    }
}

- (void)iPodLibraryDidChange
{
    TSAppController *appController = [TSAppController sharedAppController];
    appController.isBroadcasted = NO;

    TSSCommunicationManager *commManager = [TSSCommunicationManager sharedInstance];
    [commManager.chatRoom stop];
    
    [self didSelectedLogoutButton];
    
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    if(musicPlayer.playbackState == MPMusicPlaybackStatePlaying)
        [musicPlayer pause];

    [appController doViewTransitionAnimation];
    exit(0);
}


#pragma mark -
#pragma mark Bonjour connection methods
#pragma mark -

- (void) connectAllClients
{
    TSLocalRoom *roomLoc = [[TSLocalRoom alloc] init];
    NSLog(@"%@",roomLoc);
    
    TSSCommunicationManager *commManager = [TSSCommunicationManager sharedInstance];
    commManager.chatRoom = roomLoc;
    commManager.localChatRoom = roomLoc;
    chatRoom.delegate = commManager;
    
    [commManager activate];
    
}

- (void)didSelectedLogoutButton
{
    if(chatRoom != nil)
    {
        [chatRoom stop];
    }
    
    [serverBrowser stop];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.netService stop];
}
#pragma mark -0
#pragma mark portrait
#pragma mark -


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL) shouldAutorotate
{
    return YES;
}

#pragma mark -
#pragma mark iPhone5

-(void)setLayoutOfRetina4
{
    if([TSCommon isRetina4])
    {
        bgImageView.frame = CGRectMake(bgImageView.frame.origin.x,bgImageView.frame.origin.y, bgImageView.frame.size.width, bgImageView.frame.size.height + 88);
        
        self.scrollView.frame = CGRectMake(self.scrollView.frame.origin.x,self.scrollView.frame.origin.y - 88, self.scrollView.frame.size.width, self.scrollView.frame.size.height + 88);
    }
}

@end
