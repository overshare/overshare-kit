//
//  OSKTumblrViewController.m
//  Overshare
//
//  Created by Jared Sinclair on 10/11/13.
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//

#import "OSKTumblrAuthenticationViewController.h"

#import "OSKActivity.h"
#import "OSKActivitiesManager.h"
#import "OSKAppDotNetUtility.h"
#import "OSKApplicationCredential.h"
#import "OSKLogger.h"
#import "OSKManagedAccount.h"
#import "OSKManagedAccountCredential.h"
#import "NSString+OSKDerp.h"
#import "TMTumblrAuthenticator.h"

static NSString * OSKAppDotNetAuthentication_RedirectURI_Value = @"http://localhost:8000";

@interface OSKTumblrAuthenticationViewController () <OSKWebViewControllerDelegate>

@property (strong, nonatomic) OSKApplicationCredential *applicationCredential;

@end

@implementation OSKTumblrAuthenticationViewController

@synthesize delegate = _delegate;
@synthesize activity = _activity;

- (instancetype)initWithApplicationCredential:(OSKApplicationCredential *)credential {
    NSURL *url = nil;
//    [self.class authenticationURLWithAppCredential:credential];
    self = [super initWithURL:url];
    if (self) {
        _applicationCredential = credential;
        [self setTitle:@"Tumblr"];
        [self setWebViewControllerDelegate:self];
        //[self clearCookiesForBaseURLs:@[@"https://account.app.net", @"https://api.app.net"]];
        
        // Tumblr API App setup
        [TMTumblrAuthenticator sharedInstance].OAuthConsumerKey = credential.applicationKey;
        [TMTumblrAuthenticator sharedInstance].OAuthConsumerSecret = credential.applicationSecret;
        
        [[TMTumblrAuthenticator sharedInstance] authenticate:@"overshare" webView:self.webView callback:^(NSString *token, NSString *secret, NSError *error) {
            OSKLog(@"%@ %@ %@", token, secret, error);
        }];
    }
    return self;
}

- (void)cancelButtonPressed:(id)sender {
    [self.delegate authenticationViewControllerDidCancel:self withActivity:self.activity];
}

- (void)createUserWithAccessToken:(NSString *)accessToken {
    [OSKAppDotNetUtility createNewUserWithAccessToken:accessToken appCredential:self.applicationCredential completion:^(OSKManagedAccount *account, NSError *error) {
        if (account) {
            [self.delegate authenticationViewController:self didAuthenticateNewAccount:account withActivity:self.activity];
        }
    }];
}

#pragma mark - OSKWebViewControllerDelegate

//- (BOOL)webViewController:(OSKWebViewController *)webViewController shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//    BOOL should = YES;
//    NSString *absoluteString = request.URL.absoluteString;
//    if ([absoluteString rangeOfString:OSKAppDotNetAuthentication_RedirectURI_Value].length > 0) {
//        should = NO;
//        NSURLComponents *urlComps = [NSURLComponents componentsWithString:absoluteString];
//        NSString *fragment = [urlComps fragment];
//        NSArray *pair = [fragment componentsSeparatedByString:@"="];
//        if (pair.count > 1) {
//            NSString *token = [pair objectAtIndex:1];
//            [self createUserWithAccessToken:token];
//        } else {
//            OSKLog(@"Error: unable to parse access token for App Dot Net account.");
//        }
//    }
//    return should;
//}

- (void)webViewControllerDidStartLoad:(OSKWebViewController *)webViewController {
    
}

- (void)webViewControllerDidFinishLoad:(OSKWebViewController *)webViewController {
    
}

- (void)webViewController:(OSKWebViewController *)webViewController didFailLoadWithError:(NSError *)error {
    
}

#pragma mark - Authentication View Controller

- (NSString *)activityType {
 return [self.activity.class activityType];
}
     
- (void)prepareAuthenticationViewForActivity:(OSKActivity<OSKActivity_ManagedAccounts> *)activity delegate:(id<OSKAuthenticationViewControllerDelegate>)delegate {
    _activity = activity;
    [self setDelegate:delegate];
}

@end




