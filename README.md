iOS SDK for the Kloudless API
=====================================

iOS SDK for the [Kloudless API](https://developers.kloudless.com)

## Getting Started Using the KloudlessSDK for iOS:

Requirements:

1. You need the 4.2 version of the iPhone SDK. The version of your Xcode should
   be at least 3.2.5.
2. You need to have registered as a Kloudless app at
   https://developers.kloudless.com. You should have an App key and API Key.

Note: The SDK is designed to work with iOS versions 4.0 and above.


## Building and using the example app:
1. Open the project file in examples/KTester/KTester.xcodeproj
2. Fill in the values for appId in
   KTesterAppDelegate.m application:didFinishLaunchingWithOptions:
3. Make sure the build is set to Simulator. This setting should be near
   the top-left corner of Xcode.
4. Build and Run app
5. Once running, you can test functionalities of the API without getting errors.

If you cannot run the app without getting errors, please contact us at
support@kloudless.com.


## Adding the KloudlessSDK.Framework to a Third-Party Application

> View a sample project that shows the result of following these steps in the `examples/`
> directory.

This is the easy part (and what your third-party developers will have to do). Simply drag the
.framework to your application's project, ensuring that it's being added to the necessary targets.

![](https://github.com/jverkoey/iOS-Framework/raw/master/gfx/thirdparty.png)

Import your framework header and you're kickin' ass.

```obj-c
#import <KloudlessSDK/KloudlessSDK.h>
```

### Resources

If you're distributing resources with your framework then you will also send the .bundle file to the
developers. The developer will then drag the .bundle file into their application and ensure that
it's added to the application target.

## Documentation

See the [Kloudless API Docs](https://developers.kloudless.com/docs) for the official reference.
You can obtain an API Key at the [Developer Portal](https://developers.kloudless.com).

Here is a basic example of the most important methods in the Kloudless iOS SDK.

Step 1. Modifying the delegate with your App Id.
```obj-c
// Insert your App ID from your Kloudless App Details.
NSString *appId = @"YOUR APP ID HERE";

// The KAuth object keeps track of all accounts and account keys per application.
KAuth* auth = [[KAuth alloc] initWithAppId:appId];

// KAuthDelegate methods allow you to handle re-authentication
auth.delegate = self;

// Use a class instance for referencing the KAuth object.
[KAuth setSharedAuth:auth];
```

Step 2. Authenticate users and create a client.
```obj-c
// Start the authentication from a View Controller
[[KAuth sharedAuth] authFromController: self];

...
// This will be called when the authentication finishes
// TODO: move to a delegate method
- (void)viewDidAppear(BOOL)animated
{
// The account will be linked with all accounts and keys.
// Grab an accountId and accountKey.
KAuth *auth = [KAuth sharedAuth];
if ([auth isLinked]) {
    NSString *accountId = [[auth accountIds] objectAtIndex:0];
    NSString *accountKey = [auth keyForAccountId:accountId];

    // Create a client for a specific account key
    KClient *accountClient = [[KClient alloc] initWithKey:accountKey accountId:accountId];
    // Set the client delegate to handle selectors
    client.delegate = self;
}
```

Step 3. Make a few API requests from the client. *Note: Kloudless SDK uses callback selectors.
```obj-c
// See all the files/folders in an account by passing in the folderId
NSString *folderId = @"root";
[client getFolderContents:folderId];

...
// This is the callback selector called from the KClient Delegate on success.
- (void)restClient:(KClient*)client getFolderContentsLoaded:(NSDictionary *)folderContents
{
    NSLog(@"Folder Contents: %@", folderContents);
}

// This is the callback selector called from the KClient Delegate on failure.
- (void)restClient:(KClient*)client getFolderContentsFailedWithError:(NSError*)error
{
    NSLog(@"Error: %@", error);
}
```

## UPDATES
* 2014/09 - updated SDK with new methods, modified auth controller
* 2014/04 - added initial Example project

## TODO

* More Tests!
* Refactor multiple account id / key management
* Adding additional examples
