//
//  SelectMasterViewControllerViewController.h
//  TeamSync
//
//  Created for SMG Mobile on 3/26/12.
//  
//


#import "BaseTableViewController.h"

@interface SelectMasterViewControllerViewController : BaseTableViewController {
    NSInteger currentSelectedMaster;
}


- (void)logoutAction;
- (void)joinAction;

@end