//
//  OSKFlowController_Pad.m
//  Overshare
//
//  Created by Jared Sinclair on 10/11/13.
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//

#import "OSKFlowController_Pad.h"

#import "OSKNavigationController.h"
#import "OSKPresentationManager.h"

@interface OSKFlowController_Pad ()

@property (weak, nonatomic) UIPopoverController *popoverController;
@property (weak, nonatomic) UIViewController *systemViewController;
@property (weak, nonatomic) UIViewController *presentingViewController;
@property (strong, nonatomic) OSKNavigationController *navigationController;

@end

@implementation OSKFlowController_Pad

- (instancetype)initWithActivity:(OSKActivity *)activity sessionIdentifier:(NSString *)sessionIdentifier activityCompletionHandler:(OSKActivityCompletionHandler)completion delegate:(id<OSKFlowControllerDelegate>)delegate popoverController:(UIPopoverController *)popoverController presentingViewController:(UIViewController *)presentingViewController {
    self = [super initWithActivity:activity sessionIdentifier:sessionIdentifier activityCompletionHandler:completion delegate:delegate];
    if (self) {
        _popoverController = popoverController;
        _presentingViewController = presentingViewController;
    }
    return self;
}

- (void)presentViewControllerAppropriately:(UIViewController *)viewController setAsNewRoot:(BOOL)isNewRoot {
    if (self.navigationController == nil) {
        self.navigationController = [[OSKNavigationController alloc] initWithRootViewController:viewController];
        [self.navigationController setModalPresentationStyle:UIModalPresentationFormSheet];
        [self.delegate flowController:self willPresentViewController:viewController inNavigationController:self.navigationController];
        [self.presentingViewController presentViewController:self.navigationController animated:YES completion:nil];
    }
    else if (isNewRoot) {
        [self.delegate flowController:self willPresentViewController:viewController inNavigationController:self.navigationController];
        [self.navigationController setViewControllers:@[viewController] animated:YES];
    } else {
        [self.delegate flowController:self willPresentViewController:viewController inNavigationController:self.navigationController];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)presentSystemViewControllerAppropriately:(UIViewController *)systemViewController {
    [self.delegate flowController:self willPresentSystemViewController:systemViewController];
    if (self.systemViewController == nil) {
        [self setSystemViewController:systemViewController];
        if ([systemViewController isKindOfClass:[UIActivityViewController class]]) {
            [self.popoverController.contentViewController presentViewController:systemViewController animated:YES completion:nil];
        } else {
            [self.presentingViewController presentViewController:systemViewController animated:YES completion:nil];
        }
    }
}

- (void)dismissViewControllers {
    if (self.systemViewController) {
        __weak OSKFlowController_Pad *weakSelf = self;
        [self.systemViewController dismissViewControllerAnimated:YES completion:^{
            [weakSelf setSystemViewController:nil];
        }];
    }
    if (self.navigationController) {
        __weak OSKFlowController_Pad *weakSelf = self;
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            [weakSelf setNavigationController:nil];
        }];
    }
}

@end
