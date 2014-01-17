//
//  OSKReadingListActivity.m
//  Overshare
//
//
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//

#import "OSKReadingListActivity.h"

@import SafariServices;

#import "OSKActivitiesManager.h"
#import "OSKShareableContentItem.h"

@interface OSKReadingListActivity ()

@end

@implementation OSKReadingListActivity

- (instancetype)initWithContentItem:(OSKShareableContentItem *)item {
    self = [super initWithContentItem:item];
    if (self) {
    }
    return self;
}

#pragma mark - Methods for OSKActivity Subclasses

+ (NSString *)supportedContentItemType {
    return OSKShareableContentItemType_ReadLater;
}

+ (BOOL)isAvailable {
    return YES;
}

+ (NSString *)activityType {
    return OSKActivityType_iOS_ReadingList;
}

+ (NSString *)activityName {
    return @"Reading List";
}

+ (UIImage *)iconForIdiom:(UIUserInterfaceIdiom)idiom {
    UIImage *image = nil;
    if (idiom == UIUserInterfaceIdiomPhone) {
        image = [UIImage imageNamed:@"ReadingList-Icon-60.png"];
    } else {
        image = [UIImage imageNamed:@"ReadingList-Icon-76.png"];
    }
    return image;
}

+ (UIImage *)settingsIcon {
    return [UIImage imageNamed:@"ReadingList-Icon-29.png"];
}

+ (OSKAuthenticationMethod)authenticationMethod {
    return OSKAuthenticationMethod_None;
}

+ (BOOL)requiresApplicationCredential {
    return NO;
}

+ (OSKPublishingViewControllerType)publishingViewControllerType {
    return OSKPublishingViewControllerType_None;
}

- (BOOL)isReadyToPerform {
    return ([self readLaterItem].url != nil);
}

- (void)performActivity:(OSKActivityCompletionHandler)completion {
    OSKReadLaterContentItem *item = [self readLaterItem];
    NSError *error = nil;
    [[SSReadingList defaultReadingList] addReadingListItemWithURL:item.url
                                                            title:item.title
                                                      previewText:item.description
                                                            error:&error];
    __weak OSKReadingListActivity *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (completion) {
            BOOL successful = (error == nil);
            completion(weakSelf, successful, error);
        }
    });
}

+ (BOOL)canPerformViaOperation {
    return NO;
}

- (OSKActivityOperation *)operationForActivityWithCompletion:(OSKActivityCompletionHandler)completion {
    OSKActivityOperation *op = nil;
    return op;
}

#pragma mark - Convenience

- (OSKReadLaterContentItem *)readLaterItem {
    return (OSKReadLaterContentItem *)self.contentItem;
}

@end






