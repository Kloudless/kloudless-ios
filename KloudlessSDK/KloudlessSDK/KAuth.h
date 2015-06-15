//
//  KAuth.h
//  WebviewTest
//
//  Created by Timothy Liu on 4/4/14.
//  Copyright (c) 2015 Kloudless, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *kSDKVersion;

extern NSString *kAPIHost;
extern NSString *kWebHost;
extern NSString *kAPIVersion;

extern NSString *kProtocolHTTPS;

@class KAuthController;

@interface KAuth : NSObject {
    NSString *_appId;
    NSMutableDictionary *_keysStore;
    NSMutableDictionary *_keychainItem;
}

- (KAuthController *)authFromController:(UIViewController *)rootController;
- (KAuthController *)authFromController:(UIViewController *)rootController andAuthUrl:(NSString *)authUrl;
- (KAuthController *)authFromController:(UIViewController *)rootController andAuthUrl:(NSString *)authUrl andAuthParams:(NSDictionary *)params;

+ (KAuth *)sharedAuth;
+ (void)setSharedAuth:(KAuth *)auth;

- (id)initWithAppId:(NSString *)appId;
- (BOOL)isLinked; // Auth must be linked before creating any KClient objects
- (void)setKey:(NSString *)key forAccountId:(NSString *)accountId;
- (NSString *)keyForAccountId:(NSString *)accountId;

- (void)unlinkAll;

@property (strong, nonatomic) NSMutableDictionary * keychainItem;
@property (nonatomic, readonly) NSArray *accountIds;
@property (nonatomic, readonly) BOOL secure;

@end