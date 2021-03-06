//
//  KAuth.h
//  WebviewTest
//
//  Created by Timothy Liu on 4/4/14.
//  Copyright (c) 2015 Kloudless, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SafariServices/SafariServices.h>
#import "KClient.h"

extern NSString *kSDKVersion;

extern NSString *kAPIHost;
extern NSString *kWebHost;
extern NSString *kAPIVersion;

extern NSString *kProtocolHTTPS;

@interface KAuth : NSObject {
    NSString *_appId;
    NSMutableDictionary *_keysStore;
    NSMutableDictionary *_keychainItem;
}

- (SFSafariViewController *)authFromController:(UIViewController *)rootController;
- (SFSafariViewController *)authFromController:(UIViewController *)rootController andAuthUrl:(NSString *)authUrl;
- (SFSafariViewController *)authFromController:(UIViewController *)rootController andAuthUrl:(NSString *)authUrl andAuthParams:(NSDictionary *)params;

+ (KAuth *)sharedAuth;
+ (void)setSharedAuth:(KAuth *)auth;

- (id)initWithAppId:(NSString *)appId;
- (BOOL)isLinked; // Auth must be linked before creating any KClient objects
- (void)setToken:(NSString *)token forAccountId:(NSString *)accountId;
- (BOOL) handleOpenURL:(NSURL *)url withPrefix:(NSString *)prefix;
- (NSString *)tokenForAccountId:(NSString *)accountId;

- (void)unlinkAll;
- (void)unlinkAccountId:(NSString *)accountId;

@property (strong, nonatomic) NSMutableDictionary * keychainItem;
@property (nonatomic, readonly) NSArray *accountIds;
@property (nonatomic, readonly) BOOL secure;

@end
