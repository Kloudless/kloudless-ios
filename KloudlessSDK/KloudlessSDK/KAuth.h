//
//  KAuth.h
//  WebviewTest
//
//  Created by Timothy Liu on 4/4/14.
//  Copyright (c) 2014 Kloudless, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

extern NSString *kSDKVersion;

extern NSString *kAPIHost;
extern NSString *kWebHost;
extern NSString *kAPIVersion;

extern NSString *kProtocolHTTPS;

@protocol KAuthDelegate;

@interface KAuth : NSObject {
    NSString *_appId;
    NSMutableDictionary *_keysStore;
    id<KAuthDelegate> delegate;
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
@property (nonatomic, retain) id<KAuthDelegate> delegate;

@end