//
//  KAuthController.h
//  WebviewTest
//
//  Created by Timothy Liu on 4/4/14.
//  Copyright (c) 2014 Kloudless, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KAuth.h"

@protocol KAuthDelegate;

@interface KAuthController : UIViewController {
    id<KAuthDelegate> delegate;
}

- (id)initWithUrl:(NSURL *)connectUrl fromController:(UIViewController *)rootController auth:(KAuth *)auth;

@property (nonatomic, retain) id<KAuthDelegate> delegate;

@end

@protocol KAuthDelegate

- (void)authenticationFailedWithError:(NSError *)error;
- (void)authenticationSucceeded:(NSDictionary *)data;

@end
