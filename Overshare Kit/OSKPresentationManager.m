//
//  OSKPresentationManager.m
//  Overshare
//
//  Created by Jared Sinclair on 10/13/13.
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//

#import "OSKPresentationManager.h"

NSString * const OSKActivityOption_ActivitySheetDismissalHandler = @"OSKActivityOption_ActivitySheetDismissalHandler";

@import MessageUI;

#import "OSKColors.h"
#import "OSKActivity.h"
#import "OSKActivity_ManagedAccounts.h"
#import "OSKActivitySheetDelegate.h"
#import "OSKActivitiesManager.h"
#import "OSKActivitySheetViewController.h"
#import "OSKAirDropViewController.h"
#import "OSKAppDotNetAuthenticationViewController.h"
#import "OSKApplicationCredential.h"
#import "OSKFacebookPublishingViewController.h"
#import "OSKLogger.h"
#import "OSKMicroblogPublishingViewController.h"
#import "OSKPublishingViewController.h"
#import "OSKFlowController.h"
#import "OSKFlowController_Phone.h"
#import "OSKFlowController_Pad.h"
#import "OSKShareableContent.h"
#import "OSKShareableContentItem.h"
#import "OSKUsernamePasswordViewController.h"
#import "OSKMessageComposeViewController.h"
#import "OSKMailComposeViewController.h"
#import "OSKNavigationController.h"

#import "UIViewController+OSKUtilities.h"
#import "UIColor+OSKUtility.h"

static CGFloat OSKPresentationManagerActivitySheetPresentationDuration = 0.3f;
static CGFloat OSKPresentationManagerActivitySheetDismissalDuration = 0.16f;

@interface OSKPresentationManager ()
<
    OSKFlowControllerDelegate,
    OSKActivitySheetDelegate,
    UIPopoverControllerDelegate
>

// GENERAL
@property (strong, nonatomic, readwrite) NSMutableDictionary *flowControllers;
@property (strong, nonatomic, readwrite) OSKActivitySheetViewController *activitySheetViewController;
@property (assign, nonatomic, readwrite) BOOL isAnimating;

// IPHONE
@property (strong, nonatomic) UIView *shadowView;
@property (strong, nonatomic) UIViewController *presentingViewController;
@property (strong, nonatomic) UIViewController *parentMostViewController;

// IPAD
@property (strong, nonatomic, readwrite) UIPopoverController *popoverController;
@property (assign, nonatomic, readonly) BOOL isPresentingViaPopover;

@end

@implementation OSKPresentationManager

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static OSKPresentationManager * sharedInstance;
    dispatch_once(&once, ^ { sharedInstance = [[self alloc] init]; });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _flowControllers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - Public Methods

- (void)presentActivitySheetForContent:(OSKShareableContent *)content presentingViewController:(UIViewController *)presentingViewController options:(NSDictionary *)options {
    [self setPresentingViewController:presentingViewController];
    NSArray *activities = nil;
    OSKActivitiesManager *manager = [OSKActivitiesManager sharedInstance];
    activities = [manager validActivitiesForContent:content options:options];
    OSKActivitySheetViewController *sheet = nil;
    sheet = [[OSKActivitySheetViewController alloc] initWithActivities:activities delegate:self usePopoverLayout:NO];
    [sheet setActivityCompletionHandler:options[OSKActivityOption_ActivityCompletionHandler]];
    [sheet setDismissalHandler:options[OSKActivityOption_ActivitySheetDismissalHandler]];
    [sheet setTitle:content.title];
    [self presentSheet:sheet fromViewController:presentingViewController];
}

- (void)presentActivitySheetForContent:(OSKShareableContent *)content presentingViewController:(UIViewController *)presentingViewController popoverFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated options:(NSDictionary *)options {
    
    [self setPresentingViewController:presentingViewController];
    
    NSArray *activities = nil;
    OSKActivitiesManager *manager = [OSKActivitiesManager sharedInstance];
    activities = [manager validActivitiesForContent:content options:options];
    
    OSKActivitySheetViewController *sheet = nil;
    sheet = [[OSKActivitySheetViewController alloc] initWithActivities:activities delegate:self usePopoverLayout:YES];
    [sheet setActivityCompletionHandler:options[OSKActivityOption_ActivityCompletionHandler]];
    [sheet setDismissalHandler:options[OSKActivityOption_ActivitySheetDismissalHandler]];
    [sheet setTitle:content.title];
    
    [self setActivitySheetViewController:sheet];
    
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:sheet];
    [self setPopoverController:popover];
    [popover setDelegate:self];
    [popover setBackgroundColor:[self color_translucentBackground]];
    
    [popover presentPopoverFromRect:rect inView:view permittedArrowDirections:arrowDirections animated:animated];
}

- (void)presentActivitySheetForContent:(OSKShareableContent *)content presentingViewController:(UIViewController *)presentingViewController popoverFromBarButtonItem:(UIBarButtonItem *)item permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated options:(NSDictionary *)options {
    
    [self setPresentingViewController:presentingViewController];
    NSArray *activities = nil;
    OSKActivitiesManager *manager = [OSKActivitiesManager sharedInstance];
    activities = [manager validActivitiesForContent:content options:options];
    
    OSKActivitySheetViewController *sheet = nil;
    sheet = [[OSKActivitySheetViewController alloc] initWithActivities:activities delegate:self usePopoverLayout:YES];
    [sheet setActivityCompletionHandler:options[OSKActivityOption_ActivityCompletionHandler]];
    [sheet setDismissalHandler:options[OSKActivityOption_ActivitySheetDismissalHandler]];
    [sheet setTitle:content.title];
    
    [self setActivitySheetViewController:sheet];
    
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:sheet];
    [self setPopoverController:popover];
    [popover setDelegate:self];
    [popover setBackgroundColor:[self color_translucentBackground]];
    
    [popover presentPopoverFromBarButtonItem:item permittedArrowDirections:arrowDirections animated:animated];
}

#pragma mark - Presentation & Dismissal

- (void)presentSheet:(OSKActivitySheetViewController *)sheet fromViewController:(UIViewController *)presentingViewController {
    if ([self isPresenting] == NO) {
        [self setActivitySheetViewController:sheet];
        [self setIsAnimating:YES];
        self.parentMostViewController = [UIViewController osk_parentMostViewControllerForPresentingViewController:presentingViewController];
        [self setupShadowView:self.parentMostViewController.view];
        
        CGFloat sheetHeight = [sheet visibleSheetHeightForCurrentLayout];
        CGRect targetFrame = self.parentMostViewController.view.bounds;
        CGRect initialFrame = targetFrame;
        initialFrame.origin.y += sheetHeight;
        
        [sheet.view setFrame:initialFrame];
        [sheet viewWillAppear:YES];
        [self.parentMostViewController.view addSubview:sheet.view];
        
        [UIView animateWithDuration:OSKPresentationManagerActivitySheetPresentationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [sheet.view setFrame:targetFrame];
            [self.shadowView setAlpha:1.0];
        } completion:^(BOOL finished) {
            [sheet viewDidAppear:YES];
            [self setIsAnimating:NO];
        }];
    } else {
        OSKLog(@"Attempting to present a second activity sheet while the first is still visible.");
    }
}

- (void)dismissActivitySheet {
    if ([self isPresentingViaPopover]) {
        [self dismissActivitySheet_Pad];
    } else {
        [self dismissActivitySheet_Phone];
    }
}

- (void)dismissActivitySheet_Phone {
    if ([self isAnimating] == NO && [self isPresenting] == YES) {
        [self setIsAnimating:YES];
        OSKActivitySheetViewController *sheet = self.activitySheetViewController;
        CGRect targetFrame = sheet.view.frame;
        targetFrame.origin.y += [sheet visibleSheetHeightForCurrentLayout];
        [sheet viewWillDisappear:YES];
        [UIView animateWithDuration:OSKPresentationManagerActivitySheetDismissalDuration delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [sheet.view setFrame:targetFrame];
            [self.shadowView setAlpha:0];
        } completion:^(BOOL finished) {
            [sheet.view removeFromSuperview];
            [sheet viewDidDisappear:YES];
            [self tearDownShadowView];
            [self setActivitySheetViewController:nil];
            [self setPresentingViewController:nil];
            [self setIsAnimating:NO];
            if (sheet.dismissalHandler) {
                sheet.dismissalHandler();
            }
        }];
    }
}

- (void)dismissActivitySheet_Pad {
    if (self.isAnimating == NO) {
        [self setIsAnimating:YES];
        [self.popoverController dismissPopoverAnimated:YES];
        OSKActivitySheetDismissalHandler handler = [self.activitySheetViewController.dismissalHandler copy];
        __weak OSKPresentationManager *weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [weakSelf setPopoverController:nil];
            [weakSelf setPresentingViewController:nil];
            [weakSelf setIsAnimating:NO];
            if (handler) {
                handler();
            }
        });
    }
}

#pragma mark - Popover Delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    OSKActivitySheetDismissalHandler handler = [self.activitySheetViewController.dismissalHandler copy];
    [self setPopoverController:nil];
    [self setActivitySheetViewController:nil];
    [self setIsAnimating:NO]; // just in case
    if (handler) {
        handler();
    }
}

- (void)popoverController:(UIPopoverController *)popoverController willRepositionPopoverToRect:(inout CGRect *)rect inView:(inout UIView *__autoreleasing *)view {
    if ([self.viewControllerDelegate respondsToSelector:@selector(presentationManager:willRepositionPopoverToRect:inView:)]) {
        [self.viewControllerDelegate presentationManager:self willRepositionPopoverToRect:rect inView:view];
    }
}

#pragma mark - Convenience

- (BOOL)isPresentingViaPopover {
    return (self.popoverController != nil);
}

- (BOOL)isPresenting {
    return (self.activitySheetViewController != nil);
}

- (void)setupShadowView:(UIView *)superview {
    if (self.shadowView == nil) {
        self.shadowView = [[UIView alloc] initWithFrame:superview.bounds];
        self.shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.shadowView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.25];
        self.shadowView.alpha = 0;
        [superview addSubview:self.shadowView];
    }
}

- (void)tearDownShadowView {
    [self.shadowView removeFromSuperview];
    self.shadowView = nil;
}

#pragma mark - Activity Sheet Delegate

- (void)activitySheet:(OSKActivitySheetViewController *)viewController didSelectActivity:(OSKActivity *)activity {
    OSKFlowController *flowController = nil;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        flowController = [[OSKFlowController_Phone alloc] initWithActivity:activity
                                                         sessionIdentifier:viewController.sessionIdentifier
                                                 activityCompletionHandler:self.activitySheetViewController.activityCompletionHandler
                                                                  delegate:self
                                                  presentingViewController:self.presentingViewController];
    }
    else {
        flowController = [[OSKFlowController_Pad alloc] initWithActivity:activity
                                                       sessionIdentifier:viewController.sessionIdentifier
                                               activityCompletionHandler:self.activitySheetViewController.activityCompletionHandler
                                                                delegate:self
                                                       popoverController:self.popoverController
                                                presentingViewController:self.presentingViewController];
    }
    
    [self.flowControllers setObject:flowController forKey:flowController.sessionIdentifier];
    [flowController start];
    
    if ([self isPresentingViaPopover]) {
        if ([[activity.class activityType] isEqualToString:OSKActivityType_iOS_AirDrop] == NO) {
            [self dismissActivitySheet];
        }
    }
}

- (void)activitySheetDidCancel:(OSKActivitySheetViewController *)viewController {
    OSKFlowController *flowController = [self.flowControllers objectForKey:viewController.sessionIdentifier];
    if (flowController) {
        [flowController dismissViewControllers];
        [self.flowControllers removeObjectForKey:flowController.sessionIdentifier];
    }
    [self dismissActivitySheet];
}

#pragma mark - Styles

- (OSKActivitySheetViewControllerStyle)sheetStyle {
    OSKActivitySheetViewControllerStyle style;
    if ([self.styleDelegate respondsToSelector:@selector(osk_activitySheetStyle)]) {
        style = [self.styleDelegate osk_activitySheetStyle];
    } else {
        style = OSKActivitySheetViewControllerStyle_Light;
    }
    return style;
}

- (BOOL)toolbarsUseUnjustifiablyBorderlessButtons {
    BOOL useBorders = YES;
    if ([self.styleDelegate respondsToSelector:@selector(osk_toolbarsUseUnjustifiablyBorderlessButtons)]) {
        useBorders = [self.styleDelegate osk_toolbarsUseUnjustifiablyBorderlessButtons];
    }
    return useBorders;
}

- (UIImage *)alternateIconForActivityType:(NSString *)type idiom:(UIUserInterfaceIdiom)idiom {
    UIImage *image = nil;
    if ([self.styleDelegate respondsToSelector:@selector(osk_alternateIconForActivityType:idiom:)]) {
        image = [self.styleDelegate osk_alternateIconForActivityType:type idiom:idiom];
    }
    return image;
}

#pragma mark - Colors

- (UIColor *)color_activitySheetTopLine {
    UIColor *lineColor = nil;
    if ([self.colorDelegate respondsToSelector:@selector(osk_color_activitySheetTopLine)]) {
        lineColor = [self.colorDelegate osk_color_activitySheetTopLine];
    } else {
        OSKActivitySheetViewControllerStyle style = [self sheetStyle];
        if (style == OSKActivitySheetViewControllerStyle_Light) {
            lineColor = [UIColor colorWithWhite:0.0 alpha:0.25];
        } else {
            lineColor = [UIColor colorWithWhite:1.0 alpha:0.125];
        }
    }
    return lineColor;
}

- (UIColor *)color_opaqueBackground {
    UIColor *color;
    if ([self.colorDelegate respondsToSelector:@selector(osk_color_opaqueBackground)]) {
        color = [self.colorDelegate osk_color_opaqueBackground];
    } else {
        OSKActivitySheetViewControllerStyle style = [self sheetStyle];
        if (style == OSKActivitySheetViewControllerStyle_Light) {
            color = OSKDefaultColor_LightStyle_OpaqueBGColor;
        } else {
            color = OSKDefaultColor_DarkStyle_OpaqueBGColor;
        }
    }
    return color;
}

- (UIColor *)color_translucentBackground {
    UIColor *color;
    if ([self.colorDelegate respondsToSelector:@selector(osk_color_translucentBackground)]) {
        color = [self.colorDelegate osk_color_translucentBackground];
    } else {
        OSKActivitySheetViewControllerStyle style = [self sheetStyle];
        if (style == OSKActivitySheetViewControllerStyle_Light) {
            color = OSKDefaultColor_LightStyle_SheetColor;
        } else {
            color = OSKDefaultColor_DarkStyle_SheetColor;
        }
    }
    return color;
}

- (UIColor *)color_toolbarBackground {
    UIColor *color;
    if ([self.colorDelegate respondsToSelector:@selector(osk_color_toolbarBackground)]) {
        color = [self.colorDelegate osk_color_toolbarBackground];
    } else {
        OSKActivitySheetViewControllerStyle style = [self sheetStyle];
        if (style == OSKActivitySheetViewControllerStyle_Light) {
            color = OSKDefaultColor_LightStyle_BarColor;
        } else {
            color = OSKDefaultColor_DarkStyle_BarColor;
        }
    }
    return color;
}

- (UIColor *)color_groupedTableViewBackground {
    UIColor *color;
    if ([self.colorDelegate respondsToSelector:@selector(osk_color_groupedTableViewBackground)]) {
        color = [self.colorDelegate osk_color_groupedTableViewBackground];
    } else {
        OSKActivitySheetViewControllerStyle style = [self sheetStyle];
        if (style == OSKActivitySheetViewControllerStyle_Light) {
            color = OSKDefaultColor_LightStyle_GroupedTableViewBGColor;
        } else {
            color = OSKDefaultColor_DarkStyle_GroupedTableViewBGColor;
        }
    }
    return color;
}

- (UIColor *)color_groupedTableViewCells {
    UIColor *color;
    if ([self.colorDelegate respondsToSelector:@selector(osk_color_groupedTableViewCells)]) {
        color = [self.colorDelegate osk_color_groupedTableViewCells];
    } else {
        OSKActivitySheetViewControllerStyle style = [self sheetStyle];
        if (style == OSKActivitySheetViewControllerStyle_Light) {
            color = OSKDefaultColor_LightStyle_GroupedTableViewCellColor;
        } else {
            color = OSKDefaultColor_DarkStyle_GroupedTableViewCellColor;
        }
    }
    return color;
}

- (UIColor *)color_separators {
    UIColor *lineColor = nil;
    if ([self.colorDelegate respondsToSelector:@selector(osk_color_separators)]) {
        lineColor = [self.colorDelegate osk_color_separators];
    } else {
        UIColor *backgroundColor = [self color_opaqueBackground];
        UIColor *contrastingColor = [backgroundColor osk_contrastingColor]; // either b or w
        OSKActivitySheetViewControllerStyle style = [self sheetStyle];
        if (style == OSKActivitySheetViewControllerStyle_Light) {
            lineColor = [contrastingColor osk_colorByInterpolatingToColor:backgroundColor byFraction:0.83];
        } else {
            lineColor = [contrastingColor osk_colorByInterpolatingToColor:backgroundColor byFraction:0.83];
        }
    }
    return lineColor;
}

- (UIColor *)color_action {
    UIColor *color;
    if ([self.colorDelegate respondsToSelector:@selector(osk_color_action)]) {
        color = [self.colorDelegate osk_color_action];
    } else {
        OSKActivitySheetViewControllerStyle style = [self sheetStyle];
        if (style == OSKActivitySheetViewControllerStyle_Light) {
            color = OSKDefaultColor_LightStyle_ActionColor;
        } else {
            color = OSKDefaultColor_DarkStyle_ActionColor;
        }
    }
    return color;
}

- (UIColor *)color_text {
    UIColor *color;
    if ([self.colorDelegate respondsToSelector:@selector(osk_color_text)]) {
        color = [self.colorDelegate osk_color_text];
    } else {
        OSKActivitySheetViewControllerStyle style = [self sheetStyle];
        if (style == OSKActivitySheetViewControllerStyle_Light) {
            color = OSKDefaultColor_LightStyle_TextColor;
        } else {
            color = OSKDefaultColor_DarkStyle_TextColor;
        }
    }
    return color;
}

- (UIColor *)color_pageIndicatorColor_current {
    UIColor *color;
    if ([self.colorDelegate respondsToSelector:@selector(osk_color_pageIndicatorColor_current)]) {
        color = [self.colorDelegate osk_color_pageIndicatorColor_current];
    } else {
        UIColor *backgroundColor = [self color_opaqueBackground];
        UIColor *contrastingColor = [backgroundColor osk_contrastingColor]; // either b or w
        OSKActivitySheetViewControllerStyle style = [self sheetStyle];
        if (style == OSKActivitySheetViewControllerStyle_Light) {
            color = [contrastingColor osk_colorByInterpolatingToColor:backgroundColor byFraction:0.33];
        } else {
            color = [contrastingColor osk_colorByInterpolatingToColor:backgroundColor byFraction:0.33];
        }
    }
    return color;
}

- (UIColor *)color_pageIndicatorColor_other {
    UIColor *color;
    if ([self.colorDelegate respondsToSelector:@selector(osk_color_pageIndicatorColor_other)]) {
        color = [self.colorDelegate osk_color_pageIndicatorColor_other];
    } else {
        UIColor *backgroundColor = [self color_opaqueBackground];
        UIColor *contrastingColor = [backgroundColor osk_contrastingColor]; // either b or w
        OSKActivitySheetViewControllerStyle style = [self sheetStyle];
        if (style == OSKActivitySheetViewControllerStyle_Light) {
            color = [contrastingColor osk_colorByInterpolatingToColor:backgroundColor byFraction:0.75];
        } else {
            color = [contrastingColor osk_colorByInterpolatingToColor:backgroundColor byFraction:0.75];
        }
    }
    return color;
}

- (UIColor *)color_cancelButtonColor_BackgroundHighlighted {
    UIColor *color;
    if ([self.colorDelegate respondsToSelector:@selector(osk_color_cancelButtonColor_BackgroundHighlighted)]) {
        color = [self.colorDelegate osk_color_cancelButtonColor_BackgroundHighlighted];
    } else {
        OSKActivitySheetViewControllerStyle style = [self sheetStyle];
        if (style == OSKActivitySheetViewControllerStyle_Light) {
            color = [UIColor colorWithWhite:0.5 alpha:0.25];
        } else {
            color = [UIColor colorWithWhite:0.5 alpha:0.25];
        }
    }
    return color;
}

- (UIColor *)color_hashtags {
    UIColor *color;
    if ([self.colorDelegate respondsToSelector:@selector(osk_color_hashtags)]) {
        color = [self.colorDelegate osk_color_hashtags];
    } else {
        UIColor *backgroundColor = [self color_opaqueBackground];
        UIColor *contrastingColor = [backgroundColor osk_contrastingColor]; // either b or w
        color = [contrastingColor osk_colorByInterpolatingToColor:backgroundColor byFraction:0.5];
    }
    return color;
}

- (UIColor *)color_mentions {
    UIColor *color;
    if ([self.colorDelegate respondsToSelector:@selector(osk_color_mentions)]) {
        color = [self.colorDelegate osk_color_mentions];
    } else {
        color = [self color_action];
    }
    return color;
}

- (UIColor *)color_links {
    UIColor *color;
    if ([self.colorDelegate respondsToSelector:@selector(osk_color_links)]) {
        color = [self.colorDelegate osk_color_links];
    } else {
        color = [self color_action];
    }
    return color;
}

- (UIColor *)color_characterCounter_normal {
    UIColor *color;
    if ([self.colorDelegate respondsToSelector:@selector(osk_color_characterCounter_normal)]) {
        color = [self.colorDelegate osk_color_characterCounter_normal];
    } else {
        UIColor *backgroundColor = [self color_opaqueBackground];
        UIColor *contrastingColor = [backgroundColor osk_contrastingColor]; // either b or w
        color = [contrastingColor osk_colorByInterpolatingToColor:backgroundColor byFraction:0.5];
    }
    return color;
}

- (UIColor *)color_characterCounter_warning {
    UIColor *color;
    if ([self.colorDelegate respondsToSelector:@selector(osk_color_characterCounter_warning)]) {
        color = [self.colorDelegate osk_color_characterCounter_warning];
    } else {
        color = [UIColor redColor];
    }
    return color;
}

#pragma mark - Localization

- (NSString *)localizedText_ActionButtonTitleForPublishingActivity:(NSString *)activityType {
    NSString *text = nil;
    if ([self.localizationDelegate respondsToSelector:@selector(osk_localizedText_ActionButtonTitleForPublishingActivity:)]) {
        text = [self.localizationDelegate osk_localizedText_ActionButtonTitleForPublishingActivity:activityType];
    }
    if (text == nil) {
        if ([activityType isEqualToString:OSKActivityType_API_AppDotNet]) {
            text = @"Post";
        }
        else if ([activityType isEqualToString:OSKActivityType_iOS_Twitter]) {
            text = @"Tweet";
        }
        else if ([activityType isEqualToString:OSKActivityType_iOS_Facebook]) {
            text = @"Post";
        }
        else {
            text = @"Send";
        }
    }
    return text;
}

- (NSString *)localizedText_Cancel {
    NSString *text = nil;
    if ([self.localizationDelegate respondsToSelector:@selector(osk_localizedText_Cancel)]) {
        text = [self.localizationDelegate osk_localizedText_Cancel];
    }
    if (text == nil) {
        text = @"Cancel";
    }
    return text;
}

- (NSString *)localizedText_Done {
    NSString *text = nil;
    if ([self.localizationDelegate respondsToSelector:@selector(osk_localizedText_Done)]) {
        text = [self.localizationDelegate osk_localizedText_Done];
    }
    if (text == nil) {
        text = @"Done";
    }
    return text;
}

- (NSString *)localizedText_Username {
    NSString *text = nil;
    if ([self.localizationDelegate respondsToSelector:@selector(osk_localizedText_Username)]) {
        text = [self.localizationDelegate osk_localizedText_Username];
    }
    if (text == nil) {
        text = @"Username";
    }
    return text;
}

- (NSString *)localizedText_Password {
    NSString *text = nil;
    if ([self.localizationDelegate respondsToSelector:@selector(osk_localizedText_Password)]) {
        text = [self.localizationDelegate osk_localizedText_Password];
    }
    if (text == nil) {
        text = @"Password";
    }
    return text;
}

- (NSString *)localizedText_SignOut {
    NSString *text = nil;
    if ([self.localizationDelegate respondsToSelector:@selector(osk_localizedText_SignOut)]) {
        text = [self.localizationDelegate osk_localizedText_SignOut];
    }
    if (text == nil) {
        text = @"Sign Out";
    }
    return text;
}

- (NSString *)localizedText_SignIn {
    NSString *text = nil;
    if ([self.localizationDelegate respondsToSelector:@selector(osk_localizedText_SignIn)]) {
        text = [self.localizationDelegate osk_localizedText_SignIn];
    }
    if (text == nil) {
        text = @"Sign In";
    }
    return text;
}

- (NSString *)localizedText_Accounts {
    NSString *text = nil;
    if ([self.localizationDelegate respondsToSelector:@selector(osk_localizedText_Accounts)]) {
        text = [self.localizationDelegate osk_localizedText_Accounts];
    }
    if (text == nil) {
        text = @"Accounts";
    }
    return text;
}

- (NSString *)localizedText_AreYouSure {
    NSString *text = nil;
    if ([self.localizationDelegate respondsToSelector:@selector(osk_localizedText_AreYouSure)]) {
        text = [self.localizationDelegate osk_localizedText_AreYouSure];
    }
    if (text == nil) {
        text = @"Are You Sure?";
    }
    return text;
}

- (NSString *)localizedText_NoAccountsFound {
    NSString *text = nil;
    if ([self.localizationDelegate respondsToSelector:@selector(osk_localizedText_NoAccountsFound)]) {
        text = [self.localizationDelegate osk_localizedText_NoAccountsFound];
    }
    if (text == nil) {
        text = @"No Accounts Found";
    }
    return text;
}

- (NSString *)localizedText_YouCanSignIntoYourAccountsViaTheSettingsApp {
    NSString *text = nil;
    if ([self.localizationDelegate respondsToSelector:@selector(osk_localizedText_YouCanSignIntoYourAccountsViaTheSettingsApp)]) {
        text = [self.localizationDelegate osk_localizedText_YouCanSignIntoYourAccountsViaTheSettingsApp];
    }
    if (text == nil) {
        text = @"You can sign into your accounts via the settings app.";
    }
    return text;
}

- (NSString *)localizedText_Okay {
    NSString *text = nil;
    if ([self.localizationDelegate respondsToSelector:@selector(osk_localizedText_Okay)]) {
        text = [self.localizationDelegate osk_localizedText_Okay];
    }
    if (text == nil) {
        text = @"Okay";
    }
    return text;
}

- (NSString *)localizedText_AccessNotGrantedForSystemAccounts_Title {
    NSString *text = nil;
    if ([self.localizationDelegate respondsToSelector:@selector(osk_localizedText_AccessNotGrantedForSystemAccounts_Title)]) {
        text = [self.localizationDelegate osk_localizedText_AccessNotGrantedForSystemAccounts_Title];
    }
    if (text == nil) {
        text = @"Couldn’t Access Your Accounts";
    }
    return text;
}

- (NSString *)localizedText_AccessNotGrantedForSystemAccounts_Message {
    NSString *text = nil;
    if ([self.localizationDelegate respondsToSelector:@selector(osk_localizedText_AccessNotGrantedForSystemAccounts_Message)]) {
        text = [self.localizationDelegate osk_localizedText_AccessNotGrantedForSystemAccounts_Message];
    }
    if (text == nil) {
        text = @"You have previously denied this app access to your accounts. Please head to the Settings app’s Privacy options to enable sharing.";
    }
    return text;
}

- (NSString *)localizedText_UnableToSignIn {
    NSString *text = nil;
    if ([self.localizationDelegate respondsToSelector:@selector(osk_localizedText_UnableToSignIn)]) {
        text = [self.localizationDelegate osk_localizedText_UnableToSignIn];
    }
    if (text == nil) {
        text = @"Unable to Sign In";
    }
    return text;
}

- (NSString *)localizedText_PleaseDoubleCheckYourUsernameAndPasswordAndTryAgain {
    NSString *text = nil;
    if ([self.localizationDelegate respondsToSelector:@selector(osk_localizedText_PleaseDoubleCheckYourUsernameAndPasswordAndTryAgain)]) {
        text = [self.localizationDelegate osk_localizedText_PleaseDoubleCheckYourUsernameAndPasswordAndTryAgain];
    }
    if (text == nil) {
        text = @"Please double check your username and password and try again.";
    }
    return text;
}

- (NSString *)localizedText_FacebookAudience_Public {
    NSString *text = nil;
    if ([self.localizationDelegate respondsToSelector:@selector(osk_localizedText_FacebookAudience_Public)]) {
        text = [self.localizationDelegate osk_localizedText_FacebookAudience_Public];
    }
    if (text == nil) {
        text = @"Public";
    }
    return text;
}

- (NSString *)localizedText_FacebookAudience_Friends {
    NSString *text = nil;
    if ([self.localizationDelegate respondsToSelector:@selector(osk_localizedText_FacebookAudience_Friends)]) {
        text = [self.localizationDelegate osk_localizedText_FacebookAudience_Friends];
    }
    if (text == nil) {
        text = @"Friends";
    }
    return text;
}

- (NSString *)localizedText_FacebookAudience_OnlyMe {
    NSString *text = nil;
    if ([self.localizationDelegate respondsToSelector:@selector(osk_localizedText_FacebookAudience_OnlyMe)]) {
        text = [self.localizationDelegate osk_localizedText_FacebookAudience_OnlyMe];
    }
    if (text == nil) {
        text = @"Only Me";
    }
    return text;
}

- (NSString *)localizedText_FacebookAudience_Audience {
    NSString *text = nil;
    if ([self.localizationDelegate respondsToSelector:@selector(osk_localizedText_FacebookAudience_Audience)]) {
        text = [self.localizationDelegate osk_localizedText_FacebookAudience_Audience];
    }
    if (text == nil) {
        text = @"Audience";
    }
    return text;
}

#pragma mark - View Controllers

- (UIViewController <OSKPurchasingViewController> *)purchasingViewControllerForActivity:(OSKActivity *)activity {
    UIViewController <OSKPurchasingViewController> *viewController = nil;
    if ([self.viewControllerDelegate respondsToSelector:@selector(osk_purchasingViewControllerForActivity:)]) {
        viewController = [self.viewControllerDelegate osk_purchasingViewControllerForActivity:activity];
    }
    NSAssert((viewController != nil), @"Purchasing view controllers *must* be vended by the ActivitiesManager's viewControllerDelegate and cannot be nil");
    return viewController;
}

- (UIViewController <OSKAuthenticationViewController> *)authenticationViewControllerForActivity:(OSKActivity *)activity {
    UIViewController <OSKAuthenticationViewController> *viewController = nil;
    if ([self.viewControllerDelegate respondsToSelector:@selector(osk_authenticationViewControllerForActivity:)]) {
        viewController = [self.viewControllerDelegate osk_authenticationViewControllerForActivity:activity];
    }
    if (viewController == nil) {
        if ([activity.class authenticationViewControllerType] == OSKManagedAccountAuthenticationViewControllerType_DefaultUsernamePasswordViewController) {
            viewController = [[OSKUsernamePasswordViewController alloc] initWithStyle:UITableViewStyleGrouped];
        }
        else if ([[activity.class activityType] isEqualToString:OSKActivityType_API_AppDotNet]) {
            OSKActivitiesManager *manager = [OSKActivitiesManager sharedInstance];
            OSKApplicationCredential *appCredential = [manager applicationCredentialForActivityType:[activity.class activityType]];
            viewController = [[OSKAppDotNetAuthenticationViewController alloc] initWithApplicationCredential:appCredential];
        }
    }
    return viewController;
}

- (UIViewController <OSKPublishingViewController> *)publishingViewControllerForActivity:(OSKActivity *)activity {
    UIViewController <OSKPublishingViewController> *viewController = nil;
    if ([self.viewControllerDelegate respondsToSelector:@selector(osk_publishingViewControllerForActivity:)]) {
        viewController = [self.viewControllerDelegate osk_publishingViewControllerForActivity:activity];
    }
    if (viewController == nil) {
        switch ([activity.class publishingViewControllerType]) {
            case OSKPublishingViewControllerType_Microblogging: {
                NSString *nibName = NSStringFromClass([OSKMicroblogPublishingViewController class]);
                viewController = [[OSKMicroblogPublishingViewController alloc] initWithNibName:nibName bundle:nil];
            } break;
            case OSKPublishingViewControllerType_Blogging: {
                // alloc/init a blogging view controller
            } break;
            case OSKPublishingViewControllerType_System: {
                if ([activity.contentItem.itemType isEqualToString:OSKShareableContentItemType_Email]) {
                    viewController = [[OSKMailComposeViewController alloc] initWithNibName:nil bundle:nil];
                }
                else if ([activity.contentItem.itemType isEqualToString:OSKShareableContentItemType_SMS]) {
                    viewController = [[OSKMessageComposeViewController alloc] initWithNibName:nil bundle:nil];
                }
                else if ([activity.contentItem.itemType isEqualToString:OSKShareableContentItemType_AirDrop]) {
                    viewController = [[OSKAirDropViewController alloc] initWithAirDropItem:(OSKAirDropContentItem *)activity.contentItem];
                }
            } break;
            case OSKPublishingViewControllerType_Facebook: {
                NSString *nibName = NSStringFromClass([OSKFacebookPublishingViewController class]);
                viewController = [[OSKFacebookPublishingViewController alloc] initWithNibName:nibName bundle:nil];
            } break;
            case OSKPublishingViewControllerType_Bespoke: {
                NSAssert(NO, @"OSKPresentationManager: Activities with a bespoke publishing view controller require the OSKPresentationManager's delegate to vend the appropriate publishing view controller via osk_publishingViewControllerForActivity:");
            } break;
            case OSKPublishingViewControllerType_None: {
                NSAssert(NO, @"OSKPresentationManager: Attempting to present a publishing view controller for an activity that does not require one.");
            } break;
            default:
                break;
        }
    }
    return viewController;
}

#pragma mark - Flow Controller Delegate

- (void)flowController:(OSKFlowController *)controller willPresentViewController:(UIViewController *)viewController inNavigationController:(OSKNavigationController *)navigationController {
    if ([self.viewControllerDelegate respondsToSelector:@selector(presentationManager:willPresentViewController:inNavigationController:)]) {
        [self.viewControllerDelegate presentationManager:self willPresentViewController:viewController inNavigationController:navigationController];
    }
}

- (void)flowController:(OSKFlowController *)controller willPresentSystemViewController:(UIViewController *)systemViewController {
    if ([self.viewControllerDelegate respondsToSelector:@selector(presentationManager:willPresentSystemViewController:)]) {
        [self.viewControllerDelegate presentationManager:self willPresentSystemViewController:systemViewController];
    }
}

- (void)flowControllerDidBeginActivity:(OSKFlowController *)controller shouldDismissActivitySheet:(BOOL)dismiss {
    if (dismiss) {
        [self dismissActivitySheet];
    }
}

- (void)flowControllerDidFinish:(OSKFlowController *)controller {
    [self.flowControllers removeObjectForKey:controller.sessionIdentifier];
    if ([self isPresenting] && [controller.sessionIdentifier isEqualToString:self.activitySheetViewController.sessionIdentifier]) {
        [self dismissActivitySheet];
    }
}

- (void)flowControllerDidCancel:(OSKFlowController *)controller {
    [self.flowControllers removeObjectForKey:controller.sessionIdentifier];
}

@end




