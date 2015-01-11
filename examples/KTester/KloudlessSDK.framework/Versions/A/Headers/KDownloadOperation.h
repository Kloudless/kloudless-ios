//
//  KDownloadOperation.h
//  KloudlessSDK
//
//  Created by Timothy Liu on 1/9/15.
//  Copyright (c) 2015 Kloudless, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol KOperationDelegate;

@interface KDownloadOperation : NSOperation {
    BOOL executing_;
    BOOL finished_;

    NSURLRequest*       connectionURLRequest_;
    NSURLConnection*    connection_;
    NSMutableData*      data_;
    NSOutputStream*     stream_;
    NSURL*              fileURL_;
    
    int totalBytes;
    id<KOperationDelegate> delegate;
}

@property (nonatomic,readonly) NSError *error;
@property (nonatomic,readonly) NSMutableData *data;
@property (nonatomic, readonly) NSOutputStream *stream;
@property (nonatomic, readonly) NSURL *fileURL;
@property (nonatomic,readonly) NSURLRequest *connectionURLRequest;

- (id)initWithURLRequest:(NSURLRequest *)urlRequest;

@end

@protocol KOperationDelegate <NSObject>

- (void)operation:(KDownloadOperation *)operation didWriteData:(long long)bytesWritten
 totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes;

@end