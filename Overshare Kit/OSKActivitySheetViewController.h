//
//  OSKActivitySheetViewController.h
//  Overshare
//
//   
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//

@import UIKit;

#import "OSKActivity.h"

@protocol OSKActivitySheetDelegate;

typedef void(^OSKActivitySheetDismissalHandler)(void);

@interface OSKActivitySheetViewController : UIViewController

// Uniquely identifies a given activity sheet.
@property (strong, nonatomic, readonly) NSString *sessionIdentifier;

// The activityCompletionHandler is called when a tapped activity finishes or fails
@property (copy, nonatomic) OSKActivityCompletionHandler activityCompletionHandler;

// The dismissalHandler is called after the sheet is dismissed, regardless of when or why
@property (copy, nonatomic) OSKActivitySheetDismissalHandler dismissalHandler;

- (instancetype)initWithActivities:(NSArray *)activities delegate:(id <OSKActivitySheetDelegate>)delegate usePopoverLayout:(BOOL)usePopoverLayout;

- (CGFloat)visibleSheetHeightForCurrentLayout;

@end

