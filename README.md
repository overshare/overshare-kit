OvershareKit
============

#### A soup-to-nuts sharing library for iOS.

## Table of Contents    

- [Why OvershareKit?](#why-oversharekit)
- [Screenshot](#screenshot)
- [Pull Requests and New Features](#pull-requests-and-new-features)
- [How to Use OvershareKit](#how-to-use-oversharekit)
- [OvershareKit Versus UIActivityViewController](#oversharekit-versus-uiactivityviewcontroller)
- [Architecture](#architecture)
- [Authentication](#authentication)
- [Application-Specific Credentials](#application-specific-credentials)
- [URL Schemes](#url-schemes)
- [Dependencies](#dependencies)
- [In-App Purchases](#in-app-purchases)
- [Branch Setup](#branch-setup)
- [Branch Links](#branch-links-in-osk-content)
- [So Much More](#so-much-more)
- [Contributors](#contributors)
- [Apps Using OvershareKit](#apps-using-oversharekit)
- [Attributions](#attributions)
- [License](#license)

## Why OvershareKit?

Sharing is far too cumbersome to implement on iOS. UIActivityViewController is too limiting, and rolling your own library is too time-consuming. Most devs end up settling for underwhelming sharing options for lack of the time or inclination to make something better.

OvershareKit makes it trivial to add rich sharing options to your iOS apps. In a word, OvershareKit has everything:

- Beautiful share sheets with pixel-perfect, **full-color** icons in a simple layout.

- Lots of tweakable options, including a gorgeous dark mode.

- Built-in integration with iOS Twitter and Facebook accounts.

- Built-in integration with popular third-party services like App.net, Instapaper, and more.

- Built-in integration with Branch.io, enabling custom downloads for every new user.

- Complete multi-account management, including authentication and storing credentials securely in the Keychain.

- Killer text editing views with as-you-type Twitter syntax highlighting, [Riposte](http://riposteapp.net)-style swipe gesture cursor navigation, and automatic smart quotes.

## Screenshot

<img src="https://jaredsinclair-dev.s3.amazonaws.com/web/jaredsinclair.com/overshare.png" width="320"/>

## Pull Requests and New Features

We happily accept any pull request that adds meaningful value for the OvershareKit community. Bug fixes can be submitted on any branch, but significant changes and new features *must* be submitted on the `dev` branch for wider testing and review. Our day-to-day work is done on the dev branch. Watch the `dev` branch for an idea of what’s coming.

OvershareKit also has a public Pivotal Tracker project [available here](https://www.pivotaltracker.com/s/projects/1026256).

## How to Use OvershareKit

OvershareKit is designed to be dead simple for the easy cases, while still being flexible enough to scale up to more complex needs, and without breaking inbetween.

After including OvershareKit in your Xcode project (see the detailed requirements below), the steps to get started couldn't be easier:

1) Create an instance of `OSKShareableContent`, ideally via one of the convenient class-level constructors like `contentFromURL:`

2) Pass that shareable content to the `OSKPresentationManager` via one of the `presentActivitySheetForContent:` methods.

3) There is no step 3. 


## OvershareKit Versus UIActivityViewController

We are frequently asked why someone would use OvershareKit instead of `UIActivityViewController` (UIAVC) and `UIActivity`. UIAVC is great for apps that know they’ll never have a need for any of the following:

1. Never need to integrate with more than one or two third party services.
2. Never need to tweak the UI for the activity sheet and sharing screens.
3. Never care to provide separate, media-specific content for each sharing type (email versus SMS, etc.)
4. Never need to have multiple items such as a Copy Text versus a Copy Link in the same sheet.
5. Don't mind that all non-system-provided activities get stuck with boring monochromatic icons.

Many apps can't fit comfortably within those restrictions, which is why we made OvershareKit. 

The most important difference between UIAVC and OvershareKit is in how content is structured. UIAVC uses unstructured arrays of content (which contain one or more of a grab-bag of objects, usually strings, images and URLs). UIAVC lets each UIActivity decide which of these objects, if any, it will act upon and how. The shortcoming of this API design is that activities don't know anything about the context in which a sharing session is taking place. For example, the formatting for an email message generated from an Instagram post should look very different from an email generated from an RSS article. But with UIAVC, there's no easy way to communicate that context. Most crucially, it is impossible to do this using UIAVC without providing substitutes for the system-provided mail activities. 

Activities should not be given that much responsibility over content. The content should be ready to consume *before* it is handed to an activity. Furthermore, the content should be formatted in a manner that is appropriate to each type of activity.

This is why OvershareKit uses an instance of `OSKShareableContent` that bristles with many flavors of `OSKShareableContentItem`. This API design allows the part of your app that has knowledge of context to prepare all the various types of `OSKShareableContentItems` before handing it off to an OvershareKit sharing session. This results in a more satisfying sharing experience for the user, and less overall hassle for the developer. 


## Architecture

OvershareKit has lots of classes, but here are the main players:

- **OSKPresentationManager:** This singleton instance manages the user-interface layers of OvershareKit. It's the class you access to present activity sheets (share sheets). It's also how you can customize the UI of OvershareKit, via four delegates, each for different customization purposes: a style delegate, a color delegate, a localization delegate, and a view controller delegate. If you already like the default look & feel of OvershareKit, you probably won't need to implement any of these delegates.

- **OSKActivitiesManager:** This singleton instance handles model level logic around sharing activities. Unless you're writing your own view controllers, you probably won't need to access this class much (except to provide application-specific third-party credentials, see Authentication section below).

- **OSKActivity:** This semi-abstract base class is the heart and soul of OvershareKit. All sharing activities inherit from it. OvershareKit comes with lots of built-in subclasses of OSKActivity. You can easily write your own subclasses, too. Activities provide important information about how they perform their tasks via lots of required methods.

- **OSKShareableContent:** is the highest-level OvershareKit model object for passing around shareable content. It's sole purpose is to bristle with subclasses of `OSKShareableContentItem`, making it easy to pass many flavors of content in a single method argument.

- **OSKShareableContentItem:** represents the user's data in a structured, readable, portable way. It is an abstract base class with many subclasses. Because each kind of `OSKActivity` requires different bits of data and metadata, there is an `OSKShareableContentItem` subclass for each conceivable type of activity. Think of `OSKShareableContentItem` like `UINavigationItem` or `UITabBarItem`. Navigation controllers and tab bar controllers use those items to keep title and toolbar item changes in sync with child view controller changes. It’s a convenient paradigm that is useful for our purposes, too. `OSKShareableContent` (see above) has many `OSKShareableContentItem` subclass properties like `emailItem`, `microblogPostItem`, `webBrowserItem`, etc.

- **OSKManagedAccount:** Third-party accounts (like App.net accounts) are represented in OvershareKit by instances of OSKManagedAccount. OvershareKit manages the creation, authentication, and storage of these accounts. This class is not intended to be subclassed. OvershareKit does *not* create managed accounts for services that are managed at the system level (i.e. Twitter or Facebook).

- **OSKManagedAccountStore:** This singleton instance manages storing and organizing all the OSKManagedAccounts for activities tied to third-party services.

- **OSKSystemAccountStore:** This singleton instance manages access to system-level accounts like Twitter and Facebook.


## Authentication

For the most part, OvershareKit will handle all aspects of authentication by itself. There are several crucial exceptions to this which every app will need to be configured to handle:

### Application-Specific Credentials

Some third-party services require application-specific credentials in order to authenticate user actions. The sample app that ships with OvershareKit has been configured to use some test app credentials if the compiler flag for `DEBUG` is set to `1`.

**You must not ship OvershareKit's test credentials in a production application. They may be revoked at any time. We will not be responsible for any consequences if that happens. Please see the next several paragraphs for more information on setting up application credentials.** 

You can provide your app's credentials via the `customizationsDelegate` property of `OSKActivitiesManager`. These credentials are represented by instances of `OSKApplicationCredential`.

The list of services currently requiring application credentials are:

- **App.net:** App.net posting requires an application ID. Visit http://developers.app.net for more information. You will need to create a developer-tier account to register your app (currently $99 USD per year). Don't forget: registering your app with App.net may also entitle you to participate in the Developer Incentive Program ($$$). Contact App.net for more information. You will also need to register the default redirect URI for OvershareKit: `http://localhost:8000`. The other app-specific details they require (like a bundle identifier) are unique to your registered application. *Note: if you want your users to also be able to sign in via the App.net Passport application, you'll need to follow App.net's instructions for setting up a custom URL scheme.*

- **Pocket:** Visit http://getpocket.com/developer/ for more information. In addition to registering your app, you'll need to follow their instructions for setting up a custom URL scheme, including downloading the Pocket iOS SDK. *There is no way to sign into Pocket without setting up this URL scheme.*

- **Facebook:** The iOS authentication requirements for Facebook include passing an application ID. Register your app at http://developers.facebook.com/.

- **Readability:** You'll need to obtain an application key and secret by registering your app via a new developer account. Visit http://www.readability.com for more information.

- **Google Plus:** You'll need to obtain an application key by registering your app with Google Plus.

- **Branch:** Branch enables custom downloads for every new user. Visit http://branch.io for more information. You'll need to obtain an API key by registering your app with Branch.

If you have any questions about this setup process, don’t hesitate to [ask].

### URL Schemes

- **App.net Passport:** The App.net Passport app allows users to sign in without having to type their username and password. This option is automatically enabled by OvershareKit whenever the application is installed. You will need to include the [App.net Login SDK](https://github.com/appdotnet/ADNLogin-SDK-iOS) in your project. You'll also need to set up a custom URL scheme according to App.net's instructions in order for this method to function properly. If you don't set up the URL scheme, users will be prompted to sign in via OvershareKit's web view.

- **Pocket:** Pocket authentication requires setting up a custom URL scheme according to their instructions. You'll also need to include the [Pocket-iOS-SDK](https://github.com/Pocket/Pocket-ObjC-SDK) to enable Pocket sign-in.

## Dependencies

OvershareKit is almost entirely a standalone library. All of its categories and classes have been properly namespaced with the `OSK` prefix to avoid collisions.

There are three required external libraries, which are included as git submodules in the Depedencies directory:

- [App.net Login SDK](https://github.com/appdotnet/ADNLogin-SDK-iOS)

- [Pocket-iOS-SDK](https://github.com/Pocket/Pocket-ObjC-SDK)

- [Branch-iOS-SDK](https://github.com/BranchMetrics/Branch-iOS-SDK)

*The Google Plus framework in the Dependencies directory is not a submodule.*


## In-App Purchases

You can optionally configure certain activity types to require in-app purchase. OvershareKit does not handle purchasing or receipt validation, but it does handle the logic around presenting your custom purchasing view controller at the appropriate time. OvershareKit will even badge the activity icons with cute little price tags when they have not yet been purchased. See the header files for `OSKActivitiesManager` and `OSKPurchasingViewController` for more details.

## Branch Setup
Branch.io enables tracking, and personalized downloads for every user of your app through deep links, that pass data **thourgh install and open**. An example use case: Your app has a microblog post the user shares via OvershareKit. Rather than the user sharing the original URL, the Branch integration with OvershareKit automatically converts the original URL into a unique Brach short url for each action. Each short URL auto embeds the sharing channel (facebook, twitter, etc), and extends the OvershareKit Content methods to easily pass in deep link parameters, and tags to track app stage, and specific features.

Ideally, you want to use Branch links any time you have an external link pointing to your app (share, invite, referral, etc) because:

1. The Branch dashboard can tell you where your installs are coming from
2. Branch links are the highest possible converting channel to new downloads and users
3. You can pass shared data across install to give new users a custom welcome or show them the content they expect to see
 
Our linking infrastructure will support anything you want to build. If it doesn't, we'll fix it so that it does: just reach out to [alex@branch.io](mailto:alex@branch.io) with requests.

The original Branch iOS SDK and Documentation can [be found here](https://github.com/BranchMetrics/Branch-iOS-SDK)

1. To get started with the Branch integration in OvershareKit, first signup for a [Branch account](https://dashboard.branch.io/)
2. Add the Branch API key found in the [Settings panel](https://dashboard.branch.io/#/settings) of the dashboard, to your app's plist file, as "bnc_app_key". To do this, open the "Info" tab in your XCode project, and add a key to the "Custom iOS Target Properties."
3. Register a URI scheme in your app's plist file, so your app responds to direct deep links (example: myapp://...). This step is optional, but highly recomended. Full instructions [found here](https://github.com/BranchMetrics/Branch-iOS-SDK#register-a-uri-scheme-direct-deep-linking-optional-but-recommended)
4. **Initialize the Branch SDK**. Branch has a singleton instance that can be refferenced by calling [Branch getInstance]. The first time this is called, a singleton is allocated that can be referrenced throughout the app. To initliaize a Branch session, call [[Branch getInstance] initSessionWithLaunchOptions andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {...}];. There is an example of this in the OvershareKit Sample App. 
5. **Register for deeplinks**. You'll likely want your app to respond to it's customer URI scheme, and handle showing the user the correct content with the data your app is passed via the Branch deep link. To do this, your app delegate should respond to - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation. The url passed in via this method, should be sent to the Branch singleton with the method if [[Branch getInstance] handleDeepLink:url]. There is also an example of this in the OvershareKit sample app.

## Branch Links in OSK Content
Once you've setup the Branch Integration with the steps in the previous section, you're ready to initiate an OvershareKit Content with Branch short URLs! Normally, you call contentFromMicroblogPost or contentFromURL on an OSKShareableContent instance to setup a collection of Content Items for each share channel (Facebook, Twitter, etc). This integration extends those methods to include the Branch parameters: tracking tags, stage, feature, and deep linking & OG params. An example of this can be seen in the OvershareKit Sample app, in SampleTimelineViewController.m starting at line 82.

These  methods will seamlessly generate OSK shareable content items, and attach a Branch Short URL to each content channel AND automatically tag it with "facebook," "bookmark," etc. for each channel! If you do not have the Branch API key set, OSK will behave as it does without Branch.

####All availabe Branch OSK extended methods
(All of these methods also available as contentFromMicroblogPost)

- contentFromURL:(NSURL *)url branchTrackingTags:(NSArray *)branchTrackingTags branchParams:(NSDictionary *)branchParams branchStage:(NSString *)branchStage branchFeature:(NSString *)branchFeature

- contentFromURL:(NSURL *)url branchTrackingTags:(NSArray *)branchTrackingTags

- contentFromURL:(NSURL *)url branchTrackingTags:(NSArray *)branchTrackingTags branchParams:(NSDictionary *)branchPrams

- contentFromURL:(NSURL *)url branchParams:(NSDictionary *)branchPrams

- contentFromURL:(NSURL *)url branchTrackingTags:(NSArray *)branchTrackingTags branchParams:(NSDictionary branchStage:(NSString *)branchStage

- contentFromURL:(NSURL *)url branchTrackingTags:(NSArray *)branchTrackingTags branchStage:(NSString *)branchStage

- contentFromURL:(NSURL *)url branchStage:(NSString *)branchStage

- contentFromURL:(NSURL *)url branchTrackingTags:(NSArray *)branchTrackingTags branchParams:(NSDictionary *)branchParams branchFeature:(NSString *)branchFeature

- contentFromURL:(NSURL *)url branchTrackingTags:(NSArray *)branchTrackingTags branchStage:(NSString *)branchStage branchFeature:(NSString *)branchFeature

- contentFromURL:(NSURL *)url branchParams:(NSDictionary *)branchParams branchStage:(NSString *)branchStage branchFeature:(NSString *)branchFeature

- contentFromURL:(NSURL *)url branchParams:(NSDictionary *)branchParams branchFeature:(NSString *)branchFeature

- contentFromURL:(NSURL *)url branchStage:(NSString *)branchStage branchFeature:(NSString *)branchFeature

- contentFromURL:(NSURL *)url branchTrackingTags:(NSArray *)branchTrackingTags branchFeature:(NSString *)branchFeature

- contentFromURL:(NSURL *)url branchFeature:(NSString *)branchFeature

## So Much More

There’s a ton of stuff to work with in OvershareKit. All of the major and many of the minor classes have been documented with [appledoc](http://gentlebytes.com/appledoc/) syntax. More documentation is coming. If you have questions, please reach out to us.

## Contributors

<table><tr><td width="50%">
<p><a href="https://twitter.com/jaredsinclair" target="_blank"><img src="http://jaredsinclair.com/img/pixel-jared.png" alt="Jared Sinclair" width="128" height="128"></a></p>

<p><strong>Jared Sinclair</strong></p>

<p>Primary Author and API Design<br/>
Twitter: <a href="https://twitter.com/jaredsinclair">@jaredsinclair</a><br/>
App.net: <a href="https://alpha.app.net/jaredsinclair">@jaredsinclair</a></p>

<p>Jared is an independent iOS app designer and developer. He makes apps like <a href="http://jaredsinclair.com/unread/">Unread an RSS Reader</a> and <a href="http://riposteapp.net">Riposte for App.net</a>.</p>

</td><td width="50%">
<p><a href="https://twitter.com/justin" target="_blank"><img src="http://www.jaredsinclair.com/img/justin-williams.jpeg" alt="Justin Williams" width="128" height="128"></a></p>

<p><strong>Justin Williams</strong></p>

<p>API Design & iOS Account Integration<br/>
Twitter: <a href="https://twitter.com/justin">@justin</a><br/>
App.net: <a href="https://alpha.app.net/justin">@justin</a></p>

<p>Justin is an independent iOS and Mac app developer at <a href="http://www.secondgearsoftware.com">Second Gear</a>. He is a frequent public speaker at tech events.</p>

</td></tr></table>

## Apps Using OvershareKit

*Recent additions are at the top of the list.*

**Cardasee**    
*Modern Quick Notes.*    
[Website](http://cardasee.com)  |  [App Store](https://itunes.apple.com/us/app/cardasee-modern-quick-notes/id870645092?ls=1&mt=8)

**nvNotes**    
*The professional Note-taking App that allows you to focus on writing.*    
[Website](http://www.nvnotes.co.uk)  |  [App Store](https://itunes.apple.com/us/app/nvnotes-note-taking-writing/id700659300?mt=8)

**Unread**    
*An RSS Reader*    
By Jared Sinclair    
[Website](http://jaredsinclair.com/unread/)  |  [App Store](https://itunes.apple.com/us/app/unread-an-rss-reader/id754143884?ls=1&mt=8)

**Redd**    
*A Reddit client for iOS 7.*    
By Craig Merchant    
Website  |  [App Store](https://itunes.apple.com/us/app/redd-reddit-client/id777208009?mt=8&uo=4&at=10l6nh&ct=ms_inline)

**Sunlit**    
*Shared photos and stories, built with App.net.*    
By Manton Reece and Jonathan Hays    
[Website](http://sunlit.io)  |  [App Store](https://itunes.apple.com/app/sunlit/id690924901?mt=8)

**App.net - Broadcast With Push**    
*Never miss important news again with App.net Broadcast.*    
By App.net    
[Website](http://alpha.app.net)  |  [App Store](https://itunes.apple.com/us/app/app.net-passport/id534414475)

## Attributions

OvershareKit contains portions of other open-source code, either verbatim or (more commonly) with some pruning and refactoring. The following projects were immensely helpful:

- **DerpKit:** By Steve Streza. *Objective-C categories and subclasses of things that should be in Foundation and other frameworks* [On GitHub](https://github.com/stevestreza/DerpKit)

- **AFNetworking:** By Mattt Thompson. *A delightful iOS and OS X networking framework.* [On GitHub](https://github.com/AFNetworking/AFNetworking)

- **UIColor-Utilities:** By Erica Sadun. *Helpful utilities for UIColor for iPhone.* [On GitHub](https://github.com/erica/uicolor-utilities)

- **TwitterText:** By Twitter. *An Objective-C implementation of Twitter's text processing library* [On GitHub](https://github.com/twitter/twitter-text-objc)

- **Gist 1102091:** By Ole Zorn. *Creating arbitrarily-colored icons from a black-with-alpha master image (iOS).* [On GitHub](https://gist.github.com/omz/1102091)

- **UIDevice-Hardware:** By InderKumarRathmore. *This category helps to check the hardware version[s] of [iOS devices].* [On GitHub](https://github.com/InderKumarRathore/UIDevice-Hardware)

- **RPSTPasswordManagementAppService:** By Riposte LLC. *An iOS utility class for launching 1Password via URL schemes.* [On GitHub](https://github.com/Riposte/RPSTPasswordManagementAppService)


## License

The MIT License (MIT)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[ask]: http://twitter.com/oversharekit





