//
//  OSKBloggingActivity.h
//  Overshare
//
//   
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//

@import Foundation;

@class OSKBlogPostContentItem;

#import "OSKSyntaxHighlighting.h"

@protocol OSKBloggingActivity <NSObject>

@property (assign, nonatomic) NSInteger remainingCharacterCount;

- (NSInteger)maximumCharacterCount;
- (NSInteger)maximumImageCount;
- (NSInteger)maximumUsernameLength;
- (NSInteger)updateRemainingCharacterCount:(OSKBlogPostContentItem *)contentItem urlEntities:(NSArray *)urlEntities;
- (OSKSyntaxHighlighting)syntaxHighlighting;

@optional

- (BOOL)allowLinkShortening; // OSK assumes YES.

@end

