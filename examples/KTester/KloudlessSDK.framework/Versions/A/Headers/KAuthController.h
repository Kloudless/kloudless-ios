//
//  KAuthController.h
//  WebviewTest
//
//  Created by Timothy Liu on 4/4/14.
//  Copyright (c) 2015 Kloudless, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KAuth.h"
#import "KClient.h"

@protocol KAuthDelegate;

@interface KAuthController : UIViewController {
    id<KAuthDelegate> delegate;
}

- (id)initWithUrl:(NSURL *)connectUrl fromController:(SFSafariViewController *)rootController auth:(KAuth *)auth;

@property (nonatomic, retain) id<KAuthDelegate> delegate;

@end

@protocol KAuthDelegate

- (void)authenticationFailedWithError:(NSError *)error;
- (void)authenticationSucceeded:(NSDictionary *)data;

@end
