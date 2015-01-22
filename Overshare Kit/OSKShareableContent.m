//
//  OSKShareableContent.m
//  Overshare
//
//   
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//

#import "OSKShareableContent.h"

#import "OSKShareableContentItem.h"

#import "Branch.h"

@implementation OSKShareableContent

- (void)processURLForBranchWithURL:(NSURL *)url
            andTags:(NSArray *)tags
            andChannel:(NSString *)channel
            andFeature:(NSString *)feature
            andStage:(NSString *)stage
            andAlias:(NSString *)alias {
    
    // Sinleton Branch instance
    Branch *branch = [Branch getInstance];
    
    // Branch Link params
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    //probably remove
    [params setObject:[url absoluteString] forKey:@"$desktop_url"];
    //certainly remove
    [params setObject:[url absoluteString] forKey:@"$ios_url"];
    [params setObject:[url absoluteString] forKey:@"$android_url"];
    
    // Weak block reference to self
    __weak OSKShareableContent *weakContent = self;
    
    // Create Branch Short URL for each channel
    if([channel isEqualToString:@"facebook"]) {
        [branch getShortURLWithParams:params
            andTags:tags
            andChannel:channel
            andFeature:feature
            andStage:stage
            andAlias:alias
            andCallback:^(NSString *url, NSError *error) {
                __strong OSKShareableContent *strongContent = weakContent;
                strongContent.facebookItem.link = [NSURL URLWithString:url];
        }];
    } else if ([channel isEqualToString:@"browser"]) {
        [branch getShortURLWithParams:params
            andTags:tags
            andChannel:channel
            andFeature:feature
            andStage:stage
            andAlias:alias
            andCallback:^(NSString *url, NSError *error) {
                __strong OSKShareableContent *strongContent = weakContent;
                strongContent.webBrowserItem.url = [NSURL URLWithString:url];
        }];
    } else if ([channel isEqualToString:@"read_later"]) {
        [branch getShortURLWithParams:params
            andTags:tags
            andChannel:channel
            andFeature:feature
            andStage:stage
            andAlias:alias
            andCallback:^(NSString *url, NSError *error) {
                __strong OSKShareableContent *strongContent = weakContent;
                strongContent.readLaterItem.url = [NSURL URLWithString:url];
        }];
    } else if ([channel isEqualToString:@"bookmark"]) {
        [branch getShortURLWithParams:params
            andTags:tags
            andChannel:channel
            andFeature:feature
            andStage:stage
            andAlias:alias
            andCallback:^(NSString *url, NSError *error) {
                __strong OSKShareableContent *strongContent = weakContent;
                strongContent.linkBookmarkItem.url = [NSURL URLWithString:url];
        }];
    }
}

/*
// identifies all links in a string, and replaces them with Branch short links
- (void)identifyAllUrlsAndReplaceInString:(NSString *)string {
    // Find all URLs in a string
    NSLog(@"String: %@", string);
    NSDataDetector *detect = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:nil];
    self.allURLs = [[detect matchesInString:string options:0 range:NSMakeRange(0, [string length])] mutableCopy];
    NSLog(@"Matches: %@", self.allURLs);
    
    // Replace each URL in the string with a Branch Short URL
    for (int i=0; i<[self.allURLs count]; i++) {
        NSTextCheckingResult *linkResult = self.allURLs[i];
        [self processURLForBranch:linkResult.URL withArrayIndex:(NSUInteger *)(unsigned long)i];
    }
}
*/
+ (instancetype)contentFromText:(NSString *)text {
    NSParameterAssert(text.length);
    
    OSKShareableContent *content = [[OSKShareableContent alloc] init];
    
    content.title = text;
    
    OSKFacebookContentItem *facebook = [[OSKFacebookContentItem alloc] init];
    facebook.text = text;
    content.facebookItem = facebook;
    
    OSKMicroblogPostContentItem *microblogPost = [[OSKMicroblogPostContentItem alloc] init];
    microblogPost.text = text;
    content.microblogPostItem = microblogPost;
    
    OSKCopyToPasteboardContentItem *copyURLToPasteboard = [[OSKCopyToPasteboardContentItem alloc] init];
    copyURLToPasteboard.text = text;
    content.pasteboardItem = copyURLToPasteboard;
    
    OSKEmailContentItem *emailItem = [[OSKEmailContentItem alloc] init];
    emailItem.body = text;
    content.emailItem = emailItem;
    
    OSKSMSContentItem *smsItem = [[OSKSMSContentItem alloc] init];
    smsItem.body = text;
    content.smsItem = smsItem;
    
    OSKToDoListEntryContentItem *toDoList = [[OSKToDoListEntryContentItem alloc] init];
    toDoList.title = text;
    content.toDoListItem = toDoList;
    
    OSKAirDropContentItem *airDrop = [[OSKAirDropContentItem alloc] init];
    airDrop.items = @[text];
    content.airDropItem = airDrop;
    
    OSKTextEditingContentItem *textEditing = [[OSKTextEditingContentItem alloc] init];
    textEditing.text = text;
    content.textEditingItem = textEditing;
    
    return content;
}

+ (instancetype)contentFromURL:(NSURL *)url {
    NSParameterAssert(url.absoluteString.length);
    
    OSKShareableContent *content = [[OSKShareableContent alloc] init];
    NSString *absoluteString = url.absoluteString;

    content.title = absoluteString;
    
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    
    OSKFacebookContentItem *facebook = [[OSKFacebookContentItem alloc] init];
    facebook.link = url;
    content.facebookItem = facebook;
    
    OSKMicroblogPostContentItem *microblogPost = [[OSKMicroblogPostContentItem alloc] init];
    microblogPost.text = absoluteString;
    content.microblogPostItem = microblogPost;
    
    OSKCopyToPasteboardContentItem *copyURLToPasteboard = [[OSKCopyToPasteboardContentItem alloc] init];
    copyURLToPasteboard.text = absoluteString;
    copyURLToPasteboard.alternateActivityName = @"Copy URL";
    content.pasteboardItem = copyURLToPasteboard;
    
    OSKEmailContentItem *emailItem = [[OSKEmailContentItem alloc] init];
    emailItem.body = absoluteString;
    emailItem.subject = [NSString stringWithFormat:@"Link from %@", appName];
    content.emailItem = emailItem;
    
    OSKSMSContentItem *smsItem = [[OSKSMSContentItem alloc] init];
    smsItem.body = absoluteString;
    content.smsItem = smsItem;
    
    OSKReadLaterContentItem *readLater = [[OSKReadLaterContentItem alloc] init];
    readLater.url = url;
    content.readLaterItem = readLater;
    
    OSKToDoListEntryContentItem *toDoList = [[OSKToDoListEntryContentItem alloc] init];
    toDoList.title = [NSString stringWithFormat:@"Look into link from %@", appName];
    toDoList.notes = absoluteString;
    content.toDoListItem = toDoList;
    
    OSKLinkBookmarkContentItem *linkBookmarking = [[OSKLinkBookmarkContentItem alloc] init];
    linkBookmarking.url = url;
    linkBookmarking.tags = @[appName];
    linkBookmarking.markToRead = YES;
    content.linkBookmarkItem = linkBookmarking;
    
    OSKWebBrowserContentItem *browserItem = [[OSKWebBrowserContentItem alloc] init];
    browserItem.url = url;
    content.webBrowserItem = browserItem;
    
    OSKPasswordManagementAppSearchContentItem *passwordSearchItem = [[OSKPasswordManagementAppSearchContentItem alloc] init];
    passwordSearchItem.query = [url host];
    content.passwordSearchItem = passwordSearchItem;
    
    OSKAirDropContentItem *airDrop = [[OSKAirDropContentItem alloc] init];
    airDrop.items = @[url];
    content.airDropItem = airDrop;
    
    OSKTextEditingContentItem *textEditing = [[OSKTextEditingContentItem alloc] init];
    textEditing.text = url.absoluteString;
    content.textEditingItem = textEditing;
    
    return content;
}

+ (instancetype)contentFromMicroblogPost:(NSString *)text authorName:(NSString *)authorName canonicalURL:(NSString *)canonicalURL images:(NSArray *)images {
    OSKShareableContent *content = [[OSKShareableContent alloc] init];
    
    content.title = [NSString stringWithFormat:@"Post by %@: “%@”", authorName, text];
    
    NSURL *URLforCanonicalURL = nil;
    if (canonicalURL) {
        URLforCanonicalURL = [NSURL URLWithString:canonicalURL];
    }
    
    OSKFacebookContentItem *facebook = [[OSKFacebookContentItem alloc] init];
    if (authorName) {
        facebook.text = [NSString stringWithFormat:@"Check out this post by %@: ", authorName];
    }
    if (canonicalURL) {
        facebook.link = URLforCanonicalURL;
    }
    else if (images) {
        // Image posts cannot be link posts and vice versa.
        facebook.images = images;
    }
    content.facebookItem = facebook;
    
    OSKMicroblogPostContentItem *microblogPost = [[OSKMicroblogPostContentItem alloc] init];
    microblogPost.text = [NSString stringWithFormat:@"“%@” (Via @%@) %@ ", text, authorName, canonicalURL];
    microblogPost.images = images;
    //[microblogPost setBranchUrl];
    content.microblogPostItem = microblogPost;
    
    OSKCopyToPasteboardContentItem *copyTextToPasteboard = [[OSKCopyToPasteboardContentItem alloc] init];
    copyTextToPasteboard.text = text;
    copyTextToPasteboard.alternateActivityName = @"Copy Text";
    content.pasteboardItem = copyTextToPasteboard;
    
    OSKCopyToPasteboardContentItem *copyURLToPasteboard = [[OSKCopyToPasteboardContentItem alloc] init];
    copyURLToPasteboard.text = canonicalURL;
    copyURLToPasteboard.alternateActivityName = @"Copy URL";
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        copyURLToPasteboard.alternateActivityIcon = [UIImage imageNamed:@"osk-copyIcon-purple-76.png"];
    } else {
        copyURLToPasteboard.alternateActivityIcon = [UIImage imageNamed:@"osk-copyIcon-purple-60.png"];
    }
    
    content.additionalItems = @[copyURLToPasteboard];
    
    OSKEmailContentItem *emailItem = [[OSKEmailContentItem alloc] init];
    emailItem.body = [NSString stringWithFormat:@"“%@”\n\n(Via @%@)\n\n%@ ", text, authorName, canonicalURL];
    emailItem.subject = @"Clipper Ships Sail On the Ocean";
    emailItem.attachments = images.copy;
    content.emailItem = emailItem;
    
    OSKSMSContentItem *smsItem = [[OSKSMSContentItem alloc] init];
    smsItem.body = microblogPost.text;
    smsItem.attachments = images;
    content.smsItem = smsItem;
    
    if (URLforCanonicalURL) {
        OSKReadLaterContentItem *readLater = [[OSKReadLaterContentItem alloc] init];
        readLater.url = URLforCanonicalURL;
        readLater.title = [NSString stringWithFormat:@"Post by %@", authorName];
        readLater.itemDescription = text;
        content.readLaterItem = readLater;
        
        OSKLinkBookmarkContentItem *linkBookmarking = [[OSKLinkBookmarkContentItem alloc] init];
        linkBookmarking.url = URLforCanonicalURL;
        linkBookmarking.notes = [NSString stringWithFormat:@"%@\n\n%@", text, canonicalURL];
        NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        linkBookmarking.tags = @[appName];
        linkBookmarking.markToRead = YES;
        content.linkBookmarkItem = linkBookmarking;
        
        OSKWebBrowserContentItem *browserItem = [[OSKWebBrowserContentItem alloc] init];
        browserItem.url = URLforCanonicalURL;
        content.webBrowserItem = browserItem;
    }
    
    OSKToDoListEntryContentItem *toDoList = [[OSKToDoListEntryContentItem alloc] init];
    toDoList.title = [NSString stringWithFormat:@"Look into message from %@", authorName];
    toDoList.notes = [NSString stringWithFormat:@"%@\n\n%@", text, canonicalURL];
    content.toDoListItem = toDoList;
    
    OSKPasswordManagementAppSearchContentItem *passwordSearchItem = [[OSKPasswordManagementAppSearchContentItem alloc] init];
    passwordSearchItem.query = [[NSURL URLWithString:canonicalURL] host];
    content.passwordSearchItem = passwordSearchItem;
    
    if (images.count) {
        OSKAirDropContentItem *airDrop = [[OSKAirDropContentItem alloc] init];
        airDrop.items = images;
        content.airDropItem = airDrop;
    }
    else if (canonicalURL.length) {
        OSKAirDropContentItem *airDrop = [[OSKAirDropContentItem alloc] init];
        airDrop.items = @[canonicalURL];
        content.airDropItem = airDrop;
    }
    else if (text.length) {
        OSKAirDropContentItem *airDrop = [[OSKAirDropContentItem alloc] init];
        airDrop.items = @[text];
        content.airDropItem = airDrop;
    }
    
    OSKTextEditingContentItem *textEditing = [[OSKTextEditingContentItem alloc] init];
    textEditing.text = emailItem.body;
    content.textEditingItem = textEditing;
    
    // Call Branch URLs
    if (URLforCanonicalURL) {
        [content processURLForBranchWithURL:URLforCanonicalURL
            andTags:nil
            andChannel:@"facebook"
            andFeature:nil
            andStage:nil
            andAlias:nil];
        [content processURLForBranchWithURL:URLforCanonicalURL
            andTags:nil
            andChannel:@"browser"
            andFeature:nil
            andStage:nil
            andAlias:nil];
        [content processURLForBranchWithURL:URLforCanonicalURL
            andTags:nil
            andChannel:@"read_later"
            andFeature:nil
            andStage:nil
            andAlias:nil];
        [content processURLForBranchWithURL:URLforCanonicalURL
            andTags:nil
            andChannel:@"bookmark"
            andFeature:nil
            andStage:nil
            andAlias:nil];
    }
    
    return content;
}

+ (instancetype)contentFromImages:(NSArray *)images caption:(NSString *)caption {
    OSKShareableContent *content = [[OSKShareableContent alloc] init];
    
    // CONTENT TITLE
    
    if (caption.length) {
        [content setTitle:caption];
    }
    else if (images.count) {
        NSString *title = (images.count == 1) ? @"Share Image" : @"Share Images";
        [content setTitle:title];
    }
    else {
        [content setTitle:@"Share"];
    }
    
    // FACEBOOK
    
    OSKFacebookContentItem *facebook = [[OSKFacebookContentItem alloc] init];
    facebook.text = caption;
    facebook.images = images;
    content.facebookItem = facebook;
    
    // MICROBLOG POST
    
    OSKMicroblogPostContentItem *microblogPost = [[OSKMicroblogPostContentItem alloc] init];
    microblogPost.text = caption;
    microblogPost.images = images;
    content.microblogPostItem = microblogPost;
    
    // COPY TO PASTEBOARD
    
    if (images.count) {
        OSKCopyToPasteboardContentItem *copyImageToPasteboard = [[OSKCopyToPasteboardContentItem alloc] init];
        NSString *name = (images.count == 1) ? @"Copy Image" : @"Copy Images";
        [copyImageToPasteboard setAlternateActivityName:name];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            copyImageToPasteboard.alternateActivityIcon = [UIImage imageNamed:@"osk-copyIcon-purple-76.png"];
        } else {
            copyImageToPasteboard.alternateActivityIcon = [UIImage imageNamed:@"osk-copyIcon-purple-60.png"];
        }
        [copyImageToPasteboard setImages:images];
        content.pasteboardItem = copyImageToPasteboard;
    }
    
    if (caption.length) {
        OSKCopyToPasteboardContentItem *copyTextToPasteboard = [[OSKCopyToPasteboardContentItem alloc] init];
        [copyTextToPasteboard setAlternateActivityName:@"Copy Text"];
        copyTextToPasteboard.text = caption;
        if (content.pasteboardItem) {
            content.additionalItems = @[copyTextToPasteboard];
        } else {
            content.pasteboardItem = copyTextToPasteboard;
        }
    }
    
    // EMAIL
    
    OSKEmailContentItem *emailItem = [[OSKEmailContentItem alloc] init];
    emailItem.body = caption;
    emailItem.attachments = images.copy;
    content.emailItem = emailItem;
    
    // SMS
    
    OSKSMSContentItem *smsItem = [[OSKSMSContentItem alloc] init];
    smsItem.body = caption;
    smsItem.attachments = images;
    content.smsItem = smsItem;
    
    // PHOTOSHARING
	
	OSKPhotoSharingContentItem *photoItem = [[OSKPhotoSharingContentItem alloc] init];
	photoItem.images = images;
	photoItem.caption = caption;
	content.photoSharingItem = photoItem;
    
    // TODO LIST
    
    // No to-do lists accept images at this time.
    
    // AIRDROP
    
    if (images.count) {
        OSKAirDropContentItem *airDrop = [[OSKAirDropContentItem alloc] init];
        airDrop.items = images;
        content.airDropItem = airDrop;
    }
    
    return content;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setTitle:@"Share"];
    }
    return self;
}

@end
