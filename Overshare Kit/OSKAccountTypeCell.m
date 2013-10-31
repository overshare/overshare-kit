//
//  OSKAccountTypeself.m
//  Overshare
//
//  Created by Jared on 10/30/13.
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//

#import "OSKAccountTypeCell.h"

#import "OSKInMemoryImageCache.h"
#import "OSKActivity.h"
#import "OSKPresentationManager.h"

static NSString * OSKActivitySettingsIconMaskImageKey = @"OSKActivitySettingsIconMaskImageKey";

NSString * const OSKAccountTypeCellIdentifier = @"OSKAccountTypeCellIdentifier";

@interface OSKAccountTypeCell()

@property (copy, nonatomic) NSString *imageKey;

@end

@implementation OSKAccountTypeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        OSKPresentationManager *presentationManager = [OSKPresentationManager sharedInstance];
        UIColor *bgColor = [presentationManager color_groupedTableViewCells];
        self.backgroundColor = bgColor;
        self.backgroundView.backgroundColor = bgColor;
        self.textLabel.textColor = [presentationManager color_text];
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
        self.selectedBackgroundView.backgroundColor = presentationManager.color_cancelButtonColor_BackgroundHighlighted;
        self.tintColor = presentationManager.color_action;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.imageView.image = [UIImage imageNamed:@"osk-settingsPlaceholder.png"]; // fixes UIKit bug.
    }
    return self;
}

- (void)setActivityClass:(Class)activityClass {
    _activityClass = activityClass;
    NSString *name = [activityClass activityName];
    [self.textLabel setText:name];
    [self updateIcon:activityClass];
}

- (UIImage *)maskImage {
    UIImage *maskImage = [[OSKInMemoryImageCache sharedInstance] objectForKey:OSKActivitySettingsIconMaskImageKey];
    if (maskImage == nil) {
        maskImage = [UIImage imageNamed:@"osk-iconMask-bw-29.png"];
        if (maskImage) {
            [[OSKInMemoryImageCache sharedInstance] setObject:maskImage forKey:OSKActivitySettingsIconMaskImageKey];
        }
    }
    return maskImage;
}

- (void)maskImage:(UIImage *)image withMask:(UIImage *)maskImage completion:(void(^)(UIImage *maskedImage))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGImageRef maskRef = maskImage.CGImage;
        CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                            CGImageGetHeight(maskRef),
                                            CGImageGetBitsPerComponent(maskRef),
                                            CGImageGetBitsPerPixel(maskRef),
                                            CGImageGetBytesPerRow(maskRef),
                                            CGImageGetDataProvider(maskRef), NULL, false);
        
        CGImageRef maskedImageRef = CGImageCreateWithMask([image CGImage], mask);
        CGFloat scale = [[UIScreen mainScreen] scale];
        UIImage *maskedImage = [UIImage imageWithCGImage:maskedImageRef scale:scale orientation:UIImageOrientationUp];
        CGImageRelease(mask);
        CGImageRelease(maskedImageRef);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(maskedImage);
            }
        });
    });
}

- (NSString *)keyForActivityType:(NSString *)type {
    return [NSString stringWithFormat:@"%@_settings", type];
}

- (void)updateIcon:(Class)activityClass {
    NSString *imageKey = [self keyForActivityType:[activityClass activityType]];
    if ([_imageKey isEqualToString:imageKey] == NO) {
        
        [self setImageKey:imageKey];
        
        UIImage *cachedImage = [[OSKInMemoryImageCache sharedInstance] objectForKey:imageKey];
        
        if (cachedImage) {
            [self.imageView setImage:cachedImage];
        } else {
            UIImage *settingsIcon = [activityClass settingsIcon];
            if (settingsIcon == nil) {
                settingsIcon = [self maskImage];
            }

            __weak OSKAccountTypeCell *weakSelf = self;
            [self maskImage:settingsIcon withMask:[self maskImage] completion:^(UIImage *maskedImage) {
                if ([weakSelf.imageKey isEqualToString:imageKey]) { // May have changed during processing
                    [weakSelf.imageView setImage:maskedImage];
                    [[OSKInMemoryImageCache sharedInstance] setObject:maskedImage forKey:imageKey];
                }
            }];
        }
    }
}

@end





