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
2. Fill in the values for appId and _____________
   KTesterAppDelegate.m application:didFinishLaunchingWithOptions:
3. Make sure the build is set to Simulator. This setting should be near
   the top-left corner of Xcode.
4. Build and Run app
5. Once running, you can test functionalities of the API without getting errors.

If you cannot run the app without getting errors, please contact us at
support@kloudless.com.


## Adding KloudlessSDK to your project:
1. Open your project in Xcode
2. Right-click on your project in the files tab of the left pane and
   select "Add Files to '<PROJECT_NAME>'"
4. Navigate to where you uncompressed the Kloudless SDK and select the
   KloudlessSDK.framework subfolder
5. Select "Copy items into destination group's folder"
6. Press Add button
7. Ensure that you have the Security.framework and QuartzCore.framework are
   added to your project. To do this in Xcode4, select your project file in
   the file explorer, select your target, and select the "Build Phases" sub-tab.
   Under "Link Binary with Libraries", press the + button, select
   Security.framework, and press Add. Repeat for QuartzCore.framework if
   necessary.
8. Build your application. At this point you should have no build failures or
   warnings
