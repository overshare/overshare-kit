//
//  OSKAppDotNetAuthenticationViewController.m
//  Overshare
//
//  Created by Jared Sinclair on 10/11/13.
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//

#import "OSKAppDotNetAuthenticationViewController.h"

#import "OSKActivity.h"
#import "OSKActivitiesManager.h"
#import "OSKAppDotNetUtility.h"
#import "OSKApplicationCredential.h"
#import "OSKLogger.h"
#import "OSKManagedAccount.h"
#import "OSKManagedAccountCredential.h"

static NSString * OSKAppDotNetAuthentication_URL = @"https://account.app.net/oauth/authenticate";
static NSString * OSKAppDotNetAuthentication_ClientIDKey = @"client_id";
static NSString * OSKAppDotNetAuthentication_RedirectURI_Value = @"overshareuriappdotnet";
static NSString * OSKAppDotNetAuthentication_RedirectURI_Key = @"redirect_uri";
static NSString * OSKAppDotNetAuthentication_ResponseTypePair = @"response_type=token";
static NSString * OSKAppDotNetAuthentication_ADNViewPair = @"adnview=appstore";
static NSString * OSKAppDotNetAuthentication_Scopes_Value = @"basic+write_post";
static NSString * OSKAppDotNetAuthentication_Scopes_Key = @"scope";

/*
 https://account.app.net/oauth/authenticate
 ?client_id=[your client ID]
 &response_type=token
 &redirect_uri=[your redirect URI]
 &scope=[scopes separated by spaces]
*/

@interface OSKAppDotNetAuthenticationViewController () <OSKWebViewControllerDelegate>

@property (strong, nonatomic) OSKApplicationCredential *applicationCredential;

@end

@implementation OSKAppDotNetAuthenticationViewController

@synthesize delegate = _delegate;
@synthesize activity = _activity;

+ (NSURL *)authenticationURLWithAppCredential:(OSKApplicationCredential *)credential {
    NSMutableString *string = [[NSMutableString alloc] initWithString:OSKAppDotNetAuthentication_URL];
    [string appendFormat:@"?%@=%@", OSKAppDotNetAuthentication_ClientIDKey, credential.applicationKey];
    [string appendFormat:@"&%@", OSKAppDotNetAuthentication_ResponseTypePair];
    [string appendFormat:@"&%@=%@://", OSKAppDotNetAuthentication_RedirectURI_Key, OSKAppDotNetAuthentication_RedirectURI_Value];
    [string appendFormat:@"&%@=%@", OSKAppDotNetAuthentication_Scopes_Key, OSKAppDotNetAuthentication_Scopes_Value];
    [string appendFormat:@"&%@", OSKAppDotNetAuthentication_ADNViewPair];
    return [NSURL URLWithString:string];
}

- (instancetype)initWithApplicationCredential:(OSKApplicationCredential *)credential {
    NSURL *url = [self.class authenticationURLWithAppCredential:credential];
    self = [super initWithURL:url];
    if (self) {
        _applicationCredential = credential;
        [self setTitle:@"App.net"];
        [self setWebViewControllerDelegate:self];
        [self clearCookiesForBaseURLs:@[@"https://account.app.net", @"https://api.app.net"]];
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

- (BOOL)webViewController:(OSKWebViewController *)webViewController shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    BOOL should = YES;
    NSString *absoluteString = request.URL.absoluteString;
    NSURLComponents *urlComps = [NSURLComponents componentsWithString:absoluteString];
    NSString *scheme = [urlComps scheme];
    if ([scheme rangeOfString:OSKAppDotNetAuthentication_RedirectURI_Value].length > 0) {
        should = NO;
        NSString *fragment = [urlComps fragment];
        NSArray *pair = [fragment componentsSeparatedByString:@"="];
        if (pair.count > 1) {
            NSString *token = [pair objectAtIndex:1];
            [self createUserWithAccessToken:token];
        } else {
            OSKLog(@"Error: unable to parse access token for App Dot Net account.");
        }
    }
    return should;
}

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




