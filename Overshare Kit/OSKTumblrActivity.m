//
//  OSKTumblrActivity.m
//  Overshare
//
//
//  Copyright (c) 2014 Overshare Kit. All rights reserved.
//

#import "OSKTumblrActivity.h"
#import "OSKBloggingActivity.h"

#import "OSKActivitiesManager.h"
#import "OSKActivity_ManagedAccounts.h"
#import "OSKADNLoginManager.h"
#import "OSKAppDotNetUtility.h"
#import "OSKLogger.h"
#import "OSKManagedAccount.h"
#import "OSKShareableContentItem.h"
#import "NSString+OSKEmoji.h"

static NSInteger OSKTumblrActivity_MaxCharacterCount = 6000;
static NSInteger OSKTumblrActivity_MaxUsernameLength = 20;
static NSInteger OSKTumblrActivity_MaxImageCount = 0;

@interface OSKTumblrActivity ()

@property (strong, nonatomic) NSTimer *authenticationTimeoutTimer;
@property (assign, nonatomic) BOOL authenticationTimedOut;
@property (copy, nonatomic) OSKManagedAccountAuthenticationHandler completionHandler;

@end

@implementation OSKTumblrActivity

@synthesize activeManagedAccount = _activeManagedAccount;
@synthesize remainingCharacterCount = _remainingCharacterCount;

- (instancetype)initWithContentItem:(OSKShareableContentItem *)item {
    self = [super initWithContentItem:item];
    if (self) {
    }
    return self;
}

#pragma mark - System Account Methods

+ (OSKManagedAccountAuthenticationViewControllerType)authenticationViewControllerType {
    return OSKManagedAccountAuthenticationViewControllerType_OneOfAKindCustomBespokeViewController;
}

- (OSKUsernameNomenclature)usernameNomenclatureForSignInScreen {
    return OSKUsernameNomenclature_Email;
}

#pragma mark - Methods for OSKActivity Subclasses

+ (NSString *)supportedContentItemType {
    return OSKShareableContentItemType_BlogPost;
}

+ (BOOL)isAvailable {
    return YES;
}

+ (NSString *)activityType {
    return OSKActivityType_API_Tumblr;
}

+ (NSString *)activityName {
    return @"Tumblr";
}

+ (UIImage *)iconForIdiom:(UIUserInterfaceIdiom)idiom {
    UIImage *image = nil;
    if (idiom == UIUserInterfaceIdiomPhone) {
        image = [UIImage imageNamed:@"osk-tumblrIcon-60.png"];
    } else {
        image = [UIImage imageNamed:@"osk-tumblrIcon-76.png"];
    }
    return image;
}

+ (UIImage *)settingsIcon {
    return [UIImage imageNamed:@"osk-tumblrIcon-29.png"];
}

+ (OSKAuthenticationMethod)authenticationMethod {
    return OSKAuthenticationMethod_ManagedAccounts;
}

+ (BOOL)requiresApplicationCredential {
    return YES;
}

+ (OSKPublishingMethod)publishingMethod {
    return OSKPublishingMethod_ViewController_Microblogging;
}

- (BOOL)isReadyToPerform {
    BOOL appCredentialPreset = ([self.class applicationCredential] != nil);
    BOOL credentialPresent = (self.activeManagedAccount.credential != nil);
    BOOL accountPresent = (self.activeManagedAccount != nil);
    
    NSInteger maxCharacterCount = [self maximumCharacterCount];
    BOOL textIsValid = (0 <= self.remainingCharacterCount && self.remainingCharacterCount < maxCharacterCount);
    
    return (appCredentialPreset && credentialPresent && accountPresent && textIsValid);
}

- (void)performActivity:(OSKActivityCompletionHandler)completion {
    __weak OSKTumblrActivity *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [OSKAppDotNetUtility
         postContentItem:(OSKMicroblogPostContentItem *)weakSelf.contentItem
         withCredential:weakSelf.activeManagedAccount.credential
         appCredential:[weakSelf.class applicationCredential]
         completion:^(BOOL success, NSError *error) {
             OSKLog(@"Success! Sent new post to Tumblr.");
             if (completion) {
                 completion(weakSelf, success, error);
             }
         }];
    });
}

+ (BOOL)canPerformViaOperation {
    return NO;
}

- (OSKActivityOperation *)operationForActivityWithCompletion:(OSKActivityCompletionHandler)completion {
    return nil;
}

#pragma mark - Microblogging Activity Protocol

- (NSInteger)maximumCharacterCount {
    return OSKTumblrActivity_MaxCharacterCount;
}

- (NSInteger)maximumImageCount {
    return OSKTumblrActivity_MaxImageCount;
}

- (OSKSyntaxHighlighting)syntaxHighlighting {
    return OSKSyntaxHighlighting_Hashtags | OSKSyntaxHighlighting_Links | OSKSyntaxHighlighting_Usernames;
}

- (NSInteger)maximumUsernameLength {
    return OSKTumblrActivity_MaxUsernameLength;
}

- (NSInteger)updateRemainingCharacterCount:(OSKMicroblogPostContentItem *)contentItem urlEntities:(NSArray *)urlEntities {
    
    NSString *text = contentItem.text;
    NSInteger composedLength = [text osk_lengthAdjustingForComposedCharacters];
    NSInteger remainingCharacterCount = [self maximumCharacterCount] - composedLength;
    
    [self setRemainingCharacterCount:remainingCharacterCount];
    
    return remainingCharacterCount;
}

@end
