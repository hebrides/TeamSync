
#import "UINavigationController+Common.h"


@implementation UINavigationController (Common)

- (UIViewController*) viewCtrlWithClass:(Class) viewCtrlClass {
	for (UIViewController *ctrl in self.viewControllers) {
		if ( [ctrl isMemberOfClass:viewCtrlClass] ) {
			return ctrl;
		}
	}
	
	return nil;
}

@end

