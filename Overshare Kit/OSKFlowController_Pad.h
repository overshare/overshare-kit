//
//  OSKFlowController_Pad.h
//  Overshare
//
//  Created by Jared Sinclair on 10/11/13.
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//

#import "OSKFlowController.h"

@interface OSKFlowController_Pad : OSKFlowController

- (instancetype)initWithActivity:(OSKActivity *)activity
               sessionIdentifier:(NSString *)sessionIdentifier
       activityCompletionHandler:(OSKActivityCompletionHandler)completion
                        delegate:(id<OSKFlowControllerDelegate>)delegate
               popoverController:(UIPopoverController *)popoverController
        presentingViewController:(UIViewController *)presentingViewController;

@end
