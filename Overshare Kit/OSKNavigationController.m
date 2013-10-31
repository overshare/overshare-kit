//
//  OSKNavigationController.m
//  Overshare
//
//  Created by Jared Sinclair on 10/24/13.
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//

#import "OSKNavigationController.h"

#import "OSKPresentationManager.h"
#import "UIImage+OSKUtilities.h"

@interface OSKNavigationController ()

@end

@implementation OSKNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        [self setupUIAppearance];
    }
    return self;
}

- (void)setupUIAppearance {
    OSKPresentationManager *presentationManager = [OSKPresentationManager sharedInstance];
    self.navigationBar.tintColor = presentationManager.color_action;
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:presentationManager.color_text};
    UIBarStyle barStyle;
    if (presentationManager.sheetStyle == OSKActivitySheetViewControllerStyle_Dark) {
        barStyle = UIBarStyleBlack;
    } else {
        barStyle = UIBarStyleDefault;
    }
    [self.navigationBar setBarStyle:barStyle];
    
    if ([presentationManager toolbarsUseUnjustifiablyBorderlessButtons] == NO) {
        UIEdgeInsets insets = UIEdgeInsetsMake(5,4,5,4);
        UIImage *sourceImage_normal = [UIImage imageNamed:@"osk-navbarButton.png"];
        UIImage *barButtonImage_normal = [[UIImage osk_maskedImage:sourceImage_normal color:presentationManager.color_action] resizableImageWithCapInsets:insets];
        UIImage *sourceImage_highlighted = [UIImage imageNamed:@"osk-navbarButton-highlighted.png"];
        UIImage *barButtonImage_highlighted = [[UIImage osk_maskedImage:sourceImage_highlighted color:presentationManager.color_action] resizableImageWithCapInsets:insets];
        UIImage *sourceImage_disabled = [UIImage imageNamed:@"osk-navbarButton-disabled.png"];
        UIImage *barButtonImage_disabled = [[UIImage osk_maskedImage:sourceImage_disabled color:presentationManager.color_text] resizableImageWithCapInsets:insets];
        
        [[UIBarButtonItem appearanceWhenContainedIn:[OSKNavigationController class], nil] setBackgroundImage:barButtonImage_normal
                                                                                                    forState:UIControlStateNormal
                                                                                                       style:UIBarButtonItemStyleBordered
                                                                                                  barMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearanceWhenContainedIn:[OSKNavigationController class], nil] setBackgroundImage:barButtonImage_highlighted
                                                                                                    forState:UIControlStateHighlighted
                                                                                                       style:UIBarButtonItemStyleBordered
                                                                                                  barMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearanceWhenContainedIn:[OSKNavigationController class], nil] setBackgroundImage:barButtonImage_disabled
                                                                                                    forState:UIControlStateDisabled
                                                                                                       style:UIBarButtonItemStyleBordered
                                                                                                  barMetrics:UIBarMetricsDefault];
        
        [[UIBarButtonItem appearanceWhenContainedIn:[OSKNavigationController class], nil] setBackgroundImage:barButtonImage_normal
                                                                                                    forState:UIControlStateNormal
                                                                                                       style:UIBarButtonItemStyleDone
                                                                                                  barMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearanceWhenContainedIn:[OSKNavigationController class], nil] setBackgroundImage:barButtonImage_highlighted
                                                                                                    forState:UIControlStateHighlighted
                                                                                                       style:UIBarButtonItemStyleDone
                                                                                                  barMetrics:UIBarMetricsDefault];
        [[UIBarButtonItem appearanceWhenContainedIn:[OSKNavigationController class], nil] setBackgroundImage:barButtonImage_disabled
                                                                                                    forState:UIControlStateDisabled
                                                                                                       style:UIBarButtonItemStyleDone
                                                                                                  barMetrics:UIBarMetricsDefault];
    }
}

@end












