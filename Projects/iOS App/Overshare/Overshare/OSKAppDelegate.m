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

@implementation OSKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#warning  You must replace this key with your own app's key!
    [[PocketAPI sharedAPI] setConsumerKey:@"19568-eab36ebc89e751893a754475"];
    
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
    else {
        // if you handle your own custom url-schemes, do it here
        // success = whatever;
    }
    return success;
}

@end
