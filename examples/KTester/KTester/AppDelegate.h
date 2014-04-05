//
//  AppDelegate.h
//  KTester
//
//  Created by Timothy Liu on 4/5/14.
//  Copyright (c) 2014 Kloudless, Inc. All rights reserved.
//

#import <KloudlessSDK/KloudlessSDK.h>
#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, KAuthDelegate, KNetworkRequestDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
