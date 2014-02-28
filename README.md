# OvershareKit
============

#### A soup-to-nuts sharing library for iOS.

## Table of Contents    

- [Why OvershareKit?](#why-oversharekit)
- [Screenshot](#screenshot)
- [How to Use OvershareKit](#how-to-use-oversharekit)
- [Architecture](#architecture)
- [Authentication](#authentication)
- [Application-Specific Credentials](#application-specific-credentials)
- [URL Schemes](#url-schemes)
- [Dependencies](#dependencies)
- [In-App Purchases](#in-app-purchases)
- [So Much More](#so-much-more)
- [Contributors](#contributors)
- [Attributions](#attributions)
- [License](#license)

## Why OvershareKit?

Sharing is far too cumbersome to implement on iOS. UIActivityViewController is too limiting, and rolling your own library is too time-consuming. Most devs end up settling for underwhelming sharing options for lack of the time or inclination to make something better.

Enter OvershareKit. 

OvershareKit makes it trivial to add rich sharing options to your iOS apps. In a word, OvershareKit has everything:

- Beautiful share sheets with pixel-perfect, **full-color** icons in a simple layout.

- Lots of tweakable options, including a gorgeous dark mode.

- Built-in integration with iOS Twitter and Facebook accounts.

- Built-in integration with popular third-party services like App.net, Instapaper, and more.

- Complete multi-account management, including authentication and storing credentials securely in the Keychain.

- Killer text editing views with as-you-type Twitter syntax highlighting, [Riposte](http://riposteapp.net)-style swipe gesture cursor navigation, and automatic smart quotes.

## Screenshot

<img src="https://jaredsinclair-dev.s3.amazonaws.com/web/jaredsinclair.com/overshare.png" width="320"/>

## How to Use OvershareKit

OvershareKit is designed to be dead simple for the easy cases, while still being flexible enough to scale up to more complex needs, and without breaking inbetween.

After including OvershareKit in your Xcode project (see the detailed requirements below), the steps to get started couldn't be easier:

1) Create an instance of `OSKShareableContent`, ideally via one of the convenient class-level constructors like `contentFromURL:`

2) Pass that shareable content to the `OSKPresentationManager` via one of the `presentActivitySheetForContent:` methods.

3) There is no step 3. 


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

If you have any questions about this setup process, don’t hesitate to [ask].

### URL Schemes

- **App.net Passport:** The App.net Passport app allows users to sign in without having to type their username and password. This option is automatically enabled by OvershareKit whenever the application is installed. You will need to include the [App.net Login SDK](https://github.com/appdotnet/ADNLogin-SDK-iOS) in your project. You'll also need to set up a custom URL scheme according to App.net's instructions in order for this method to function properly. If you don't set up the URL scheme, users will be prompted to sign in via OvershareKit's web view.

- **Pocket:** Pocket authentication requires setting up a custom URL scheme according to their instructions. You'll also need to include the [Pocket-iOS-SDK](https://github.com/Pocket/Pocket-ObjC-SDK) to enable Pocket sign-in.

## Dependencies

OvershareKit is almost entirely a standalone library. All of its categories and classes have been properly namespaced with the `OSK` prefix to avoid collisions.

There are three required external libraries:

- [App.net Login SDK](https://github.com/appdotnet/ADNLogin-SDK-iOS)

- [Pocket-iOS-SDK](https://github.com/Pocket/Pocket-ObjC-SDK)
- 
- [Google-Plus-iOS-SDK](https://developers.google.com/+/mobile/ios/)


## In-App Purchases

You can optionally configure certain activity types to require in-app purchase. OvershareKit does not handle purchasing or receipt validation, but it does handle the logic around presenting your custom purchasing view controller at the appropriate time. OvershareKit will even badge the activity icons with cute little price tags when they have not yet been purchased. See the header files for `OSKActivitiesManager` and `OSKPurchasingViewController` for more details.

## So Much More

There’s a ton of stuff to work with in OvershareKit. All of the major and many of the minor classes have been documented with [appledoc](http://gentlebytes.com/appledoc/) syntax. More documentation is coming. If you have questions, please reach out to us.

## Contributors

<a href="https://twitter.com/jaredsinclair" target="_blank"><img src="http://jaredsinclair.com/img/pixel-jared.png" alt="Jared Sinclair" width="128" height="128"></a>  
**Jared Sinclair** — Primary Author and API Design  

Twitter: <a href="https://twitter.com/jaredsinclair" target="_blank">@jaredsinclair</a>

App.net: <a href="https://alpha.app.net/jaredsinclair" target="_blank">@jaredsinclair</a>

Jared is an independent iOS app designer and developer. He makes [Riposte](http://riposteapp.net) and [Whisper](http://riposteapp.net/whisper) for App.net along with [Jamin Guy](http://alpha.app.net/jaminguy).

---

<a href="https://twitter.com/justin" target="_blank"><img src="https://pbs.twimg.com/profile_images/378800000306417944/4bd8ad98836bdf9af9767a10217475bb.jpeg" alt="Justin Williams" width="128" height="128"></a>  
**Justin Williams** — API Design & iOS Account Integration 
 
Twitter: <a href="https://twitter.com/justin" target="_blank">@justin</a>

App.net: <a href="https://alpha.app.net/justin" target="_blank">@justin</a>

Justin is an independent iOS and Mac app developer at [Second Gear](http://www.secondgearsoftware.com). He is a frequent public speaker at tech events.

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





