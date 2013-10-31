//
//  OSKFlowController.h
//  Overshare
//
//  Created by Jared Sinclair on 10/11/13.
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//

@import UIKit;

#import "OSKActivity.h"

@class OSKFlowController;
@class OSKNavigationController;
@protocol OSKPurchasingViewController;
@protocol OSKAuthenticationViewController;
@protocol OSKPublishingViewController;

@protocol OSKFlowControllerDelegate <NSObject>

- (void)flowController:(OSKFlowController *)controller
willPresentViewController:(UIViewController *)viewController
     inNavigationController:(OSKNavigationController *)navigationController;

- (void)flowController:(OSKFlowController *)controller
willPresentSystemViewController:(UIViewController *)systemViewController;

- (void)flowControllerDidBeginActivity:(OSKFlowController *)controller shouldDismissActivitySheet:(BOOL)dismiss;

- (void)flowControllerDidFinish:(OSKFlowController *)controller; // Activity finished

- (void)flowControllerDidCancel:(OSKFlowController *)controller;

@end

@interface OSKFlowController : NSObject

// OSKFlowController should be used via one of its concrete subclasses, OSKFlowController_Phone or OSKFlowController_Pad.

- (instancetype)initWithActivity:(OSKActivity *)activity
               sessionIdentifier:(NSString *)sessionIdentifier
       activityCompletionHandler:(OSKActivityCompletionHandler)completion
                        delegate:(id <OSKFlowControllerDelegate>)delegate;

@property (strong, nonatomic, readonly) NSString *sessionIdentifier;
@property (weak, nonatomic, readonly) id <OSKFlowControllerDelegate> delegate;
@property (strong, nonatomic, readonly) OSKActivity *activity;

- (void)start;

@end

@interface OSKFlowController (RequiredForSubclasses)

- (void)presentViewControllerAppropriately:(UIViewController *)viewController setAsNewRoot:(BOOL)isNewRoot;
- (void)presentSystemViewControllerAppropriately:(UIViewController *)systemViewController;
- (void)dismissViewControllers;

@end





