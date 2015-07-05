//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSContactsViewController.m
// Description		:	TSContactsViewController class Implementation.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import "TSContactsViewController.h"
#import "TSAppConfig.h"

@interface TSContactsViewController ()

- (void) getAllContacts;
-(void)sendSms;
@end

@implementation TSContactsViewController
@synthesize selectedIndxPathArr;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    self.selectedIndxPathArr = [[NSMutableArray alloc]init];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    objContactArr = [[NSMutableArray alloc]init];
    [self.selectedIndxPathArr removeAllObjects];
    
    if([TSCommon isRetina4])
    {
        [self setLayoutOfRetina4];
    }
    else
    {
        [self.contactListTableView setFrame:CGRectMake(self.contactListTableView.frame.origin.x, self.contactListTableView.frame.origin.y, self.contactListTableView.frame.size.width, 364)];
    }

    
    [self getAllContacts];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setContactListTableView:nil];
    [self setBgImageView:nil];
    [super viewDidUnload];
}

- (void) getAllContacts
{
    NSString *ver = [[UIDevice currentDevice] systemVersion];

    float ver_float = [ver floatValue];
   
    __block BOOL accessGranted = NO;
    if(ver_float >= 6)
    {
            ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
            
            if (ABAddressBookRequestAccessWithCompletion != NULL) { // we're on iOS 6
                dispatch_semaphore_t sema = dispatch_semaphore_create(0);
                ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                    accessGranted = granted;
                    dispatch_semaphore_signal(sema);
                });
                dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
                dispatch_release(sema);
            }
            else { // we're on iOS 5 or older
                accessGranted = YES;
            }
    }
    

    if (accessGranted || ver_float < 6) {
        ABAddressBookRef addressBook = ABAddressBookCreate();
       // ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);

        CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);

        CFMutableArrayRef peopleMutable = CFArrayCreateMutableCopy(kCFAllocatorDefault,
                                                                 CFArrayGetCount(people),
                                                                  people);
        
        CFArraySortValues(peopleMutable,
                          CFRangeMake(0, CFArrayGetCount(peopleMutable)),
                          (CFComparatorFunction) ABPersonComparePeopleByName,
                          kABPersonSortByFirstName);
        
        CFRelease(people);
        
        for (CFIndex i = 0; i < CFArrayGetCount(peopleMutable); i++)
        {
            NSMutableDictionary *objContactDict = [[NSMutableDictionary alloc] init];
    
            ABRecordRef currentPerson = CFArrayGetValueAtIndex(peopleMutable, i);
            NSString *currentFirstName = CFBridgingRelease(ABRecordCopyValue(currentPerson, kABPersonFirstNameProperty));
            NSString *currentLastName = CFBridgingRelease(ABRecordCopyValue(currentPerson, kABPersonLastNameProperty));
            
            ABMultiValueRef phoneNumbers = (ABMultiValueRef)ABRecordCopyValue(currentPerson, kABPersonPhoneProperty);
            CFRelease(phoneNumbers);
            CFIndex numPhoneNums = ABMultiValueGetCount(phoneNumbers);
            NSString* phoneNumber;
                       
            
            if(((currentFirstName && ![currentFirstName isEqualToString:@""]) || (currentLastName && ![currentLastName isEqualToString:@""])) && numPhoneNums != 0)
            {
                phoneNumber = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
                NSLog(@"%@---%@",currentFirstName,phoneNumber);
                
                NSString *_contactName = @"";
                
                if(currentFirstName && currentLastName)
                    _contactName = [NSString stringWithFormat:@"%@ %@",currentFirstName, currentLastName];
                else if(currentFirstName && !currentLastName)
                    _contactName = currentFirstName;
                else if(!currentFirstName && currentLastName)
                    _contactName = currentLastName;

                
                [objContactDict setValue:_contactName forKey:@"ContactName"];
                [objContactDict setValue:phoneNumber forKey:@"ContactNo"];
                [objContactArr addObject:objContactDict];
            }
        }
        
        CFRelease(peopleMutable);
    }    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return objContactArr.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier    = @"Not Set";
    TSContactCell *tableCell = (TSContactCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    tableCell = nil;
    
    if (tableCell == nil)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"TSContactCell"
                                                       owner:[TSContactCell class]
                                                     options:nil];
        tableCell           = (TSContactCell*)[array objectAtIndex:0];
    }
    
    tableCell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableCell.tag = indexPath.row;
    tableCell.accessoryType = UITableViewCellAccessoryNone;
  
    if ( [self.selectedIndxPathArr indexOfObject:indexPath] == NSNotFound )
        tableCell.bgImageView.image = [UIImage imageNamed:@"greyBar.png"];
    else
        tableCell.bgImageView.image = [UIImage imageNamed:@"redBar.png"];
    
    NSDictionary *objDict =[objContactArr objectAtIndex:indexPath.row];
    tableCell.contactNameLabel.text = [objDict valueForKey:@"ContactName"];
    tableCell.contactNameLabel.textColor = [UIColor whiteColor];
    return tableCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TSContactCell *cell = (TSContactCell*)[self.contactListTableView cellForRowAtIndexPath:indexPath];
    
    if ( [self.selectedIndxPathArr indexOfObject:indexPath] == NSNotFound )
    {
        [self.selectedIndxPathArr addObject:indexPath];
        cell.bgImageView.image = [UIImage imageNamed:@"redBar.png"];
    }
    else
    {
        [self.selectedIndxPathArr removeObject:indexPath];
        cell.bgImageView.image = [UIImage imageNamed:@"greyBar.png"];
    }
    
}

- (IBAction)homeButtonPressed:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)sendButtonPressed:(id)sender
{
    selectedContactNumber = [[NSMutableArray alloc]init];
    for(int i = 0;i < self.selectedIndxPathArr.count;i++)
    {
        NSIndexPath *wer = [self.selectedIndxPathArr objectAtIndex:i];
        NSDictionary *objDic = [objContactArr objectAtIndex:wer.row];
        [selectedContactNumber addObject:[objDic valueForKey:@"ContactNo"]];
        
    }
    NSLog(@"%d",selectedContactNumber.count);
    [self sendSms];
}


-(void)sendSms
{
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        NSString *mastername = [TSAppConfig getInstance].name;
        NSString *smsText = [NSString stringWithFormat:@"%@ has invited you to join the Team Sync app using the following link: TeamSync://Launch_application",mastername ];
        controller.body = smsText;//@"TeamSync://Launch_application";
        controller.recipients = selectedContactNumber;
        controller.messageComposeDelegate = self;
        [self presentModalViewController:controller animated:YES];
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////
// Purpose     : SMS delegate for getting notification.
// Parameters  : Nil
// Return type : Nil
// Comments    : Nil
////////////////////////////////////////////////////////////////////////////////////////////////

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissModalViewControllerAnimated:YES];
    
    if (result == MessageComposeResultCancelled)
        NSLog(@"Message cancelled");
    else if (result == MessageComposeResultSent)
    {
        NSLog(@"Message sent");
        [TSCommon showAlert:@"Invitation sent successfully."];
        [self.selectedIndxPathArr removeAllObjects];
        [_contactListTableView reloadData];
    }
    else
        NSLog(@"Message failed");
}

- (void)setLayoutOfRetina4
{
    NSLog(@"setLayoutOfRetina4");
    if([TSCommon isRetina4])
    {
       self.bgImageView.frame = CGRectMake(self.bgImageView.frame.origin.x,self.bgImageView.frame.origin.y, self.bgImageView.frame.size.width, self.bgImageView.frame.size.height + 88);
        
        self.contactListTableView.frame = CGRectMake(self.contactListTableView.frame.origin.x,self.contactListTableView.frame.origin.y, self.contactListTableView.frame.size.width, self.contactListTableView.frame.size.height);
    }
}
@end
