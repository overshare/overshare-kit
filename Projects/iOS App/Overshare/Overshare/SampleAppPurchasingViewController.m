//
//  SampleAppPurchasingViewController.m
//  Overshare
//
//  Created by Jared on 10/28/13.
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//

#import "SampleAppPurchasingViewController.h"

#import "OSKActivity.h"
#import "OSKBorderedButton.h"
#import "OSKPresentationManager.h"

@interface SampleAppPurchasingViewController ()

@property (weak, nonatomic) IBOutlet UILabel *activityNameLabel;
@property (weak, nonatomic) IBOutlet OSKBorderedButton *button;

@end

@implementation SampleAppPurchasingViewController

@synthesize activity = _activity;
@synthesize purchasingDelegate = _purchasingDelegate;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
        [self setTitle:@"Overshare Pro"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.button.layer.cornerRadius = 20.0f;
    self.button.clipsToBounds = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    [self updateColors];
    [self.activityNameLabel setText:@"Overshare Pro"];
}

- (void)updateColors {
    OSKPresentationManager *presentationManager = [OSKPresentationManager sharedInstance];
    [self.activityNameLabel setTextColor:[presentationManager color_text]];
    [self.button setBackgroundColor:[UIColor colorWithWhite:0.5 alpha:0.2]];
}

- (void)cancelButtonPressed:(id)sender {
    [self.purchasingDelegate purchasingViewControllerDidCancel:self
                                                  withActivity:self.activity];
}

- (IBAction)buyButtonPressed:(id)sender {
    [self.purchasingDelegate purchasingViewController:self
                             didPurchaseActivityTypes:@[OSKActivityType_API_Instapaper,
                                                        OSKActivityType_API_Pocket,
                                                        OSKActivityType_API_Pinboard,
                                                        OSKActivityType_API_Readability,
                                                        OSKActivityType_URLScheme_Omnifocus,
                                                        OSKActivityType_URLScheme_Things]
                                         withActivity:self.activity];
}

- (void)preparePurchasingViewForActivity:(OSKActivity *)activity delegate:(id <OSKPurchasingViewControllerDelegate>)delegate {
    [self setPurchasingDelegate:delegate];
    [self setActivity:activity];
}

@end





