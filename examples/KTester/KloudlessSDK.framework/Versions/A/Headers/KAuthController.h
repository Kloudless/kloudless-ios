//
//  KAuthController.h
//  WebviewTest
//
//  Created by Timothy Liu on 4/4/14.
//  Copyright (c) 2014 Kloudless, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KAuth.h"

@interface KAuthController : UIViewController

- (id)initWithUrl:(NSURL *)connectUrl fromController:(UIViewController *)rootController auth:(KAuth *)auth;

@end