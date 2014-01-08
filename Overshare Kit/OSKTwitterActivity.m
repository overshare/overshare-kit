//
//  OSKTwitterActivity.m
//  Overshare
//
//   
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//

@import Accounts;

#import "OSKTwitterActivity.h"
#import "OSKTwitterUtility.h"
#import "OSKMicrobloggingActivity.h"
#import "OSKShareableContentItem.h"

#import "OSKSystemAccountStore.h"
#import "OSKActivity_SystemAccounts.h"

static NSInteger OSKTwitterActivity_MaxCharacterCount = 140;
static NSInteger OSKTwitterActivity_MaxUsernameLength = 20;
static NSInteger OSKTwitterActivity_MaxImageCount = 1;

@interface OSKTwitterActivity ()

@property (copy, nonatomic) NSNumber *estimatedLengthOfAttachmentURL;

@end

@implementation OSKTwitterActivity

@synthesize activeSystemAccount = _activeSystemAccount;

- (instancetype)initWithContentItem:(OSKShareableContentItem *)item {
    self = [super initWithContentItem:item];
    if (self) {
        //
    }
    return self;
}

#pragma mark - System Accounts

+ (NSString *)systemAccountTypeIdentifier {
    return ACAccountTypeIdentifierTwitter;
}

#pragma mark - Methods for OSKActivity Subclasses

+ (NSString *)supportedContentItemType {
    return OSKShareableContentItemType_MicroblogPost;
}

+ (BOOL)isAvailable {
    return YES; // This is *in general*, not whether account access has been granted.
}

+ (NSString *)activityType {
    return OSKActivityType_iOS_Twitter;
}

+ (NSString *)activityName {
    return @"Twitter";
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
    return OSKAuthenticationMethod_SystemAccounts;
}

+ (BOOL)requiresApplicationCredential {
    return NO;
}

+ (OSKPublishingViewControllerType)publishingViewControllerType {
    return OSKPublishingViewControllerType_Microblogging;
}

- (BOOL)isReadyToPerform {
    BOOL accountPresent = (self.activeSystemAccount != nil);

    NSInteger totalAvailableCharacters = [self maximumCharacterCount];
    OSKMicroblogPostContentItem *contentItem = (OSKMicroblogPostContentItem *)self.contentItem;
    if (contentItem.images.count) {
        NSUInteger attachmentLength = (_estimatedLengthOfAttachmentURL.integerValue) ? _estimatedLengthOfAttachmentURL.integerValue : 24;
        totalAvailableCharacters -= attachmentLength; // We only ever send the first image in the array, due to API limits.
    }
    BOOL textIsValid = (contentItem.text.length > 0 && contentItem.text.length <= totalAvailableCharacters);
    
    return (accountPresent && textIsValid);
}

- (void)performActivity:(OSKActivityCompletionHandler)completion {
    __weak OSKTwitterActivity *weakSelf = self;
    UIBackgroundTaskIdentifier backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        if (completion) {
            completion(weakSelf, NO, nil);
        }
    }];
    [OSKTwitterUtility
     postContentItem:(OSKMicroblogPostContentItem *)self.contentItem
     toSystemAccount:self.activeSystemAccount
     completion:^(BOOL success, NSError *error) {
         if (completion) {
             completion(weakSelf, (error == nil), error);
         }
         [[UIApplication sharedApplication] endBackgroundTask:backgroundTaskIdentifier];
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

- (BOOL)characterCountsAreAffectedByAttachments {
    return YES;
}

- (void)getEstimatedAttachmentURLLength:(void(^)(NSUInteger length))completion {
    if (_estimatedLengthOfAttachmentURL) {
        NSUInteger roughEstimate = [_estimatedLengthOfAttachmentURL integerValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(roughEstimate);
            }
        });

    }
    else if (self.activeSystemAccount) {
        __weak OSKTwitterActivity *weakSelf = self;
        [OSKTwitterUtility requestTwitterConfiguration:self.activeSystemAccount completion:^(NSError *error, NSDictionary *configurationParameters) {
            NSNumber *estimateNumber = configurationParameters[OSKTwitterImageHttpsURLLengthKey];
            CGFloat roughEstimate = (estimateNumber.integerValue) ? estimateNumber.integerValue : 24;
            [weakSelf setEstimatedLengthOfAttachmentURL:estimateNumber];
            if (completion) {
                completion(roughEstimate);
            }
        }];
    }
    else {
        NSUInteger roughEstimate = 24;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(roughEstimate);
            }
        });
    }
}

@end




