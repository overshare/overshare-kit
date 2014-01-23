//
//  OSKSocialComposeViewController.m
//  Overshare
//
//  Created by Flavio Caetano on 1/22/14.
//  Copyright (c) 2014 Overshare Kit. All rights reserved.
//

#import "OSKSocialComposeViewController.h"

#import "OSKMessageComposeViewController.h"
#import "OSKShareableContentItem.h"

@interface OSKSocialComposeViewController () <MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) OSKMicroblogPostContentItem *contentItem;

@end

@implementation OSKSocialComposeViewController

@synthesize oskPublishingDelegate = _oskPublishingDelegate;

+(instancetype)composeForMicrobloggingActivity:(OSKActivity<OSKMicrobloggingActivity> *)activity
{
	NSString *serviceType;
	NSString *activityType = [activity.class activityType];
	if ([activityType isEqualToString:OSKActivityType_iOS_Facebook])
	{
		serviceType = SLServiceTypeFacebook;
	}
	else if ([activityType isEqualToString:OSKActivityType_iOS_Twitter])
	{
		serviceType = SLServiceTypeTwitter;
	}
	
	OSKSocialComposeViewController *compose = (OSKSocialComposeViewController *)[OSKSocialComposeViewController composeViewControllerForServiceType:serviceType];
	compose.contentItem = (OSKMicroblogPostContentItem *)activity.contentItem;
	
	return compose;
}

- (void)preparePublishingViewForActivity:(OSKActivity *)activity delegate:(id<OSKPublishingViewControllerDelegate>)oskPublishingDelegate
{
	self.oskPublishingDelegate = oskPublishingDelegate;
	
	OSKMicroblogPostContentItem *contentItem = (OSKMicroblogPostContentItem *)self.contentItem;
	
	[self addURL:[NSURL URLWithString:contentItem.text]];
	[self addImage:contentItem.images.firstObject];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
}

@end
