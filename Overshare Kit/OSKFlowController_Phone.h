//
//  OSKFlowController_Phone.h
//  Overshare
//
//  Created by Jared Sinclair on 10/11/13.
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//

#import "OSKFlowController.h"

@interface OSKFlowController_Phone : OSKFlowController

@property (strong, nonatomic, readonly) UIViewController *presentingViewController;

- (instancetype)initWithActivity:(OSKActivity *)activity
               sessionIdentifier:(NSString *)sessionIdentifier
       activityCompletionHandler:(OSKActivityCompletionHandler)completion
                        delegate:(id<OSKFlowControllerDelegate>)delegate
        presentingViewController:(UIViewController *)presentingViewController;

@end





