//
//  SampleTimelineViewController.m
//  Overshare
//
//  Created by Jared Sinclair on 10/30/13.
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//

#import "SampleTimelineViewController.h"

#import "SampleTimelineCell.h"
#import "SampleAppPurchasingViewController.h"

#import "OvershareKit.h"

#import "NSString+OSKDerp.h"

@interface SampleTimelineViewController ()
<
    SampleTimelineCellDelegate,
    OSKPresentationViewControllers,
    OSKPresentationStyle,
    OSKPresentationColor,
    OSKXCallbackURLInfo
>

@property (assign, nonatomic) OSKActivitySheetViewControllerStyle sheetStyle;
@property (strong, nonatomic) NSIndexPath *iPadPresentingIndexPath;

@end

#warning Set this to 1 to enable the In-App Purchase simulation
#define SIMULATE_UPGRADE_TO_PRO 0

@implementation SampleTimelineViewController


#pragma mark - UITableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.title = @"Overshare";
        [[OSKActivitiesManager sharedInstance] setXCallbackURLDelegate:self];
        [[OSKPresentationManager sharedInstance] setViewControllerDelegate:self];
        [[OSKPresentationManager sharedInstance] setColorDelegate:self];
        [[OSKPresentationManager sharedInstance] setStyleDelegate:self];
#if SIMULATE_UPGRADE_TO_PRO == 1
        [self setupPurchaseHistory];
#endif
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SampleTimelineCell class]) bundle:nil]
         forCellReuseIdentifier:SampleTimelineCellIdentifier];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(accountManagerButtonTapped:)];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareBarButtonTapped:)];
    }
}


#pragma mark - Sharing

- (void)showShareSheetForTappedCell:(SampleTimelineCell *)tappedCell {
    
    // 1) Create the shareable content from the user's source content.
    
    NSString *text = @"Me and my dad make models of clipper ships. #Clipperships sail on the ocean.";
    NSArray *images = @[[UIImage imageNamed:@"soda.jpg"],
                        [UIImage imageNamed:@"rain.jpg"],
                        [UIImage imageNamed:@"type.jpg"]];
    NSString *canonicalURL = @"http://github.com/overshare/overshare-kit";
    NSString *authorName = @"testochango";
    
    // Original OvershareKit Shareable Content Method
    // This fork of OvershareKit is 100% backwards compatible, meaning the original shareable content items will still work. If the Branch API key is not present, OvershareKit will behave exactly as it does without Branch: directing the user to the URL that is provided.
    /*
     OSKShareableContent *content = [OSKShareableContent contentFromMicroblogPost:text
                                                                     authorName:authorName
                                                                     canonicalURL:canonicalURL
                                                                     images:images];
     */
    
    // ========== Branch ==========
    // Now let's use Branch!!
    // Provided you have set the Branch API key provided to you here: https://dashboard.branch.io/#/settings
    // ...the following methods will seamlessly generate OSK shareable content items, and attach a Branch Short URL to each content channel AND automatically tag it with "facebook," "bookmark," etc. for each channel!
    
    // To see this in action, let's setup some dummy data that we'd like to be passed thru download and install of sharing content with another user
    
    // For a complete explanation of creating Branch links, see: https://github.com/BranchMetrics/Branch-Integration-Guides/blob/master/url-creation-guide.md
    
    // Branch tags
    // ====================================================
    // Accepts an unlimited number of strings in an NSArray.
    // This is more a free form entry of anything that
    // helps you collect your thoughts. It’s a place where
    // you can add meaningful labels for organizing links
    // that aren’t confined to a channel or campaign
    NSArray *branchTags = @[@"test_tag1", @"test_tag2"];
    
    // Brach deep link params
    // ====================================================
    // These are the params you want passed thru the link.
    // This could be _anything_ you want: A user id of who shared the content,
    // an image URL, an internal URI to direct the user to the content within
    // your app, etc. Here are just a few samples...
    NSMutableDictionary *branchParams = [[NSMutableDictionary alloc] init];
    // Example params Deep Link data
    [branchParams setObject:@"Joe" forKey:@"user"];
    [branchParams setObject:@"https://s3-us-west-1.amazonaws.com/myapp/joes_pic.jpg" forKey:@"profile_pic"];
    [branchParams setObject:@"Joe likes long walks on the beach..." forKey:@"description"];
    
    // OpenGraph tags
    // ====================================================
    // OpenGraph tags are a way of sharing content attributes
    // with social media platforms: http://ogp.me/) <<-- Thanks Facebook!
    // These can also be set in the params. A Great thing to do
    // If you want your app's name or icon to show up on a Facebook timeline
    // when a user shares this on Facebook.
    [branchParams setObject:@"Joe is a super cool guy!" forKey:@"$og_title"];
    [branchParams setObject:@"https://branch.io/img/logo_icon_black.png" forKey:@"$og_image_url"];
    [branchParams setObject:@"Because he likes long walks on the beach..." forKey:@"$og_description"];
    
    // Branch Stage
    // ====================================================
    // This is a label typically used to categorize the progress
    // or category of a user when the link was generated. For example,
    // if the customer has an invite system accessible on level 1, level 3 and 5,
    // the customer could differentiate links generated at each level with this parameter
    NSString *branchStage = @"test_stage";
    
    // Branch Feature
    // ====================================================
    // This is the feature of the customer’s product that the
    // link might be associated with. For example, if the customer
    // had built a referral program in their app, they might have
    // tagged all links with the String ‘referral’.
    NSString *branchFeature = @"test_feature";
    
    // OSK Content with Branch params
    // ====================================================
    // These methods all return a instance of an OSKShareableContent object
    // but they also automatically generate a Branch Short URL with all of the Branch
    // params they are provided with!
    // you can also call contentFromURL with all of these optional params.

    // OSK Content with all arguments
    OSKShareableContent *content = [OSKShareableContent contentFromMicroblogPost:text
                                                                      authorName:authorName
                                                                    canonicalURL:canonicalURL
                                                                          images:images
                                                              branchTrackingTags:branchTags
                                                                    branchParams:branchParams
                                                                     branchStage:branchStage
                                                                   branchFeature:branchFeature];
    /*
    // OSK with tracking tags
    OSKShareableContent *content = [OSKShareableContent contentFromMicroblogPost:text
                                                                      authorName:authorName canonicalURL:canonicalURL
                                                                          images:images branchTrackingTags:branchTags];
     */
    
    // OSK with Branch tags and Params for deep links
    /*
    OSKShareableContent *content = [OSKShareableContent contentFromMicroblogPost:text
                                                                      authorName:authorName canonicalURL:canonicalURL
                                                                          images:images branchTrackingTags:branchTags branchParams:branchParams];
     */
    
    // OSK with Params for deep links
    /*
     OSKShareableContent *content = [OSKShareableContent contentFromMicroblogPost:text
                                                                     authorName:authorName
                                                                     canonicalURL:canonicalURL
                                                                     images:images
                                                                     branchParams:branchParams];
     */
    // OSK with Branch tags, Params for deep links, and Branch Stage
    /*
     OSKShareableContent *content = [OSKShareableContent contentFromMicroblogPost:text
                                                                       authorName:authorName
                                                                     canonicalURL:canonicalURL
                                                                         images:images
                                                               branchTrackingTags:branchTags
                                                                     branchParams:branchParams
                                                                      branchStage:branchStage];
     */
    
    // OSK with Branch tags and Branch Stage
    /*
    OSKShareableContent *content = [OSKShareableContent contentFromMicroblogPost:text
                                                                      authorName:authorName
                                                                    canonicalURL:canonicalURL
                                                                          images:images
                                                              branchTrackingTags:branchTags
                                                                     branchStage:branchStage];
     */
    
    // OSK with Branch Params for deep links and Branch Stage
    /*
    OSKShareableContent *content = [OSKShareableContent contentFromMicroblogPost:text
                                                                      authorName:authorName
                                                                    canonicalURL:canonicalURL
                                                                          images:images
                                                                    branchParams:branchParams
                                                                     branchStage:branchStage];
     */
    
    // OSK with Branch Stage
    /*
    OSKShareableContent *content = [OSKShareableContent contentFromMicroblogPost:text
                                                                      authorName:authorName
                                                                    canonicalURL:canonicalURL
                                                                          images:images
                                                                     branchStage:branchStage];
     */
    
    // OSK with Branch Feature
    /*
    OSKShareableContent *content = [OSKShareableContent contentFromMicroblogPost:text
                                                                      authorName:authorName
                                                                    canonicalURL:canonicalURL
                                                                          images:images
                                                                     branchFeature:branchFeature];
     */
    
    // ========== End Branch ==========
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self showShareSheet_Phone:content];
    } else {
        [self showShareSheet_Pad_FromCell:tappedCell content:content];
    }
}

- (void)showShareSheet_Pad_FromCell:(SampleTimelineCell *)tappedCell content:(OSKShareableContent *)content {
    
    [self setIPadPresentingIndexPath:[self.tableView indexPathForCell:tappedCell]];
    
    // 2) Setup optional completion and dismissal handlers
    OSKActivityCompletionHandler completionHandler = [self activityCompletionHandler];
    OSKPresentationEndingHandler dismissalHandler = [self dismissalHandler];
    
    // 3) Create the options dictionary. See OSKActivity.h for more options.
    NSDictionary *options = @{    OSKPresentationOption_ActivityCompletionHandler : completionHandler,
                              OSKPresentationOption_PresentationEndingHandler : dismissalHandler};
    
    // 4) Prep the iPad-specific presentation needs.
    CGRect presentationRect = [self presentationRectForCell:tappedCell];
    
    // 5) Present the activity sheet via the presentation manager.
    [[OSKPresentationManager sharedInstance] presentActivitySheetForContent:content
                                                   presentingViewController:self
                                                            popoverFromRect:presentationRect inView:self.view
                                                   permittedArrowDirections:UIPopoverArrowDirectionAny
                                                                   animated:YES
                                                                    options:options];
}

- (void)showShareSheet_Pad_FromBarButtonItem:(UIBarButtonItem *)barButtonItem content:(OSKShareableContent *)content {
    
    // 2) Setup optional completion and dismissal handlers
    OSKActivityCompletionHandler completionHandler = [self activityCompletionHandler];
    OSKPresentationEndingHandler dismissalHandler = [self dismissalHandler];
    
    // 3) Create the options dictionary. See OSKActivity.h for more options.
    NSDictionary *options = @{    OSKPresentationOption_ActivityCompletionHandler : completionHandler,
                                  OSKPresentationOption_PresentationEndingHandler : dismissalHandler};
    
    // 4) Present the activity sheet via the presentation manager.
    [[OSKPresentationManager sharedInstance] presentActivitySheetForContent:content
                                                   presentingViewController:self
                                                   popoverFromBarButtonItem:barButtonItem
                                                   permittedArrowDirections:UIPopoverArrowDirectionAny
                                                                   animated:YES
                                                                    options:options];
}

- (void)showShareSheet_Phone:(OSKShareableContent *)content {
    
    // 2) Setup optional completion and dismissal handlers
    OSKActivityCompletionHandler completionHandler = [self activityCompletionHandler];
    OSKPresentationEndingHandler dismissalHandler = [self dismissalHandler];
    
    // 3) Create the options dictionary. See OSKActivity.h for more options.
    NSDictionary *options = @{    OSKPresentationOption_ActivityCompletionHandler : completionHandler,
                              OSKPresentationOption_PresentationEndingHandler : dismissalHandler};
    
    // 4) Present the activity sheet via the presentation manager.
    [[OSKPresentationManager sharedInstance] presentActivitySheetForContent:content
                                                   presentingViewController:self
                                                                    options:options];
}


#pragma mark - OSKActivitiesManager X-Callback-URL Delegate

- (NSString *)xCallbackSourceForActivity:(OSKActivity *)activity {
    return @"OvershareKit";
}

- (NSString *)xCallbackSuccessForActivity:(OSKActivity *)activity {
    return [@"oversharekit://" osk_derp_stringByEscapingPercents];
}

- (NSString *)xCallbackCancelForActivity:(OSKActivity *)activity {
    return [@"oversharekit://" osk_derp_stringByEscapingPercents];
}

- (NSString *)xCallbackErrorForActivity:(OSKActivity *)activity {
    return [@"oversharekit://" osk_derp_stringByEscapingPercents];
}


#pragma mark - OSKPresentationManager Style Delegate

- (OSKActivitySheetViewControllerStyle)osk_activitySheetStyle {
    return self.sheetStyle;
}

- (BOOL)osk_toolbarsUseUnjustifiablyBorderlessButtons {
#warning Override this to use bordered navigation bar buttons.
    return YES;
}


#pragma mark - OSKPresentationManager Color Delegate

- (UIColor *)osk_color_action {
    UIColor *color = nil;
    if (self.sheetStyle == OSKActivitySheetViewControllerStyle_Dark) {
        color = [UIColor redColor];
    } else {
        color = [UIColor colorWithRed:0.00 green:0.48 blue:1.00 alpha:1.0];
    }
    return color;
}


#pragma mark - OSKPresentationManager View Controller Delegate

- (void)presentationManager:(OSKPresentationManager *)manager willRepositionPopoverToRect:(inout CGRect *)rect inView:(inout UIView *__autoreleasing *)view {
    if (self.iPadPresentingIndexPath) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.iPadPresentingIndexPath];
        if (cell == nil) {
            cell = [self.tableView.visibleCells firstObject];
        }
        if (cell) {
            *rect = [self presentationRectForCell:(SampleTimelineCell *)cell];
        } else {
            *rect = self.view.bounds;
        }
    } else {
        // no op
    }
}

- (UIViewController <OSKPurchasingViewController> *)osk_purchasingViewControllerForActivity:(OSKActivity *)activity {
    return [[SampleAppPurchasingViewController alloc] initWithNibName:NSStringFromClass([SampleAppPurchasingViewController class]) bundle:nil];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SampleTimelineCell *cell = [tableView dequeueReusableCellWithIdentifier:SampleTimelineCellIdentifier forIndexPath:indexPath];
    [cell setDelegate:self];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return SampleTimelineCellHeight;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - SampleTimelineViewController 

- (void)accountManagerButtonTapped:(id)sender {
    [self showAccountsManagement];
}

- (void)shareBarButtonTapped:(UIBarButtonItem *)item {
    
    // 1) Create the shareable content from the user's source content.
    
    NSString *text = @"Me and my dad make models of clipper ships. #Clipperships sail on the ocean.";
    NSArray *images = @[[UIImage imageNamed:@"soda.jpg"],
                        [UIImage imageNamed:@"rain.jpg"],
                        [UIImage imageNamed:@"type.jpg"]];
    NSString *canonicalURL = @"http://github.com/overshare/overshare-kit";
    NSString *authorName = @"testochango";
    
    OSKShareableContent *content = [OSKShareableContent contentFromMicroblogPost:text
                                                                      authorName:authorName
                                                                    canonicalURL:canonicalURL
                                                                          images:images];
    
    [self showShareSheet_Pad_FromBarButtonItem:item content:content];
}


#pragma mark - Timeline Cell Delegate

- (void)timelineCell:(SampleTimelineCell *)cell didTapLightModeShareButtonInRect:(CGRect)rect {
    self.sheetStyle = OSKActivitySheetViewControllerStyle_Light;
    [self showShareSheetForTappedCell:cell];
}

- (void)timelineCell:(SampleTimelineCell *)cell didTapDarkModeShareButtonInRect:(CGRect)rect {
    self.sheetStyle = OSKActivitySheetViewControllerStyle_Dark;
    [self showShareSheetForTappedCell:cell];
}


#pragma mark - Convenience

- (OSKActivityCompletionHandler)activityCompletionHandler {
    OSKActivityCompletionHandler activityCompletionHandler = ^(OSKActivity *activity, BOOL successful, NSError *error){
        if (successful) {
            NSDictionary *titleStyle = @{NSForegroundColorAttributeName:[UIColor colorWithRed:0.1 green:0.8 blue:0.2 alpha:1.0]};
            [self.navigationController.navigationBar setTitleTextAttributes:titleStyle];
            [self setTitle:[NSString stringWithFormat:@"%@ successful.", [activity.class activityName]]];
        } else {
            NSDictionary *titleStyle = @{NSForegroundColorAttributeName:[UIColor redColor]};
            [self.navigationController.navigationBar setTitleTextAttributes:titleStyle];
            [self setTitle:[NSString stringWithFormat:@"%@ failed.", [activity.class activityName]]];
        }
    };
    return activityCompletionHandler;
}

- (OSKPresentationEndingHandler)dismissalHandler {
    __weak SampleTimelineViewController *weakSelf = self;
    OSKPresentationEndingHandler dismissalHandler = ^(OSKPresentationEnding ending, OSKActivity *activityOrNil){
        OSKLog(@"Sheet dismissed.");
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            [weakSelf setIPadPresentingIndexPath:nil];
        }
    };
    return dismissalHandler;
}

- (void)setupPurchaseHistory {
    OSKActivitiesManager *activitiesManager = [OSKActivitiesManager sharedInstance];
    
    NSArray *typesRequiringPurchase = @[OSKActivityType_API_Instapaper,
                                        OSKActivityType_API_Pocket,
                                        OSKActivityType_API_Pinboard,
                                        OSKActivityType_API_Readability,
                                        OSKActivityType_URLScheme_Omnifocus,
                                        OSKActivityType_URLScheme_Things];
    
    // This tells Overshare that these activity types require In-App Purchase **in general**.
    // To mark an activity type as **actually** purchased, use markActivityTypes:asAlreadyPurchased:
    [activitiesManager markActivityTypes:typesRequiringPurchase asRequiringPurchase:YES];
}

- (void)showAccountsManagement {
    OSKAccountManagementViewController *manager = [[OSKAccountManagementViewController alloc] initWithIgnoredActivityClasses:nil optionalBespokeActivityClasses:nil];
    OSKNavigationController *navController = [[OSKNavigationController alloc] initWithRootViewController:manager];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [navController setModalPresentationStyle:UIModalPresentationFormSheet];
    }
    [self presentViewController:navController animated:YES completion:nil];
}

- (CGRect)presentationRectForCell:(SampleTimelineCell *)cell {
    CGRect sourceRect;
    if (self.sheetStyle == OSKActivitySheetViewControllerStyle_Light) {
        sourceRect = [cell shareButtonRectLight];
    } else {
        sourceRect = [cell shareButtonRectDark];
    }
    CGRect presentationRect = [self.tableView convertRect:sourceRect fromView:cell];
    return presentationRect;
}


@end




