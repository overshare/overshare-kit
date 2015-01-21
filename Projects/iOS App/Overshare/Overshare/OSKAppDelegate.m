//
//  OSKAppDelegate.m
//  Overshare
//
//
//  Copyright (c) 2013 Overshare Kit. All rights reserved.
//

#import <GooglePlus/GooglePlus.h>
#import "OSKAppDelegate.h"

#import "OSKADNLoginManager.h"
#import "PocketAPI.h"

#import "SampleTimelineViewController.h"

// Include Branch, and Branch preference helper
#import "Branch.h"
#import "BNCPreferenceHelper.h"

@implementation OSKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#warning  You must replace this key with your own app's key!
    [[PocketAPI sharedAPI] setConsumerKey:@"19568-eab36ebc89e751893a754475"];
    
#warning You must set your own Branch API key in Overshare-Info.plist as bnc_app_key (String). Find it here: https://dashboard.branch.io/#/settings
    // Initialize Branch SDK
    /*
     http://branch.io
     Branch enables custom downloads for every new user.
     Drive higher conversions and more engagement using deep links that pass data through install and open.
     
     1. Track how many installs/opens come from each shared link.
     2. Calculate viral kFactor
     3. Insight into which share channels are driving the most downloads: Facebook, Twitter, etc.
     4. Insight and analytics on which users are you rbiggest influencers and driving the most downloads.
     5. Embed custom dictionaries that live on through clicking a link - even through the app store - to build a customized experience for each new user and make it really easy to deep link.
     6. Customize links with OG tags to display content in Facebook, Twitter, etc.
     7. Reward new or reffering users! Power the link with referral tracking, reward attribution, and credit balance!
     
     For full documentation, see README.md in https://github.com/BranchMetrics/Branch-iOS-SDK
     */
    
    // Only initiate Branch if API key is defined in plist
    if (![@"bnc_no_value" isEqualToString:[BNCPreferenceHelper getAppKey]]) {
        // A Pointer to the signleton instance of Branch. The first time this is called in the app lifecycle, a Branch instance is synchronously instatiated.
        Branch *branch = [Branch getInstance];
    
#ifdef DEBUG
        // Verbose logs for debugging
        [Branch setDebug];
#endif
    
        // Initiates a Branch session, and registers a callback. If you created a custom link with your own custom dictionary data, you probably want to know when the user session init finishes, so you can check that data. Think of this callback as your "deep link router". If your app opens with some data, you want to route the user depending on the data you passed in. Otherwise, send them to a generic install flow.
        [branch initSessionWithLaunchOptions:launchOptions isReferrable:YES andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
            if (!error) {
                NSLog(@"finished init with params = %@", [params description]);
                
                // example dictionary data
                // NSString *name = [params objectForKey:@"user"];
                // NSString *profileUrl = [params objectForKey:@"profile_pic"];
                // NSString *description = [params objectForKey:@"description"];
            }
        }];
    }
    
    UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self setWindow:window];
    
    SampleTimelineViewController *timeline = [[SampleTimelineViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:timeline];
    [window setRootViewController:navController];
    
    [window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#warning Don't forget to override this method so that Pocket, App.net and Google+ authentication have the opportunity to respond!
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    BOOL success = NO;
    
    if ([[OSKADNLoginManager sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation]) {
        success = YES;
    }
    else if ([[PocketAPI sharedAPI] handleOpenURL:url]){
        success = YES;
    }
    else if ([GPPURLHandler handleURL:url sourceApplication:sourceApplication annotation:annotation]) {
        success = YES;
    }
    // Branch deep link handeler
    // pass the url to the handle deep link call
    // if handleDeepLink returns YES, and you registered a callback in initSessionAndRegisterDeepLinkHandler, the callback will be called with the data associated with the deep link
    else if (![[Branch getInstance] handleDeepLink:url]) {
        success = YES;
        // do other deep link routing for the Facebook SDK, Pinterest SDK, etc
    }
    else {
        // if you handle your own custom url-schemes, do it here
        // success = whatever;
    }
    return success;
}

@end
