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

@interface KAuth : NSObject {
    NSString *_appId;
    NSMutableDictionary *_keysStore;
}

- (void)authFromController:(UIViewController *)rootController andAuthUrl:(NSString *)authUrl;

+ (KAuth *)sharedAuth;
+ (void)setSharedAuth:(KAuth *)auth;

- (id)initWithAppId:(NSString *)appId;
- (BOOL)isLinked; // Auth must be linked before creating any KClient objects
- (void)setKey:(NSString *)key forAccountId:(NSString *)accountId;
- (NSString *)keyForAccountId:(NSString *)accountId;

- (void)unlinkAll;

@property (nonatomic, readonly) NSArray *accountIds;

@end