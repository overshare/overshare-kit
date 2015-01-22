//
//  OSKShareableContentItem.m
//  Overshare
//
//   
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//

#import "OSKShareableContentItem.h"

NSString * const OSKShareableContentItemType_MicroblogPost = @"OSKShareableContentItemType_MicroblogPost";
NSString * const OSKShareableContentItemType_Facebook = @"OSKShareableContentItemType_Facebook";
NSString * const OSKShareableContentItemType_BlogPost = @"OSKShareableContentItemType_BlogPost";
NSString * const OSKShareableContentItemType_Email = @"OSKShareableContentItemType_Email";
NSString * const OSKShareableContentItemType_SMS = @"OSKShareableContentItemType_SMS";
NSString * const OSKShareableContentItemType_PhotoSharing = @"OSKShareableContentItemType_PhotoSharing";
NSString * const OSKShareableContentItemType_CopyToPasteboard = @"OSKShareableContentItemType_CopyToPasteboard";
NSString * const OSKShareableContentItemType_ReadLater = @"OSKShareableContentItemType_ReadLater";
NSString * const OSKShareableContentItemType_LinkBookmark = @"OSKShareableContentItemType_LinkBookmark";
NSString * const OSKShareableContentItemType_WebBrowser = @"OSKShareableContentItemType_WebBrowser";
NSString * const OSKShareableContentItemType_PasswordManagementAppSearch = @"OSKShareableContentItemType_PasswordManagementAppSearch";
NSString * const OSKShareableContentItemType_ToDoListEntry = @"OSKShareableContentItemType_ToDoListEntry";
NSString * const OSKShareableContentItemType_AirDrop = @"OSKShareableContentItemType_AirDrop";
NSString * const OSKShareableContentItemType_TextEditing = @"OSKShareableContentItemType_TextEditing";

NSMutableArray *allURLs;

@implementation OSKShareableContentItem

- (instancetype)init {
    self = [super init];
    if (self) {
        _userInfo = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSString *)itemType {
    NSAssert(NO, @"OSKShareableContentItem subclasses must override itemType without calling super.");
    return nil;
}

// --- Branch ---
// Branch URL Methods

- (NSURL *)setBranchUrl {
    NSURL *returnUrl;
    if ([self.itemType isEqualToString:OSKShareableContentItemType_Facebook]) {
        returnUrl = ((OSKFacebookContentItem*)self).link;
    } else if ([@[
                  OSKShareableContentItemType_ReadLater,
                  OSKShareableContentItemType_LinkBookmark]
                containsObject:self.itemType]) {
        returnUrl = ((OSKReadLaterContentItem*)self).url;
    } else if ([@[
                  OSKShareableContentItemType_MicroblogPost,
                  OSKShareableContentItemType_BlogPost,
                  OSKShareableContentItemType_CopyToPasteboard,
                  OSKShareableContentItemType_TextEditing
                  ] containsObject:self.itemType]) {
        NSString *text = ((OSKBlogPostContentItem*)self).text;
        [self identifyAllUrlsAndReplaceInString:text];
        returnUrl = [NSURL URLWithString:text];
    } else if ([@[
                  OSKShareableContentItemType_Email,
                  OSKShareableContentItemType_SMS
                  ] containsObject:self.itemType]) {
        NSString *body = ((OSKEmailContentItem*)self).body;
        [self identifyAllUrlsAndReplaceInString:body];
        returnUrl = [NSURL URLWithString:body];
    } else if (self.itemType == OSKShareableContentItemType_ToDoListEntry) {
        NSString *notes = ((OSKToDoListEntryContentItem*)self).notes;
        [self identifyAllUrlsAndReplaceInString:notes];
        returnUrl = [NSURL URLWithString:notes];
    }
    return returnUrl;
}

// identifies all links in a string, and replaces them with Branch short links
- (void)identifyAllUrlsAndReplaceInString:(NSString *)string {
    // Find all URLs in a string
    NSDataDetector *detect = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:nil];
    self.allURLs = [[detect matchesInString:string options:0 range:NSMakeRange(0, [string length])] mutableCopy];
    
    // Replace each URL in the string with a Branch Short URL
    for (int i=0; i<[self.allURLs count]; i++) {
        NSTextCheckingResult *linkResult = self.allURLs[i];
        [self processURLForBranch:linkResult.URL];
    }
}

- (void)processURLForBranch:(NSURL *)url {
    // Sinleton Branch instance
    Branch *branch = [Branch getInstance];
    
    // Branch Link params
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:url forKey:@"$desktop_url"];
    [params setObject:url forKey:@"$ios_url"];
    [params setObject:url forKey:@"$android_url"];
    /*
    [branch getShortURLWithParams:params andCallback:^(NSString *url, NSError *error) {
        if(!error) {
            // put the link somewhere
        }
    }];
     */
}

// come back to this, need to define multiple methods for any combination of arguments
- (void)shareableBranchWithUrl:(NSURL *)url
            andParams:(NSDictionary *)params
            andTags:(NSArray *)tags
            andChannel:(NSString *)channel
            andFeature:(NSString *)feature
            andStage:(NSString *)stage
            andAlias:(NSString *)alias
            andCallback:(callbackWithUrl)callback {
    NSLog(@"url: %@", url);
    NSLog(@"params: %@", params);
    NSLog(@"tags: %@", tags);
    NSLog(@"channel: %@", channel);
    NSLog(@"feature: %@", feature);
    NSLog(@"stage: %@", stage);
    NSLog(@"alias: %@", alias);
    NSLog(@"callback: %@", callback);
}

// End Branch Url Methods
// --- Branch ---

@end

@implementation OSKMicroblogPostContentItem

- (NSString *)itemType {
    return OSKShareableContentItemType_MicroblogPost;
}

@end

@implementation OSKFacebookContentItem

- (NSString *)itemType {
    return OSKShareableContentItemType_Facebook;
}

@end

@implementation OSKBlogPostContentItem

- (NSString *)itemType {
    return OSKShareableContentItemType_BlogPost;
}

@end

@implementation OSKEmailContentItem

- (NSString *)itemType {
    return OSKShareableContentItemType_Email;
}

@end

@implementation OSKSMSContentItem

- (NSString *)itemType {
    return OSKShareableContentItemType_SMS;
}

@end

@implementation OSKPhotoSharingContentItem

- (NSString *)itemType {
    return OSKShareableContentItemType_PhotoSharing;
}

@end

@implementation OSKCopyToPasteboardContentItem

- (NSString *)itemType {
    return OSKShareableContentItemType_CopyToPasteboard;
}

- (void)setText:(NSString *)text {
    _text = [text copy];
    if (_text) {
        [self setImages:nil];
    }
}

- (void)setImages:(NSArray *)images {
    _images = [images copy];
    if (_images) {
        [self setText:nil];
    }
}

@end

@implementation OSKReadLaterContentItem

- (NSString *)itemType {
    return OSKShareableContentItemType_ReadLater;
}

@end

@implementation OSKLinkBookmarkContentItem

- (instancetype)init {
    self = [super init];
    if (self) {
        _markToRead = YES;
    }
    return self;
}

- (NSString *)itemType {
    return OSKShareableContentItemType_LinkBookmark;
}

@end

@implementation OSKWebBrowserContentItem

- (NSString *)itemType {
    return OSKShareableContentItemType_WebBrowser;
}

@end

@implementation OSKPasswordManagementAppSearchContentItem

- (NSString *)itemType {
    return OSKShareableContentItemType_PasswordManagementAppSearch;
}

@end

@implementation OSKToDoListEntryContentItem

- (NSString *)itemType {
    return OSKShareableContentItemType_ToDoListEntry;
}

@end

@implementation OSKAirDropContentItem

- (NSString *)itemType {
    return OSKShareableContentItemType_AirDrop;
}

@end

@implementation OSKTextEditingContentItem

- (NSString *)itemType {
    return OSKShareableContentItemType_TextEditing;
}

@end

