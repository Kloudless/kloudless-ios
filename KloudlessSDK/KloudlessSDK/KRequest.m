//
//  KRequest.m
//  WebviewTest
//
//  Created by Timothy Liu on 4/3/14.
//  Copyright (c) 2014 Kloudless, Inc. All rights reserved.
//

#import "KRequest.h"

id<KNetworkRequestDelegate> kNetworkRequestDelegate = nil;

@interface KRequest ()

- (void)setError:(NSError *)error;

@end

@implementation KRequest

NSString *kDomain = @"kloudless.com";

+ (void)setNetworkRequestDelegate:(id<KNetworkRequestDelegate>)delegate
{
    kNetworkRequestDelegate = delegate;
}

- (id)initWithURLRequest:(NSURLRequest*)aRequest andInformTarget:(id)aTarget selector:(SEL)aSelector
{
    if ((self = [super init])) {
        _request = aRequest;
        target = aTarget;
        selector = aSelector;
        
        urlConnection = [[NSURLConnection alloc] initWithRequest:_request delegate:self];
        [kNetworkRequestDelegate networkRequestStarted];
    }
    return self;
    
}

- (void)cancel {
    [urlConnection cancel];
    target = nil;
    
    [kNetworkRequestDelegate networkRequestStopped];
}

- (NSString *)resultString {
    return [[NSString alloc]
             initWithData:resultData encoding:NSUTF8StringEncoding];
}

- (NSObject *)resultJSON {
    NSError *e;
    NSJSONSerialization *serialJSON = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:&e];
    if (e) {
        NSLog(@"JSON error: %@", e);
        return nil;
    } else {
        return serialJSON;
    }
}

- (NSInteger)statusCode {
    return [_response statusCode];
}

#pragma mark NSURLConnectionData delegate methods

// Handling Incoming Data
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _response = (NSHTTPURLResponse *) response;
    resultData = [NSMutableData new];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [resultData appendData:data];
}

// Receiving Connection Progress
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"statusCode: %d", self.statusCode);

    if (self.statusCode < 200 || self.statusCode > 299) {
        // Errors
        NSMutableDictionary *errorUserInfo = [NSMutableDictionary new];
        NSString *resultString = [self resultString];
        
        NSLog(@"resultString: %@", resultString);
        
        if ([resultString length] > 0) {
          
            NSError *e;
            NSDictionary *json = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:&e];
            
            [errorUserInfo addEntriesFromDictionary:(NSDictionary *)json];
        }
        [self setError:[NSError errorWithDomain:kDomain code:self.statusCode userInfo:errorUserInfo]];
    }

    [target performSelector:selector withObject:self];

    [kNetworkRequestDelegate networkRequestStopped];
}

// Handling Redirects
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
    return request;
}

- (NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request;
{
    return nil;
}

// Overriding Caching Behavior
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}


#pragma mark NSURLConnection delegate methods

// Connection Authentication
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    // Check the authentication method for connection: only SSL/TLS is allowed
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        // TODO: SSL Cert Verification
        // Certificate validation succeeded. Continue the connection
        [challenge.sender
         useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]
         forAuthenticationChallenge:challenge];
        // Certificate validation errored. Stop the connection
        // [[challenge sender] cancelAuthenticationChallenge: challenge];
        
    }
    // Non SSL Cert authentication challenges like OAuth
    [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
}

// Connection Completion
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
}

#pragma mark private methods

- (void)setError:(NSError *)theError {
    if (theError == error) return;
    error = theError;
    
	NSString *errorStr = [error.userInfo objectForKey:@"error"];
	if (!errorStr) {
		errorStr = [error description];
	}
    
    NSLog(@"Kloudless SDK: error making request to %@ - (%ld) %@",
                 [[_request URL] path], (long)error.code, errorStr);
}


@synthesize error;
@synthesize resultData;
@synthesize resultJSON;

@end
