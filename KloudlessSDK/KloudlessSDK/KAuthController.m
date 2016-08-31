//
//  KAuthController.m
//  WebviewTest
//
//  Created by Timothy Liu on 4/4/14.
//  Copyright (c) 2015 Kloudless, Inc. All rights reserved.
//

#import "KAuthController.h"
#import <QuartzCore/QuartzCore.h>
#import "KRequest.h"

extern id<KNetworkRequestDelegate> kNetworkRequestDelegate;

@interface KAuthController () <UIWebViewDelegate, UIAlertViewDelegate>

- (void)loadRequest;
- (void)dismiss;
- (void)dismissAnimated:(BOOL)animated;
- (void)cancelAnimated:(BOOL)animated;

@property (nonatomic, assign) UIViewController *rootController;
@property (nonatomic, retain) KAuth *auth;
@property (nonatomic, retain) UIAlertView *alertView;
@property (nonatomic, assign) BOOL hasLoaded;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) UIWebView *webView;

@end

@implementation KAuthController

@synthesize alertView;

- (void)setAlertView:(UIAlertView *)pAlertView {
    if (pAlertView == alertView) return;
    alertView.delegate = nil;
}

@synthesize rootController;
@synthesize auth;
@synthesize hasLoaded;
@synthesize url;
@synthesize webView;
@synthesize delegate;

- (id)initWithUrl:(NSURL *)connectUrl fromController:(UIViewController *)pRootController auth:(KAuth *)pAuth {
    if ((self = [super init])) {
        self.url = connectUrl;
        self.rootController = pRootController;
        self.auth = pAuth;

        self.title = @"Kloudless";
        self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc]
          initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];

#ifdef __IPHONE_7_0 // Temporary until we can switch to XCode 5 for release.
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
#endif
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.view.backgroundColor = [UIColor colorWithRed:241.0/255 green:249.0/255 blue:255.0/255 alpha:1.0];

    UIActivityIndicatorView *activityIndicator =
    [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.autoresizingMask =
    UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    CGRect frame = activityIndicator.frame;
    frame.origin.x = floorf(self.view.bounds.size.width/2 - frame.size.width/2);
    frame.origin.y = floorf(self.view.bounds.size.height/2 - frame.size.height/2) - 20;
    activityIndicator.frame = frame;
    [activityIndicator startAnimating];
    [self.view addSubview:activityIndicator];

    self.webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    self.webView.delegate = self;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.scalesPageToFit = YES;
    self.webView.hidden = YES;
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    [self.view addSubview:self.webView];

    [self loadRequest];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ||
    [self.rootController shouldAutorotateToInterfaceOrientation:interfaceOrientation]; // Delegate to presenting view.
}

#pragma mark UIWebViewDelegate methods

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [kNetworkRequestDelegate networkRequestStarted];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    [aWebView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout = \"none\";"]; // Disable touch-and-hold action sheet
    [aWebView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect = \"none\";"]; // Disable text selection
    webView.frame = self.view.bounds;

    CATransition* transition = [CATransition animation];
    transition.duration = 0.25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    transition.type = kCATransitionFade;
    [self.view.layer addAnimation:transition forKey:nil];

    webView.hidden = NO;

    hasLoaded = YES;
    [kNetworkRequestDelegate networkRequestStopped];

    NSString *token = [aWebView stringByEvaluatingJavaScriptFromString:@"document.getElementById('access_token').getAttribute('data-value')"];
    
    NSString *accountId;
    if (![token isEqualToString:@""]) {
        KClient *client = [[KClient alloc] initWithId:@"" andToken:token];
        accountId = [client verifyToken:token];
    }
    
    if (![accountId isEqualToString:@""] && ![token isEqualToString:@""]) {
        NSMutableDictionary *accountData = [[NSMutableDictionary alloc] init];
        [accountData setObject:accountId forKey:@"accountId"];
        [accountData setObject:token forKey:@"token"];

        [[KAuth sharedAuth] setToken:token forAccountId:accountId];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        [delegate authenticationSucceeded:accountData];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [kNetworkRequestDelegate networkRequestStopped];

    // ignore "Fame Load Interrupted" errors and cancels
    if (error.code == 102 && [error.domain isEqual:@"WebKitErrorDomain"]) return;
    if (error.code == NSURLErrorCancelled && [error.domain isEqual:NSURLErrorDomain]) return;


    NSString *title = @"";
    NSString *message = @"";

    if ([error.domain isEqual:NSURLErrorDomain] && error.code == NSURLErrorNotConnectedToInternet) {
        title = NSLocalizedString(@"No internet connection", @"");
        message = NSLocalizedString(@"Try again once you have an internet connection.", @"");
    } else if ([error.domain isEqual:NSURLErrorDomain] &&
               (error.code == NSURLErrorTimedOut || error.code == NSURLErrorCannotConnectToHost)) {
        title = NSLocalizedString(@"Internet connection lost", @"");
        message    = NSLocalizedString(@"Please try again.", @"");
    } else {
        title = NSLocalizedString(@"Unknown Error Occurred", @"");
        message = NSLocalizedString(@"There was an error loading Kloudless. Please try again.", @"");
    }

    if (self.hasLoaded) {
        // If it has loaded, it means it's a form submit, so users can cancel/retry on their own
        NSString *okStr = NSLocalizedString(@"OK", nil);

        self.alertView =
        [[UIAlertView alloc]
          initWithTitle:title message:message delegate:nil cancelButtonTitle:okStr otherButtonTitles:nil];
    } else {
        // if the page hasn't loaded, this alert gives the user a way to retry
        NSString *retryStr = NSLocalizedString(@"Retry", @"Retry loading a page that has failed to load");

        self.alertView =
        [[UIAlertView alloc]
          initWithTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
          otherButtonTitles:retryStr, nil];
    }

    [self.alertView show];

    [delegate authenticationFailedWithError:error];
}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    return YES;
}

#pragma mark UIAlertView methods

- (void)alertView:(UIAlertView *)pAlertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != pAlertView.cancelButtonIndex) {
        [self loadRequest];
    } else {
        if ([self.navigationController.viewControllers count] > 1) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self cancel];
        }
    }

    self.alertView = nil;
}

#pragma mark private methods

- (void)loadRequest {
    NSURLRequest *urlRequest =
    [[NSURLRequest alloc] initWithURL:self.url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20];
    [self.webView loadRequest:urlRequest];
}

- (void)cancelAnimated:(BOOL)animated {
    [self dismissAnimated:animated];
}

- (void)cancel {
    [self cancelAnimated:YES];
}

- (void)dismissAnimated:(BOOL)animated {
    if ([webView isLoading]) {
        [webView stopLoading];
    }
    [self.navigationController dismissViewControllerAnimated:animated completion:nil];
}

- (void)dismiss {
    [self dismissAnimated:YES];
}

@end
