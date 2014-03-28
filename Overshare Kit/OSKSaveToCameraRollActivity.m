//
//  OSKSaveToCameraRollActivity.m
//  Pods
//
//  Created by Konstadinos Karayannis on 22/2/14.
//
//

#import "OSKSaveToCameraRollActivity.h"
#import "OSKShareableContentItem.h"

@interface OSKSaveToCameraRollActivity ()

@property (strong, nonatomic, readonly) OSKSaveToCameraRollContentItem *cameraRollItem;

@end

@implementation OSKSaveToCameraRollActivity

- (instancetype)initWithContentItem:(OSKShareableContentItem *)item {
    self = [super initWithContentItem:item];
    if (self) {
        //
    }
    return self;
}

#pragma mark - Methods for OSKActivity Subclasses

+ (NSString *)supportedContentItemType {
    return OSKShareableContentItemType_SaveToCameraRoll;
}

+ (BOOL)isAvailable {
    return YES;
}

+ (NSString *)activityType {
    return OSKActivityType_iOS_SaveToCameraRoll;
}

+ (NSString *)activityName {
    return @"Camera Roll";
}

+ (UIImage *)iconForIdiom:(UIUserInterfaceIdiom)idiom {
    UIImage *image = nil;
    if (idiom == UIUserInterfaceIdiomPhone) {
        image = [UIImage imageNamed:@"osk-photosIcon-60.png"];
    } else {
        image = [UIImage imageNamed:@"oosk-photosIcon-76.png"];
    }
    return image;
}


+ (OSKAuthenticationMethod)authenticationMethod {
    return OSKAuthenticationMethod_None;
}

+ (BOOL)requiresApplicationCredential {
    return NO;
}

+ (OSKPublishingMethod)publishingMethod {
    return OSKPublishingMethod_None;
}

- (BOOL)isReadyToPerform {
    return (self.cameraRollItem.image ? YES : NO);
}

- (void)performActivity:(OSKActivityCompletionHandler)completion {
    UIImageWriteToSavedPhotosAlbum(self.cameraRollItem.image, nil, nil, nil);
    if (completion) {
        completion(self, YES, nil);
    }
}

+ (BOOL)canPerformViaOperation {
    return NO;
}

- (OSKActivityOperation *)operationForActivityWithCompletion:(OSKActivityCompletionHandler)completion {
    return nil;
}

#pragma mark - Convenience

- (OSKSaveToCameraRollContentItem *)cameraRollItem {
    return (OSKSaveToCameraRollContentItem *)self.contentItem;
}

@end