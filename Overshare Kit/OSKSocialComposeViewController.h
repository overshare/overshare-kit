//
//  OSKSocialComposeViewController.h
//  Overshare
//
//  Created by Flavio Caetano on 1/22/14.
//  Copyright (c) 2014 Overshare Kit. All rights reserved.
//

@import Social;

#import "OSKPublishingViewController.h"
#import "OSKMicrobloggingActivity.h"
#import "OSKActivity.h"

@interface OSKSocialComposeViewController : SLComposeViewController <OSKPublishingViewController>

+ (instancetype)composeForMicrobloggingActivity:(OSKActivity *)activity;

@end