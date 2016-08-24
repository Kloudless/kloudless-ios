//
//  KAuth.m
//  WebviewTest
//
//  Created by Timothy Liu on 4/4/14.
//  Copyright (c) 2015 Kloudless, Inc. All rights reserved.
//

#import "KAuth.h"
#import "KAuthController.h"
#import <Security/Security.h>

NSString *kSDKVersion = @"0.0.1"; // TODO: parameterize from build system

NSString *kAPIHost = @"api.kloudless.com";
NSString *kWebHost = @"www.kloudless.com";
NSString *kAPIVersion = @"0";

NSString *kProtocolHTTPS = @"https";

static KAuth *_sharedAuth = nil;
static BOOL _secure = true;
static NSString *_server = @"kldl.es";

@interface KAuth ()

- (void)saveCredentials;
- (void)setKey:(NSString *)key forAccountId:(NSString *)accountId;

@end

@implementation KAuth

@synthesize secure = _secure;
@synthesize keychainItem = _keychainItem;

+ (KAuth *)sharedAuth {
    return _sharedAuth;
}

+ (void)setSharedAuth:(KAuth *) auth {
    if (auth == _sharedAuth) return;
    _sharedAuth = auth;
}

+ (void)setSecure:(BOOL) secure {
    _secure = secure;
}

- (id)initWithAppId:(NSString *)appId
{
    if ((self = [super init])) {
        _appId = appId;
        _keysStore = [NSMutableDictionary new];
        [self loadCredentials];
    }
    return self;
}

- (void)setKey:(NSString *)key forAccountId:(NSString *)accountId
{
    [_keysStore setObject:key forKey:accountId];
    [self saveCredentials];
}

- (BOOL)isLinked {
    return [_keysStore count] != 0;
}

- (void)unlinkAll {
    [_keysStore removeAllObjects];
    [self saveCredentials];
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

- (void)createEmptyKeychainItem{

    //Let's create an empty mutable dictionary:
    _keychainItem = [NSMutableDictionary dictionary];

    //Populate it with the data and the attributes we want to use.

    _keychainItem[(__bridge id)kSecClass] = (__bridge id)kSecClassInternetPassword; // We specify what kind of keychain item this is.
    _keychainItem[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleWhenUnlocked; // This item can only be accessed when the user unlocks the device.

    _keychainItem[(__bridge id)kSecAttrServer] = _server;
    _keychainItem[(__bridge id)kSecAttrAccount] = _appId;

    _keychainItem[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
    _keychainItem[(__bridge id)kSecReturnAttributes] = (__bridge id)kCFBooleanTrue;
}


- (void)loadCredentials {
    if (_secure) {

        [self createEmptyKeychainItem];

        CFDictionaryRef result = nil;
        OSStatus sts = SecItemCopyMatching((__bridge CFDictionaryRef)_keychainItem, (CFTypeRef *)&result);
        NSLog(@"Error Code: %d", (int)sts);

        if (sts == noErr) {
            NSDictionary *resultDict = (__bridge_transfer NSDictionary *)result;
            NSData *keysData = resultDict[(__bridge id)kSecValueData];
            [_keysStore addEntriesFromDictionary:(NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:keysData]];
        }
    } else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *defaultStore = [defaults objectForKey:@"KAuthStore"];
        if (defaultStore && [defaultStore count] > 0) {
            [_keysStore addEntriesFromDictionary:defaultStore];
        }
    }
}

- (void)saveCredentials {
    if (_secure) {

        [self createEmptyKeychainItem];

        NSData *keysData = [NSKeyedArchiver archivedDataWithRootObject:_keysStore];

        //Check if this keychain item already exists.
        if(SecItemCopyMatching((__bridge CFDictionaryRef)_keychainItem, NULL) == noErr) {
            NSMutableDictionary *attributesToUpdate = [NSMutableDictionary dictionary];
            attributesToUpdate[(__bridge id)kSecValueData] = keysData;

            _keychainItem[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanFalse;
            _keychainItem[(__bridge id)kSecReturnAttributes] = (__bridge id)kCFBooleanFalse;

            OSStatus sts = SecItemUpdate((__bridge CFDictionaryRef)_keychainItem, (__bridge CFDictionaryRef)attributesToUpdate);
            NSLog(@"Error Code: %d", (int)sts);
        } else {
            _keychainItem[(__bridge id)kSecValueData] = keysData;

            OSStatus sts = SecItemAdd((__bridge CFDictionaryRef)_keychainItem, NULL);
            NSLog(@"Error Code: %d", (int)sts);
        }
    } else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:_keysStore forKey:@"KAuthStore"];
        [defaults synchronize];
    }
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
- (KAuthController *)authFromController:(UIViewController *)rootController
{
    return [self authFromController:rootController andAuthUrl:nil];
}

- (KAuthController *)authFromController:(UIViewController *)rootController andAuthUrl:(NSString *)authUrl
{
    return [self authFromController:rootController andAuthUrl:authUrl andAuthParams:nil];
}

- (KAuthController *)authFromController:(UIViewController *)rootController andAuthUrl:(NSString *)authUrl andAuthParams:(NSDictionary *)params
{
    NSString *appId = _appId;
    // initializing authURL
    if (!authUrl || [authUrl isEqualToString:@""]) {
        authUrl = [NSString stringWithFormat:@"%@://%@/v%@/services/?app_id=%@&referrer=mobile&retrieve_account_key=true",
           kProtocolHTTPS, kAPIVersion, kAPIHost, appId];
    }

    // adding query params
    if (params) {
        NSMutableString *queryString = [NSMutableString string];
        // doesn't have query parameters
        if ([authUrl rangeOfString:@"?"].length == 0) {
            [queryString appendString:@"?"];
        } else {
            [queryString appendString:@"&"];
        }
        NSMutableArray *queryComponents = [NSMutableArray array];
        for (NSString *key in params) {
            [queryComponents addObject:[NSString stringWithFormat:@"%@=%@", [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], [[params objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        }
        [queryString appendString:[queryComponents componentsJoinedByString:@"&"]];
        authUrl = [NSString stringWithFormat:@"%@%@", authUrl, queryString];
    }

    NSLog(@"Auth URL: %@", authUrl);
    KAuthController *connectController = [[KAuthController alloc] initWithUrl:[NSURL URLWithString:authUrl] fromController:rootController auth:self];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:connectController];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        connectController.modalPresentationStyle = UIModalPresentationFormSheet;
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
    }

    [rootController presentViewController:navController animated:YES completion:nil];
    return connectController;
}

@end
