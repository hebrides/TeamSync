//////////////////////////////////////////////////////////////////////////////////////
// File Name		:	TSSplashViewController.m
// Description		:	TSSplashViewController class Implementation.
// Built for SMG Mobile


//////////////////////////////////////////////////////////////////////////////////////

#import "TSSplashViewController.h"
#import "TSCommon.h"

@interface TSSplashViewController ()
-(void)setLayoutOfRetina4;
@end

@implementation TSSplashViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.bgImageView.image = [TSCommon loadImageResource:SPLASHIMAGE];
    
    [self setLayoutOfRetina4];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark portrait
#pragma mark -

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
        self.bgImageView.frame = CGRectMake(self.bgImageView.frame.origin.x,self.bgImageView.frame.origin.y, self.bgImageView.frame.size.width, self.bgImageView.frame.size.height + 88);
    }
}

- (void)viewDidUnload
{
    [self setBgImageView:nil];
    [super viewDidUnload];
}
@end
