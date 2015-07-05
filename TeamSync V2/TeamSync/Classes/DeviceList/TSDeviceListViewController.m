//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSDeviceListViewController.m
// Description		:	TSDeviceListViewController class Implementation.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import "TSDeviceListViewController.h"
#import "TSPlayListTableViewCell.h"
#import "TSCommon.h"
#import "TSSigninViewController.h"
#import "TSClientSongListViewController.h"
#import "TSClientPlaySongViewController.h"

@interface TSDeviceListViewController ()
- (void)setLayoutOfRetina4;
- (void)joinCommunication;
- (void) removeProgressView;
- (void)removeNotifications;
@end

@implementation TSDeviceListViewController
@synthesize browser;
@synthesize services;
@synthesize serverBrowser;
@synthesize deviceListTableview;
@synthesize chatRoom;
@synthesize selectedRowIndex;
@synthesize selectedDevices;
@synthesize isModifyTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil modifyTableInteraction:(BOOL)isModify
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.selectedRowIndex = -1;
        self.selectedDevices = [[NSMutableArray alloc]init];
        isModifyTableView = isModify;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appController = [TSAppController sharedAppController];
    if(!isModifyTableView)
    {
        [joinButton setEnabled:NO];
    }
    else
    {
        [joinButton setEnabled:YES];
        isConnected = FALSE;
    }
    [self.deviceListTableview setUserInteractionEnabled:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshClientSettings) name:@"ConnectionTerminatedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDeviceListTableView) name:@"ClientArrayModifiedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestApproved) name:@"JoinRequestApproval" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestRejected) name:@"JoinRequestRejected" object:nil];
    
    [self setLayoutOfRetina4];

    disconnectbutton.hidden = YES;
    
    if([[TSAppConfig getInstance].type isEqualToString:@"Master"])
    {
        self.deviceListTableview.allowsMultipleSelection = YES;
        titleLabel.text = @"Disconnect";
    }
    else
    {
        titleLabel.text = @"Server List";
        self.deviceListTableview.allowsMultipleSelection = NO;
    }
    
    [self.selectedDevices removeAllObjects];
    
    serverBrowser = [[TSServerBrowser alloc] init];
    serverBrowser.delegate = self;
    [serverBrowser start];

}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ConnectionTerminatedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ClientArrayModifiedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"JoinRequestApproval" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"JoinRequestRejected" object:nil];
}

- (void) refreshClientSettings
{
    [self removeProgressView];
    [deviceListTableview setUserInteractionEnabled:YES];
    [self updateServerList];
    [self removeNotifications];
    [appController loadSignInScreenOnTermination];
}

- (void)viewWillAppear:(BOOL)animated
{
    if([[TSAppConfig getInstance].type isEqualToString:@"Master"])
    {
        cancelButton.hidden = NO;
        doneButton.hidden = NO;
        joinButton.hidden = YES;
        logoutButton.hidden = YES;
    }
    else
    {
        cancelButton.hidden = YES;
        doneButton.hidden = YES;
        joinButton.hidden = NO;
        logoutButton.hidden = NO;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    bgImageView = nil;
    self.serverBrowser = nil;
    titleLabel = nil;
    [self setDeviceListTableview:nil];
    cancelButton = nil;
    doneButton = nil;
    logoutButton = nil;
    joinButton = nil;

    disconnectbutton = nil;
    [super viewDidUnload];
}

- (IBAction)onCancelButtonPressed:(id)sender
{
    [self.selectedDevices removeAllObjects];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)onDoneButtonPressed:(id)sender
{
    if(self.selectedDevices && self.selectedDevices.count > 0)
    {
        commManager = [TSSCommunicationManager sharedInstance];
        NSMutableArray *array = [NSMutableArray arrayWithArray:commManager.localChatRoom.clientSet.array];       
        
        NSMutableArray *objClientTempArr = [[NSMutableArray alloc]init];
        for(NSIndexPath *objIndxPth in self.selectedDevices)
        {
            TSConnection *conn = [array objectAtIndex:objIndxPth.row];
            [conn close];
            [commManager.localChatRoom.clientSet removeObject:conn];            
        }
        
        if(commManager.localChatRoom.clientArr && commManager.localChatRoom.clientArr.count > 0)
        {
            BOOL isExists;
            for(int i = 0;i < commManager.localChatRoom.clientArr.count;i++)
            {
                isExists = false;
                for(NSIndexPath *objIndxPth in self.selectedDevices)
                {
                    if(objIndxPth.row == i)
                    {
                        isExists = true;
                    }
                }
                if(!isExists)
                {
                    [objClientTempArr addObject:[commManager.localChatRoom.clientArr objectAtIndex:i]];
                }
            }
            [commManager.localChatRoom.clientArr removeAllObjects];
            commManager.localChatRoom.clientArr = [NSMutableArray arrayWithArray:objClientTempArr];
        }
    }

    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)onLogoutButtonPressed:(id)sender
{
    if (appController.connectionTimer)
    {
		[appController.connectionTimer invalidate];
		appController.connectionTimer = nil;
    }

    [self.selectedDevices removeAllObjects];
    self.selectedRowIndex = -1;
    [joinButton setEnabled:NO];
    [deviceListTableview setUserInteractionEnabled:YES];
    
    commManager = [TSSCommunicationManager sharedInstance];
    [commManager.chatRoom stop];

    TSSigninViewController *viewController = [[TSSigninViewController alloc]initWithNibName:@"TSSigninViewController" bundle:nil];
    viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:viewController animated:YES];

}

- (IBAction)onJoinbuttonPressed:(id)sender
{
    [self joinCommunication];
}

- (IBAction)onDisconnectbuttonPressed:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"VolumeChangedNotification"
                                                  object:nil];
    
    MPMusicPlaybackState playbackState = appController.musicPlayer.playbackState;
    
    if (playbackState == MPMusicPlaybackStatePlaying)
    {
        [appController.musicPlayer pause];
    }
    
    commManager = [TSSCommunicationManager sharedInstance];
    [commManager.chatRoom stop];
    
    [TSAppConfig getInstance].songInformationDict = nil;
    [TSAppConfig getInstance].isEnteredBackGround = NO;
    
    [TSCommon showAlert:@"Disconnected from Master."];
    [appController loadSignInScreenOnTermination];
    
    joinButton.hidden = NO;
    disconnectbutton.hidden = YES;
    
    if (appController.connectionTimer)
    {
		[appController.connectionTimer invalidate];
		appController.connectionTimer = nil;
    }

}

#pragma mark -
#pragma mark UITableview delegate methods
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount = 0;
    if(servArr)
    {
        servArr = nil;
    }
    servArr = [[NSMutableArray alloc]init];
    for(NSNetService* server in serverBrowser.servers)
    {
        NSString *selectedType = @"";
        NSString *name = @"";
        
        NSArray *listItems = [[server name] componentsSeparatedByString:@"/"];
        if(listItems && listItems.count > 0)
        {
            selectedType = [listItems objectAtIndex:listItems.count - 1];
            name = [listItems objectAtIndex:0];
        }
        

        if([[TSAppConfig getInstance].type isEqualToString:@"Master"])
        {
            commManager = [TSSCommunicationManager sharedInstance];
            rowCount = commManager.localChatRoom.clientArr.count;
        }
        else
        {            
            if(!([TSAppConfig getInstance].name == name) && !([TSAppConfig getInstance].type == selectedType))
            {
                [servArr addObject:server];
            }
            
            rowCount = servArr.count;
        }
    }
    if(rowCount == 0)
    {
        [joinButton setEnabled:NO];
        [deviceListTableview setUserInteractionEnabled:NO];
    }
    else
    {
        if(isModifyTableView || !isConnected)
        {
            [joinButton setEnabled:YES];
            [deviceListTableview setUserInteractionEnabled:YES];
        }
    }
    
    return rowCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 52.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier    = @"Not Set";
    TSPlayListTableViewCell *tableCell = (TSPlayListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    tableCell = nil;
    
    if (tableCell == nil)
    {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"TSPlayListTableViewCell"
                                                       owner:[TSPlayListTableViewCell class]
                                                     options:nil];
        tableCell           = (TSPlayListTableViewCell*)[array objectAtIndex:0];
    }
    
    tableCell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableCell.tag = indexPath.row;
    tableCell.accessoryType = UITableViewCellAccessoryNone;
    
    if([[TSAppConfig getInstance].type isEqualToString:@"Master"])
    {
        tableCell.playListNameLabel.text = [commManager.localChatRoom.clientArr objectAtIndex:indexPath.row];
       
        if ( [self.selectedDevices indexOfObject:indexPath] == NSNotFound )
            tableCell.bgImageView.image = [UIImage imageNamed:@"greyBar.png"];
        else
            tableCell.bgImageView.image = [UIImage imageNamed:@"redBar.png"];
    }
    else
    {
        // Set cell's text to device name
        NSNetService* server = [servArr objectAtIndex:indexPath.row];
        NSArray *listItems = [[server name] componentsSeparatedByString:@"/"];
        if(listItems && listItems.count > 0)
        {
            tableCell.playListNameLabel.text = [listItems objectAtIndex:0];
          
            if(self.selectedDevices && self.selectedDevices.count > 0)
            {
                if([[self.selectedDevices objectAtIndex:0] isEqualToString:tableCell.playListNameLabel.text])
                {
                    tableCell.bgImageView.image = [UIImage imageNamed:@"redBar.png"];
                }
                else
                {
                    tableCell.bgImageView.image = [UIImage imageNamed:@"greyBar.png"];
                }
            }
            
            
        }
    }

    return tableCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TSPlayListTableViewCell *cell = (TSPlayListTableViewCell*)[deviceListTableview cellForRowAtIndexPath:indexPath];
    selectedMasterName = cell.playListNameLabel.text;
   
    if([[TSAppConfig getInstance].type isEqualToString:@"Master"])
    {
        if ( [self.selectedDevices indexOfObject:indexPath] == NSNotFound )
        {
            [self.selectedDevices addObject:indexPath];
            cell.bgImageView.image = [UIImage imageNamed:@"redBar.png"];
        }
        else
        {
            [self.selectedDevices removeObject:indexPath];
            cell.bgImageView.image = [UIImage imageNamed:@"greyBar.png"];
        }
    }
    else
    {
        [self.selectedDevices removeAllObjects];
        cell.bgImageView.image = [UIImage imageNamed:@"redBar.png"];
        [self.selectedDevices addObject:selectedMasterName];
        self.selectedRowIndex = indexPath.row;

        [joinButton setEnabled:YES];
    }

    [self.deviceListTableview reloadData];
}

- (void) joinCommunication
{
    if ( self.selectedRowIndex == -1 )
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:APP_NAME message:@"Select a master" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSString *textMessage =  [NSString stringWithFormat:@"Connecting with '%@'",selectedMasterName];
    CGRect _frame = CGRectMake(0, 0, 200, 100);
    [TSCommon showProcessViewWithFrame:_frame andMessage:textMessage];

    NSNetService* selectedServer = [serverBrowser.servers objectAtIndex:self.selectedRowIndex];
    
    // Create chat room that will connect to that chat server
    if(room != nil)
    {
        room = nil;
    }
    room = [[TSRemoteRoom alloc] initWithNetService:selectedServer];
       
    if(commManager != nil)
    {
        commManager = nil;
    }
    commManager = [TSSCommunicationManager sharedInstance];
    commManager.chatRoom = room;
    chatRoom.delegate = commManager;
    commManager.delegate = self;
    
    [commManager activate];
    [joinButton setEnabled:NO];
    [deviceListTableview setUserInteractionEnabled:NO];

    [self performSelector:@selector(sendAddressOfConnectedClient) withObject:nil afterDelay:1.5f];

}

- (void) sendAddressOfConnectedClient
{
    if([TSCommon isNetworkConnected])
    {
        [room  broadcastChatMessage:@"" andDetails:nil fromUser:[TSAppConfig getInstance].name selectedView:kConnectionStatus];
    
        appController.connectionTimer = [NSTimer scheduledTimerWithTimeInterval:180 target:self selector:@selector(hideAndDismissProgressView) userInfo:nil repeats:NO];
    }
    else
    {
        [TSCommon showAlert:@"Currently there is no connectivity, Please try later when you have WiFi or Cell Phone Signals."];
    }
}


- (void) hideAndDismissProgressView
{
    [TSCommon dismissProcessView];
    
    [TSCommon showAlert:@"Join communication request not accepted by Master."];
    
    if (appController.connectionTimer)
    {
		[appController.connectionTimer invalidate];
		appController.connectionTimer = nil;
    }
}

- (void) connectAllClients
{
    [serverBrowser stop];
}

- (void) removeProgressView
{
    if (appController.connectionTimer)
    {
		[appController.connectionTimer invalidate];
		appController.connectionTimer = nil;
    }
    
    [TSCommon dismissProcessView];

    [self.deviceListTableview reloadData];
    
}

- (void) requestApproved
{
    isConnected = TRUE;
    [self removeProgressView];
    [joinButton setEnabled:NO];
    [self.deviceListTableview setUserInteractionEnabled:NO];
}

- (void) requestRejected
{
    isConnected = FALSE;
    [self removeProgressView];
    [joinButton setEnabled:YES];
    [self.deviceListTableview setUserInteractionEnabled:YES];
}

#pragma mark -
#pragma mark TSServerBrowserDelegate methods
#pragma mark -

- (void)updateServerList
{
    [self.deviceListTableview performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

#pragma mark -
#pragma mark TSSCommunicationManagerDelegate methods
#pragma mark -

- (void) updateDeviceListTableView
{
    [self.deviceListTableview reloadData];
}

- (void) hideProgressView
{
    [self removeProgressView];
}

- (void)showDisconnectButton
{
    joinButton.hidden = YES;
    disconnectbutton.hidden = NO;
}

- (void)showSongList:(NSDictionary*)songDict
{
    [appController showClientSongList:songDict]; 
}

- (void)showSongListWithMusic:(NSDictionary*)songDict
{
    [appController showClientSongListWithMusic:songDict];
}

- (void)resetDurationSliderinPlaySongView
{
    [appController resetDurationSliderinClientView];
}

- (void)showSongDetailsScreen:(NSDictionary*)songDict
{
    [appController showClientSongDetails:songDict];
}

- (void)didChangedPlayState:(NSDictionary*)detailsDict
{
    [appController changeSongPlayState:detailsDict];
}

- (void)didChangedSongvolume:(NSString*)volume
{
    [appController changeSongVolume:volume];
}

- (void)didChangedSongDuration:(NSDictionary*)durationDict
{
    [appController changeSongDuration:durationDict];
}

#pragma mark -
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

- (void)setLayoutOfRetina4
{
    if([TSCommon isRetina4])
    {
        bgImageView.frame = CGRectMake(bgImageView.frame.origin.x,bgImageView.frame.origin.y, bgImageView.frame.size.width, bgImageView.frame.size.height + 88);
        
        self.deviceListTableview.frame = CGRectMake(self.deviceListTableview.frame.origin.x,self.deviceListTableview.frame.origin.y, self.deviceListTableview.frame.size.width, self.deviceListTableview.frame.size.height + 88);
    }
}

@end
