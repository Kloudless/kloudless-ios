//
//  KAuth.m
//  WebviewTest
//
//  Created by Timothy Liu on 4/4/14.
//  Copyright (c) 2014 Kloudless, Inc. All rights reserved.
//

#import "KAuth.h"
#import "KAuthController.h"

NSString *kSDKVersion = @"0.0.1"; // TODO: parameterize from build system

NSString *kAPIHost = @"api.kloudless.com";
NSString *kWebHost = @"www.kloudless.com";
NSString *kAPIVersion = @"0";

NSString *kProtocolHTTPS = @"https";

static KAuth *_sharedAuth = nil;

@interface KAuth ()

- (void)saveCredentials;
- (void)setKey:(NSString *)key forAccountId:(NSString *)accountId;

@end

@implementation KAuth

+ (KAuth *)sharedAuth {
    return _sharedAuth;
}

+ (void)setSharedAuth:(KAuth *) auth {
    if (auth == _sharedAuth) return;
    _sharedAuth = auth;
}

- (id)initWithAppId:(NSString *)appId
{
    if ((self = [super init])) {
        _appId = appId;
        _keysStore = [NSMutableDictionary new];
        //TODO: load from default stores, keychain, etc.
        [self saveCredentials];
    }
    return self;
}

@synthesize delegate;

- (void)setKey:(NSString *)key forAccountId:(NSString *)accountId
{
    [_keysStore setObject:key forKey:accountId];
}

- (BOOL)isLinked {
    return [_keysStore count] != 0;
}

- (void)unlinkAll {
    [_keysStore removeAllObjects];
}

- (void)unlinkAccountId:(NSString *)accountId {
    [_keysStore removeObjectForKey:accountId];
    [self saveCredentials];
}

- (NSString *)keyForAccountId:(NSString *)accountId {
    if (!accountId) {
        return nil;
    }
    return [_keysStore objectForKey:accountId];
}

- (NSArray *)accountIds {
    return [_keysStore allKeys];
}

#pragma mark private methods

- (void)saveCredentials {
    // TODO: save
}

/**
 Launches a UIView Controller for authentication given a specific authentication URL
 @param rootController (the controller from which you want to authenticate
 @param authUrl the specific authentication endpoint
     Default:
     NSString *authUrl = @"https://api.kloudless.com/services/?app_id=%@&referrer=mobile&retrieve_account_key=true"
     
     Authenticate a set of services:
     NSString *authUrl = @"https://api.kloudless.com/services/?app_id=%@&referrer=mobile&retrieve_account_key=true&services=box,dropbox"
     
     Skip the user selecting and authenticate a specific service:
     NSString *authUrl = @"https://api.kloudless.com/services/dropbox?app_id=%@&referrer=mobile&retrieve_account_key=true"
     
     Note: Both retrieve_account_key and mobile need to be set to true and mobile respectively to retrieve authentication credentials.
 @returns
 @exception <#throws#>
 */
- (void)authFromController:(UIViewController *)rootController andAuthUrl:(NSString *)authUrl
{
    NSString *appId = _appId;
    if (!authUrl || [authUrl isEqualToString:@""]) {
        authUrl = [NSString stringWithFormat:@"%@://%@/services/?app_id=%@&referrer=mobile&retrieve_account_key=true",
           kProtocolHTTPS, kAPIHost, appId];
    }
    NSLog(@"Auth URL: %@", authUrl);
    UIViewController *connectController = [[KAuthController alloc] initWithUrl:[NSURL URLWithString:authUrl] fromController:rootController auth:self];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:connectController];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        connectController.modalPresentationStyle = UIModalPresentationFormSheet;
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    [rootController presentViewController:navController animated:YES completion:nil];
}

@end
