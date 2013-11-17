//
//  OSKPresentationManager.h
//  Overshare
//
//  Created by Jared Sinclair on 10/13/13.
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//

@import UIKit;

@class OSKActivity;
@class OSKNavigationController;
@class OSKPresentationManager;
@class OSKShareableContent;

#import "OSKActivitySheetDelegate.h"
#import "OSKPresentationStyle.h"
#import "OSKPresentationColor.h"
#import "OSKPresentationLocalization.h"
#import "OSKPresentationViewControllers.h"

extern NSString * const OSKActivityOption_ActivitySheetDismissalHandler; // Called when an activity sheet is dismissed, regardless why

///-----------------------------------------------
/// @name Presentation Manager
///-----------------------------------------------

/**
 The Presentation Manager handle the user-facing layers of Overshare. It is used as a singleton instance.
 */
@interface OSKPresentationManager : NSObject

///-----------------------------------------------
/// @name Properties
///-----------------------------------------------


@property (nonatomic, strong) id<OSKActivitySheetDelegate> delegate;

/**
 Set this delegate to override the default colors.
 */
@property (weak, nonatomic) id <OSKPresentationColor> colorDelegate;

/**
 Set this delegate to override default style info, like light or dark mode.
 */
@property (weak, nonatomic) id <OSKPresentationStyle> styleDelegate;

/**
 Set this delegate to provide localized alternate display text for Overshare's UI strings.
 */
@property (weak, nonatomic) id <OSKPresentationLocalization> localizationDelegate;

/**
 Set this delegate to provide custom view controllers, or respond to view controller changes.
 */
@property (weak, nonatomic) id <OSKPresentationViewControllers> viewControllerDelegate;

///-----------------------------------------------
/// @name Methods
///-----------------------------------------------

/**
 @return returns the singleton instance.
 */
+ (instancetype)sharedInstance;

/**
 Presents an activity sheet from the presenting view controller. Use this on iPhone.
 
 @param content The content to be shared.
 
 @param presentingViewController Your app's presenting view controller.
 
 @param options See OSKActivity.h for other options you can pass here, in addition to the
 `OSKActivityOption_ActivitySheetDismissalHandler` option listed above.
 */
- (void)presentActivitySheetForContent:(OSKShareableContent *)content
              presentingViewController:(UIViewController *)presentingViewController
                               options:(NSDictionary *)options;

/**
 Presents an activity sheet in an iPad popover from `rect` in `view`
 
 @param content The content to be shared.
 
 @param presentingViewController Your app's presenting view controller.
 
 @param options See OSKActivity.h for other options you can pass here, in addition to the
 `OSKActivityOption_ActivitySheetDismissalHandler` option listed above.
 */
- (void)presentActivitySheetForContent:(OSKShareableContent *)content
              presentingViewController:(UIViewController *)presentingViewController
                       popoverFromRect:(CGRect)rect
                                inView:(UIView *)view
              permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
                              animated:(BOOL)animated
                               options:(NSDictionary *)options;

/**
 Presents an activity sheet in an iPad popover from `item`.
 
 @param content The content to be shared.
 
 @param presentingViewController Your app's presenting view controller.
 
 @param options See OSKActivity.h for other options you can pass here, in addition to the
 `OSKActivityOption_ActivitySheetDismissalHandler` option listed above.
 */
- (void)presentActivitySheetForContent:(OSKShareableContent *)content
              presentingViewController:(UIViewController *)presentingViewController
              popoverFromBarButtonItem:(UIBarButtonItem *)item
              permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
                              animated:(BOOL)animated
                               options:(NSDictionary *)options;

@end

///-----------------------------------------------
/// @name Obtaining New View Controllers
///-----------------------------------------------

@interface OSKPresentationManager (ViewControllers)

/**
 @return Returns a new purchasing view controller for `activity`.
 */
- (UIViewController <OSKPurchasingViewController> *)purchasingViewControllerForActivity:(OSKActivity *)activity;

/**
 @return Returns a new authentication view controller for `activity`.
 */
- (UIViewController <OSKAuthenticationViewController> *)authenticationViewControllerForActivity:(OSKActivity *)activity;

/**
 @return Returns a new publishing view controller for `activity`.
 */
- (UIViewController <OSKPublishingViewController> *)publishingViewControllerForActivity:(OSKActivity *)activity;

@end

///-----------------------------------------------
/// @name Obtaining Colors
///-----------------------------------------------

@interface OSKPresentationManager (ColorAndStyle)

/**
 The style to be used for Overshare's view controllers. Dark mode FTW!
 
 Returns OSKActivitySheetViewControllerStyle_Light by default.
 
 Override this via the `styleDelegate`.
 */
- (OSKActivitySheetViewControllerStyle)sheetStyle;

/**
 Buttons need borders in order to look tappable.
 
 Returns `YES` by default. :-( 
 
 Override this via the `styleDelegate`.
 */
- (BOOL)toolbarsUseUnjustifiablyBorderlessButtons;

/**
 Returns an alternate icon for a given activity type, or nil (the default is nil).
 
 @param type An `OSKActivity` type.
 
 @param idiom The current user interface idiom.
 
 @return If non-nil, it returns a square, opaque image of size 60x60 points (for iPhone) or 76x76 points (for iPad).
 */
- (UIImage *)alternateIconForActivityType:(NSString *)type idiom:(UIUserInterfaceIdiom)idiom;

- (UIColor *)color_activitySheetTopLine;
- (UIColor *)color_opaqueBackground;
- (UIColor *)color_translucentBackground;
- (UIColor *)color_toolbarBackground;
- (UIColor *)color_groupedTableViewBackground;
- (UIColor *)color_groupedTableViewCells;
- (UIColor *)color_separators;
- (UIColor *)color_action;
- (UIColor *)color_text;
- (UIColor *)color_pageIndicatorColor_current;
- (UIColor *)color_pageIndicatorColor_other;
- (UIColor *)color_cancelButtonColor_BackgroundHighlighted;
- (UIColor *)color_hashtags;
- (UIColor *)color_mentions;
- (UIColor *)color_links;
- (UIColor *)color_characterCounter_normal;
- (UIColor *)color_characterCounter_warning;

@end

///-----------------------------------------------
/// @name Localization and VoiceOver
///-----------------------------------------------

@interface OSKPresentationManager (LocalizationAndAccessibility)

- (NSString *)localizedText_ActionButtonTitleForPublishingActivity:(NSString *)activityType;
- (NSString *)localizedText_Cancel;
- (NSString *)localizedText_Done;
- (NSString *)localizedText_Okay;
- (NSString *)localizedText_Username;
- (NSString *)localizedText_Password;
- (NSString *)localizedText_Accounts;
- (NSString *)localizedText_SignOut;
- (NSString *)localizedText_SignIn;
- (NSString *)localizedText_AreYouSure;
- (NSString *)localizedText_NoAccountsFound;
- (NSString *)localizedText_YouCanSignIntoYourAccountsViaTheSettingsApp;
- (NSString *)localizedText_AccessNotGrantedForSystemAccounts_Title;
- (NSString *)localizedText_AccessNotGrantedForSystemAccounts_Message;
- (NSString *)localizedText_UnableToSignIn;
- (NSString *)localizedText_PleaseDoubleCheckYourUsernameAndPasswordAndTryAgain;
- (NSString *)localizedText_FacebookAudience_Public;
- (NSString *)localizedText_FacebookAudience_Friends;
- (NSString *)localizedText_FacebookAudience_OnlyMe;
- (NSString *)localizedText_FacebookAudience_Audience;

@end








