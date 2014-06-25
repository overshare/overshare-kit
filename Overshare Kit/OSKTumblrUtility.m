//
//  OSKTumblrUtility.m
//  Overshare
//
//
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//

#import "OSKTumblrUtility.h"

#import "OSKLogger.h"
#import "OSKManagedAccountCredential.h"
#import "OSKApplicationCredential.h"
#import "OSKShareableContentItem.h"
#import "TMAPIClient.h"


@implementation OSKTumblrUtility

#pragma mark - Write Post

+ (void)postContentItem:(OSKBlogPostContentItem *)item withCredential:(OSKManagedAccountCredential *)credential appCredential:(OSKApplicationCredential *)appCredential completion:(void(^)(BOOL success, NSError *error))completion {
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    
    NSMutableString *body = [NSMutableString new];
    if (item.textHeader && item.textHeader.length > 0)
    {
        [body appendFormat:@"%@\n", item.textHeader];
    }
    [body appendString:item.text];
    if (item.textFooter && item.textFooter.length > 0)
    {
        [body appendFormat:@"\n%@", item.textFooter];
    }
    
    parameters[@"body"] = body;
    
    if (item.title)
    {
        parameters[@"title"] = item.title;
    }
    
    [TMAPIClient sharedInstance].OAuthConsumerKey = appCredential.applicationKey;
    [TMAPIClient sharedInstance].OAuthConsumerSecret = appCredential.applicationSecret;
    [TMAPIClient sharedInstance].OAuthToken = credential.token;
    [TMAPIClient sharedInstance].OAuthTokenSecret = credential.tokenSecret;
    
    [[TMAPIClient sharedInstance] text:credential.accountID
                            parameters:parameters
                              callback:^(id response, NSError *error) {
         if (error) {
             OSKLog(@"Failed to send Tumblr post: %@", error);
         }
         if (completion) {
             completion(!error, error);
         }
     }];
}

@end


