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
#import "OSKManagedAccountStore.h"
#import "NSString+OSKDerp.h"
#import "TMTumblrAuthenticator.h"
#import "TMAPIClient.h"

static NSString * OSKTumblrAuthentication_RedirectURI_Value = @"overshare";

@interface OSKTumblrAuthenticationViewController () <OSKWebViewControllerDelegate>

@property (strong, nonatomic) OSKApplicationCredential *applicationCredential;

@end

@implementation OSKTumblrAuthenticationViewController

@synthesize delegate = _delegate;
@synthesize activity = _activity;

- (instancetype)initWithApplicationCredential:(OSKApplicationCredential *)credential {
    NSURL *url = nil;
    self = [super initWithURL:url];
    if (self) {
        _applicationCredential = credential;
        [self setTitle:@"Tumblr"];
        [self setWebViewControllerDelegate:self];
        [self clearCookiesForBaseURLs:@[@"https://tumblr.com", @"https://www.tumblr.com"]];
        
        // Tumblr API App setup
        [TMAPIClient sharedInstance].OAuthConsumerKey = credential.applicationKey;
        [TMAPIClient sharedInstance].OAuthConsumerSecret = credential.applicationSecret;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[TMAPIClient sharedInstance] authenticate:OSKTumblrAuthentication_RedirectURI_Value webView:self.webView callback:^(NSError *error) {
        if (!error)
        {
            [self createTumblrAccounts];
        } else {
            OSKLog(@"Unable to authenticate to Tumblr, error: %@", error);
            [self.delegate authenticationViewControllerDidCancel:self withActivity:self.activity];
        }
    }];
}

- (void)cancelButtonPressed:(id)sender {
    [self.delegate authenticationViewControllerDidCancel:self withActivity:self.activity];
}

- (void)createTumblrAccounts {
    [[TMAPIClient sharedInstance] userInfo:^(id userInfo, NSError *error) {
        if (!error) {
            NSArray *tumblrBlogs = userInfo[@"user"][@"blogs"];
            if ([tumblrBlogs count] == 0) {
                OSKLog(@"Error, you first need to create a Tumblr blog for your account.");
                return;
            }
            
            NSMutableArray *accounts = [NSMutableArray new];
            for (NSDictionary *blogInfo in tumblrBlogs)
            {
                NSString *accountIdentifier = [OSKManagedAccount generateNewOvershareAccountIdentifier];
                OSKManagedAccountCredential *accountCredential =  [[OSKManagedAccountCredential alloc] initWithOvershareAccountIdentifier:accountIdentifier accountID:blogInfo[@"name"] OauthToken:[TMAPIClient sharedInstance].OAuthToken OauthTokenSecret:[TMAPIClient sharedInstance].OAuthTokenSecret];
                
                OSKManagedAccount *account = [[OSKManagedAccount alloc] initWithOvershareAccountIdentifier:accountIdentifier
                                                                           activityType:[self.activity.class activityType]
                                                                             credential:accountCredential];
                [account setUsername:blogInfo[@"name"]];
                [account setAccountID:blogInfo[@"name"]];
                
                OSKLog(@"%@", blogInfo[@"name"]);
                
                [accounts addObject:account];
            }
            [self.delegate authenticationViewController:self didAuthenticateNewAccounts:accounts withActivity:self.activity];

        } else {
            OSKLog(@"Unable to create account for Tumblr, error fetching user info: %@", error);
        }
    }];
}

- (BOOL)isWebViewFirstResponder
{
    NSString *str = [self.webView stringByEvaluatingJavaScriptFromString:@"document.activeElement.tagName"];
    if ([[str lowercaseString]isEqualToString:@"input"]) {
        return YES;
    }
    return NO;
}

#pragma mark - OSKWebViewControllerDelegate

- (BOOL)webViewController:(OSKWebViewController *)webViewController shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    // Avoid keyboard hiding on UIWebView reload
    // as described here: http://stackoverflow.com/a/22692645/269753
    if ([self isWebViewFirstResponder] &&
        navigationType != UIWebViewNavigationTypeFormSubmitted) {
        return NO;
    }

    BOOL shouldLoad = YES;
    NSString *absoluteString = request.URL.absoluteString;
    
    if ([absoluteString rangeOfString:OSKTumblrAuthentication_RedirectURI_Value].length > 0) {
        shouldLoad = NO;
        
        [[TMTumblrAuthenticator sharedInstance] handleOpenURL:request.URL];
    }
    return shouldLoad;
}

- (void)webViewControllerDidStartLoad:(OSKWebViewController *)webViewController {
    
}

- (void)webViewControllerDidFinishLoad:(OSKWebViewController *)webViewController {
    [self.webView becomeFirstResponder];
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




