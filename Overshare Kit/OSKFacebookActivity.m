//
//  OSKFacebookActivity.m
//  Overshare
//
//  Created by Jared Sinclair on 10/15/13.
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//

@import Accounts;

#import "OSKFacebookActivity.h"
#import "OSKShareableContentItem.h"
#import "OSKApplicationCredential.h"

#import <Facebook.h>

static NSInteger OSKFacebookActivity_MaxCharacterCount = 6000;
static NSInteger OSKFacebookActivity_MaxUsernameLength = 20;
static NSInteger OSKFacebookActivity_MaxImageCount = 3;

@implementation OSKFacebookActivity

- (instancetype)initWithContentItem:(OSKShareableContentItem *)item {
    self = [super initWithContentItem:item];
    if (self) {
        _currentAudience = ACFacebookAudienceEveryone;
    }
    return self;
}

#pragma mark - Methods for OSKActivity Subclasses

+ (NSString *)supportedContentItemType {
    return OSKShareableContentItemType_MicroblogPost;
}

+ (BOOL)isAvailable {
    return YES; // This is *in general*, not whether account access has been granted.
}

+ (NSString *)activityType {
    return OSKActivityType_iOS_Facebook;
}

+ (NSString *)activityName {
    return @"Facebook";
}

+ (UIImage *)iconForIdiom:(UIUserInterfaceIdiom)idiom {
    UIImage *image = nil;
    if (idiom == UIUserInterfaceIdiomPhone) {
        image = [UIImage imageNamed:@"osk-facebookIcon-60.png"];
    } else {
        image = [UIImage imageNamed:@"osk-facebookIcon-76.png"];
    }
    return image;
}

+ (UIImage *)settingsIcon {
    return [self iconForIdiom:UIUserInterfaceIdiomPhone];
}

+ (OSKAuthenticationMethod)authenticationMethod {
    return OSKAuthenticationMethod_None;
}

+ (BOOL)requiresApplicationCredential {
    NSAssert([[NSBundle mainBundle] objectForInfoDictionaryKey:@"FacebookAppID"], @"You must define your Facebook App ID in the main Info.plist file as defined by the Facebook SDK. \
			 https://developers.facebook.com/docs/ios/getting-started#configure");
	
	return NO;
}

+ (OSKPublishingViewControllerType)publishingViewControllerType {
    return OSKPublishingViewControllerType_None;
}

- (BOOL)isReadyToPerform {
    OSKMicroblogPostContentItem *contentItem = (OSKMicroblogPostContentItem *)self.contentItem;
    NSInteger maxCharacterCount = [self maximumCharacterCount];
    BOOL textIsValid = (contentItem.text.length > 0 && contentItem.text.length <= maxCharacterCount);
    
    return textIsValid;
}

- (void)performActivity:(OSKActivityCompletionHandler)completion {
    __weak OSKFacebookActivity *weakSelf = self;
	
	OSKMicroblogPostContentItem *contentItem = (OSKMicroblogPostContentItem *)self.contentItem;
	FBShareDialogParams *shareParams	= [FBShareDialogParams new];
	shareParams.link					= [NSURL URLWithString:contentItem.text];
	
	if ([FBDialogs canPresentShareDialogWithParams:shareParams])
	{
		[FBDialogs presentShareDialogWithParams:shareParams
									clientState:nil
										handler:nil];
	}
	else
	{
		[FBWebDialogs presentFeedDialogModallyWithSession:nil
											   parameters:@{
															@"link": contentItem.text,
															}
												  handler:nil];
	}
	
	if (completion) {
		completion(weakSelf, NO, nil);
	}
}

+ (BOOL)canPerformViaOperation {
    return NO;
}

- (OSKActivityOperation *)operationForActivityWithCompletion:(OSKActivityCompletionHandler)completion {
    return nil;
}

#pragma mark - Microblogging Activity Protocol

- (NSInteger)maximumCharacterCount {
    return OSKFacebookActivity_MaxCharacterCount;
}

- (NSInteger)maximumImageCount {
    return OSKFacebookActivity_MaxImageCount;
}

- (OSKMicroblogSyntaxHighlightingStyle)syntaxHighlightingStyle {
    return OSKMicroblogSyntaxHighlightingStyle_LinksOnly;
}

- (NSInteger)maximumUsernameLength {
    return OSKFacebookActivity_MaxUsernameLength;
}

@end
