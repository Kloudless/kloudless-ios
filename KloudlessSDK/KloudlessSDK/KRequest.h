//
//  KRequest.h
//  WebviewTest
//
//  Created by Timothy Liu on 4/3/14.
//  Copyright (c) 2014 Juan Gonzalez. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KNetworkRequestDelegate;

@interface KRequest : NSObject {
    NSURLRequest* _request;
    NSHTTPURLResponse* _response;

    id target;
    SEL selector;
    NSURLConnection* urlConnection;

    NSMutableData* resultData;
    NSError* error;
}

+ (void)setNetworkRequestDelegate:(id<KNetworkRequestDelegate>)delegate;
- (id)initWithURLRequest:(NSURLRequest*)request andInformTarget:(id)target selector:(SEL)selector;
- (void)cancel;

@property (nonatomic, readonly) NSError* error;
@property (nonatomic, readonly) NSData* resultData;
@property (nonatomic, readonly) NSObject* resultJSON;

@end

@protocol KNetworkRequestDelegate

- (void)networkRequestStarted;
- (void)networkRequestStopped;

@end
