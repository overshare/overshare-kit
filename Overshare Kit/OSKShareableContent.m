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

// --- Branch ---

- (void)initiateBranchWithURL:(NSURL *)url {
    // Arrays of all channels
    // Channels that have a url or link attribute
    self.channelsToProcessToBranch = [@[
                                       @"facebook",
                                       @"browser",
                                       @"read_later",
                                       @"bookmark",
                                       @"microblog_twitter",
                                       @"email",
                                       @"sms",
                                       @"todo",
                                       @"text_editor",
                                       @"airdrop"
                                       ] mutableCopy];
    
    // URL to process for each channel
    self.urlToProcessToBranch = [url absoluteString];
    
    // begin processing URLs for Branch
    [self processURLsForBranch];
}

- (void)processURLsForBranch {
    
    // Sinleton Branch instance
    Branch *branch = [Branch getInstance];
    
    // Tracking tags
    NSLog(@"Tags: %@", self.branchTags);
    
    // Weak block reference to self
    __weak OSKShareableContent *weakContent = self;
    
    NSString *channel = [self.channelsToProcessToBranch firstObject];
    
    // Content items that take a single URL as an argument
    // Create Branch Short URL for each channel
    [branch getShortURLWithParams:self.branchParams
        andTags:self.branchTags
        andChannel:channel
        andFeature:self.branchFeature
        andStage:self.branchStage
        andCallback:^(NSString *url, NSError *error) {
            __strong OSKShareableContent *strongContent = weakContent;
            
            if(!error) {
                NSString *channel = [strongContent.channelsToProcessToBranch firstObject];
                
                if([channel isEqualToString:@"facebook"]) {
                    strongContent.facebookItem.link = [NSURL URLWithString:url];
                    NSLog(@"Facebook: %@", strongContent.facebookItem.link);
                } else if ([channel isEqualToString:@"browser"]) {
                    strongContent.webBrowserItem.url = [NSURL URLWithString:url];
                    NSLog(@"Browser: %@", strongContent.webBrowserItem.url);
                } else if ([channel isEqualToString:@"read_later"]) {
                    strongContent.readLaterItem.url = [NSURL URLWithString:url];
                    NSLog(@"Read Later: %@", strongContent.readLaterItem.url);
                } else if ([channel isEqualToString:@"bookmark"]) {
                    strongContent.linkBookmarkItem.url = [NSURL URLWithString:url];
                    NSLog(@"Bookmark: %@", strongContent.linkBookmarkItem.url);
                } else if ([channel isEqualToString:@"microblog_twitter"]) {
                    strongContent.microblogPostItem.text = [self branchifiedStringWithURL:url andOriginalString:strongContent.microblogPostItem.text];
                    NSLog(@"Twitter / Microblog: %@", strongContent.microblogPostItem.text);
                } else if ([channel isEqualToString:@"email"]) {
                    strongContent.emailItem.body = [self branchifiedStringWithURL:url andOriginalString:strongContent.emailItem.body];
                    NSLog(@"Email: %@", strongContent.emailItem.body);
                } else if ([channel isEqualToString:@"sms"]) {
                    strongContent.smsItem.body = [self branchifiedStringWithURL:url andOriginalString:strongContent.smsItem.body];
                    NSLog(@"SMS: %@", strongContent.smsItem.body);
                } else if ([channel isEqualToString:@"todo"]) {
                    strongContent.toDoListItem.notes = [ self branchifiedStringWithURL:url andOriginalString:strongContent.toDoListItem.notes];
                    NSLog(@"Todo: %@", strongContent.toDoListItem.notes);
                } else if ([channel isEqualToString:@"text_editor"]) {
                    strongContent.textEditingItem.text = [self branchifiedStringWithURL:url andOriginalString:strongContent.textEditingItem.text];
                    NSLog(@"Text editor: %@", strongContent.textEditingItem.text);
                } else if ([channel isEqualToString:@"airdrop"]) {
                    NSMutableArray *airdropItems = [strongContent.airDropItem.items mutableCopy];
                    for (int i = 0; i < [airdropItems count]; i++) {
                        if ([airdropItems[i] isKindOfClass:[NSString class]]) {
                            airdropItems[i] =
                            [self branchifiedStringWithURL:url
                                         andOriginalString:airdropItems[i]];
                            NSLog(@"AirDrop: %@", airdropItems[i]);
                        }
                    }
                    strongContent.airDropItem.items = airdropItems;
                }
            }
            
            // Next channel
            [strongContent.channelsToProcessToBranch removeObjectAtIndex:0];
            if (strongContent.channelsToProcessToBranch.count > 0) {
                NSLog(@"\n--------------------------------------\n");
                [strongContent processURLsForBranch];
            }
    }];
}

// Processes strings of content, and replaces the URL at the end with the Branch URL provided
- (NSString *)branchifiedStringWithURL:(NSString *)branchURL andOriginalString:(NSString *)string {
    // Identifies all links in a string
    NSTextCheckingResult *urlCheckingResult = [self identifyAllUrlsAndReplaceInString:string];
    
    // Remove the original URL from the end of the string
    NSString *truncatedString = [string stringByReplacingCharactersInRange:urlCheckingResult.range withString:@""];
    
    // Append the original string with the Branch URL and return
    return [truncatedString stringByAppendingString:branchURL];
}

// identifies all links in a string
- (NSTextCheckingResult *)identifyAllUrlsAndReplaceInString:(NSString *)string {
    // Find all URLs in a string
    NSDataDetector *detect = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:nil];
    NSMutableArray *allURLs = [[detect matchesInString:string options:0 range:NSMakeRange(0, [string length])] mutableCopy];
    
    //return the URL checking result at the end of the string
    return [allURLs lastObject];
}

// --- End Branch ---

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
    
    // Process all content for Branch URLs
    if (url) {
        [content initiateBranchWithURL:url];
    }
    
    return content;
}

+ (instancetype)contentFromMicroblogPost:(NSString *)text
                              authorName:(NSString *)authorName
                            canonicalURL:(NSString *)canonicalURL
                                  images:(NSArray *)images
                      branchTrackingTags:(NSArray *)branchTrackingTags
                            branchParams:(NSDictionary *)branchParams
                             branchStage:(NSString *)branchStage
                           branchFeature:(NSString *)branchFeature
                          branchCampaign:(NSString *)branchCampaign {
    
    OSKShareableContent *content = [[OSKShareableContent alloc] init];
    
    // Branch arguments
    content.branchTags = branchTrackingTags;
    content.branchStage = branchStage;
    content.branchFeature = branchFeature;
    content.branchCampaign = branchCampaign;
    content.branchParams = branchParams;
    
    content.title = [NSString stringWithFormat:@"Post by %@: “%@”", authorName, text];
    
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    
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
    emailItem.subject = [NSString stringWithFormat:@"Link from %@", appName];
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
    
    // Process all content for Branch URLs
    if (URLforCanonicalURL) {
        [content initiateBranchWithURL:URLforCanonicalURL];
    }
    
    return content;
}

// --- Branch ---

/**
 Original class allocation method without Branch arguments
 */
+ (instancetype)contentFromMicroblogPost:(NSString *)text
                              authorName:(NSString *)authorName
                            canonicalURL:(NSString *)canonicalURL
                                  images:(NSArray *)images {
    
    return [OSKShareableContent contentFromMicroblogPost:text authorName:authorName canonicalURL:canonicalURL images:images branchTrackingTags:nil branchParams:nil branchStage:nil branchFeature:nil branchCampaign:nil];
}

/**
 Branch extensions to conveninvce constructors for Microblog posts
 */

// Tracking tags
+ (instancetype)contentFromMicroblogPost:(NSString *)text
                              authorName:(NSString *)authorName
                            canonicalURL:(NSString *)canonicalURL
                                  images:(NSArray *)images
                      branchTrackingTags:(NSArray *)branchTrackingTags {
    
    return [OSKShareableContent contentFromMicroblogPost:text authorName:authorName canonicalURL:canonicalURL images:images branchTrackingTags:branchTrackingTags branchParams:nil branchStage:nil branchFeature:nil branchCampaign:nil];
}

// Tracking tags, Deep link params
+ (instancetype)contentFromMicroblogPost:(NSString *)text
                              authorName:(NSString *)authorName
                            canonicalURL:(NSString *)canonicalURL
                                  images:(NSArray *)images
                      branchTrackingTags:(NSArray *)branchTrackingTags
                            branchParams:(NSDictionary *)branchPrams {
    
    return [OSKShareableContent contentFromMicroblogPost:text authorName:authorName canonicalURL:canonicalURL images:images branchTrackingTags:branchTrackingTags branchParams:branchPrams branchStage:nil branchFeature:nil branchCampaign:nil];
}

//--- End Branch ---

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
