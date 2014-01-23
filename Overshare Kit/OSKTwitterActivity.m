//
//  OSKTwitterActivity.m
//  Overshare
//
//   
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//

#import "OSKTwitterActivity.h"

@import Social;

#import "OSKShareableContentItem.h"
#import "OSKLocalizedStrings.h"

static NSInteger OSKTwitterActivity_MaxCharacterCount = 140;
static NSInteger OSKTwitterActivity_MaxUsernameLength = 20;
static NSInteger OSKTwitterActivity_MaxImageCount = 1;

@interface OSKTwitterActivity ()

@end

@implementation OSKTwitterActivity

- (instancetype)initWithContentItem:(OSKShareableContentItem *)item {
    self = [super initWithContentItem:item];
    if (self) {
        //
    }
    return self;
}

#pragma mark - Methods for OSKActivity Subclasses

+ (NSString *)supportedContentItemType {
    return OSKShareableContentItemType_MicroblogPost;
}

+ (BOOL)isAvailable {
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
}

+ (NSString *)activityType {
    return OSKActivityType_iOS_Twitter;
}

+ (NSString *)activityName {
    return OSKLocalizedString(@"Twitter", nil);
}

+ (UIImage *)iconForIdiom:(UIUserInterfaceIdiom)idiom {
    UIImage *image = nil;
    if (idiom == UIUserInterfaceIdiomPhone) {
        image = [UIImage imageNamed:@"osk-twitterIcon-60.png"];
    } else {
        image = [UIImage imageNamed:@"osk-twitterIcon-76.png"];
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
    return NO;
}

+ (OSKPublishingViewControllerType)publishingViewControllerType {
    return OSKPublishingViewControllerType_System;
}

- (BOOL)isReadyToPerform {
    OSKMicroblogPostContentItem *contentItem = (OSKMicroblogPostContentItem *)self.contentItem;
    NSInteger maxCharacterCount = [self maximumCharacterCount];
    BOOL textIsValid = (contentItem.text.length > 0 && contentItem.text.length <= maxCharacterCount);
    
	return textIsValid;
}

- (void)performActivity:(OSKActivityCompletionHandler)completion {
    __weak OSKTwitterActivity *weakSelf = self;
	[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        if (completion) {
            completion(weakSelf, NO, nil);
        }
    }];
}

+ (BOOL)canPerformViaOperation {
    return NO;
}

- (OSKActivityOperation *)operationForActivityWithCompletion:(OSKActivityCompletionHandler)completion {
    return nil;
}

#pragma mark - Microblogging Activity Protocol

- (NSInteger)maximumCharacterCount {
    return OSKTwitterActivity_MaxCharacterCount;
}

- (NSInteger)maximumImageCount {
    return OSKTwitterActivity_MaxImageCount;
}

- (OSKMicroblogSyntaxHighlightingStyle)syntaxHighlightingStyle {
    return OSKMicroblogSyntaxHighlightingStyle_Twitter;
}

- (NSInteger)maximumUsernameLength {
    return OSKTwitterActivity_MaxUsernameLength;
}

@end

