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

@interface SampleTimelineViewController ()
<
    SampleTimelineCellDelegate,
    OSKPresentationViewControllers,
    OSKPresentationStyle,
    OSKPresentationColor
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
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self showShareSheet_Phone];
    } else {
        [self showShareSheet_Pad_FromCell:tappedCell];
    }
}

- (void)showShareSheet_Pad_FromCell:(SampleTimelineCell *)tappedCell {
    
    [self setIPadPresentingIndexPath:[self.tableView indexPathForCell:tappedCell]];
    
    NSString *text = @"Me and my dad make models of clipper ships. #Clipperships sail on the ocean.";
    NSArray *images = @[[UIImage imageNamed:@"soda.jpg"],
                        [UIImage imageNamed:@"rain.jpg"],
                        [UIImage imageNamed:@"type.jpg"]];
    NSString *canonicalURL = @"http://twitter.com/testochango";
    NSString *authorName = @"testochango";
    
    // 1) Create the shareable content from the user's source content.
    OSKShareableContent *content = [OSKShareableContent contentFromMicroblogPost:text
                                                                      authorName:authorName
                                                                    canonicalURL:canonicalURL
                                                                          images:images];
    
    // 2) Setup optional completion and dismissal handlers
    OSKActivityCompletionHandler completionHandler = [self activityCompletionHandler];
    OSKActivitySheetDismissalHandler dismissalHandler = [self dismissalHandler];
    
    // 3) Create the options dictionary. See OSKActivity.h for more options.
    NSDictionary *options = @{    OSKActivityOption_ActivityCompletionHandler : completionHandler,
                              OSKActivityOption_ActivitySheetDismissalHandler : dismissalHandler};
    
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

- (void)showShareSheet_Pad_FromBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    NSString *text = @"Me and my dad make models of clipper ships. #Clipperships sail on the ocean.";
    NSArray *images = @[[UIImage imageNamed:@"soda.jpg"],
                        [UIImage imageNamed:@"rain.jpg"],
                        [UIImage imageNamed:@"type.jpg"]];
    NSString *canonicalURL = @"http://twitter.com/testochango";
    NSString *authorName = @"testochango";
    
    // 1) Create the shareable content from the user's source content.
    OSKShareableContent *content = [OSKShareableContent contentFromMicroblogPost:text
                                                                      authorName:authorName
                                                                    canonicalURL:canonicalURL
                                                                          images:images];
    
    // 2) Setup optional completion and dismissal handlers
    OSKActivityCompletionHandler completionHandler = [self activityCompletionHandler];
    OSKActivitySheetDismissalHandler dismissalHandler = [self dismissalHandler];
    
    // 3) Create the options dictionary. See OSKActivity.h for more options.
    NSDictionary *options = @{    OSKActivityOption_ActivityCompletionHandler : completionHandler,
                                  OSKActivityOption_ActivitySheetDismissalHandler : dismissalHandler};
    
    // 4) Present the activity sheet via the presentation manager.
    [[OSKPresentationManager sharedInstance] presentActivitySheetForContent:content
                                                   presentingViewController:self
                                                   popoverFromBarButtonItem:barButtonItem
                                                   permittedArrowDirections:UIPopoverArrowDirectionAny
                                                                   animated:YES
                                                                    options:options];
}

- (void)showShareSheet_Phone {
    NSString *text = @"Me and my dad make models of clipper ships. #Clipperships sail on the ocean.";
    NSArray *images = @[[UIImage imageNamed:@"soda.jpg"],
                        [UIImage imageNamed:@"rain.jpg"],
                        [UIImage imageNamed:@"type.jpg"]];
    NSString *canonicalURL = @"http://twitter.com/testochango";
    NSString *authorName = @"testochango";
    
    // 1) Create the shareable content from the user's source content.
    OSKShareableContent *content = [OSKShareableContent contentFromMicroblogPost:text
                                                                      authorName:authorName
                                                                    canonicalURL:canonicalURL
                                                                          images:images];
    
    // 2) Setup optional completion and dismissal handlers
    OSKActivityCompletionHandler completionHandler = [self activityCompletionHandler];
    OSKActivitySheetDismissalHandler dismissalHandler = [self dismissalHandler];
    
    // 3) Create the options dictionary. See OSKActivity.h for more options.
    NSDictionary *options = @{    OSKActivityOption_ActivityCompletionHandler : completionHandler,
                              OSKActivityOption_ActivitySheetDismissalHandler : dismissalHandler};
    
    // 4) Present the activity sheet via the presentation manager.
    [[OSKPresentationManager sharedInstance] presentActivitySheetForContent:content
                                                   presentingViewController:self
                                                                    options:options];
}



#pragma mark - OSKPresentationManager Style Delegate

- (OSKActivitySheetViewControllerStyle)osk_activitySheetStyle {
    return self.sheetStyle;
}

- (BOOL)osk_toolbarsUseUnjustifiablyBorderlessButtons {
    BOOL hellNo = NO;
    return hellNo;
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
    [self showShareSheet_Pad_FromBarButtonItem:item];
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

- (OSKActivitySheetDismissalHandler)dismissalHandler {
    __weak SampleTimelineViewController *weakSelf = self;
    OSKActivitySheetDismissalHandler dismissalHandler = ^{
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




