//
//  KDownloadOperation.m
//  KloudlessSDK
//
//  Created by Timothy Liu on 1/9/15.
//  Copyright (c) 2015 Kloudless, Inc. All rights reserved.
//

#import "KDownloadOperation.h"

@implementation KDownloadOperation

@synthesize error = error_, data = data_;
@synthesize connectionURLRequest = connectionURLRequest_;
@synthesize stream = stream_;
@synthesize fileURL = fileURL_;
#pragma mark -
#pragma mark Initialization & Memory Management

- (id)initWithURLRequest:(NSURLRequest *)urlRequest
{
    
    if( (self = [super init]) ) {
        NSError *error;
        NSURL *directoryURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]] isDirectory:YES];
        [[NSFileManager defaultManager] createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:&error];
        fileURL_ = [directoryURL URLByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
        
        connectionURLRequest_ = [urlRequest copy];
        stream_ = [NSOutputStream outputStreamToFileAtPath:[fileURL_ absoluteString] append:NO];
        [stream_ open];
        totalBytes = 0;
    }
    return self;
}

- (void)dealloc
{
    if( connection_ ) {
        [connection_ cancel];
        connection_ = nil;
    }
    connectionURLRequest_ = nil;

    stream_ = nil;
    
    data_ = nil;
    
    error_ = nil;
    
    totalBytes = 0;
}

#pragma mark -
#pragma mark Start & Utility Methods

// This method is just for convenience. It cancels the URL connection if it
// still exists and finishes up the operation.
- (void)done
{
    if( connection_ ) {
        [connection_ cancel];
        connection_ = nil;
        [stream_ close];
    }
    
    // Alert anyone that we are finished
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    executing_ = NO;
    finished_  = YES;
    [self didChangeValueForKey:@"isFinished"];
    [self didChangeValueForKey:@"isExecuting"];

    if ([delegate respondsToSelector:@selector(operation:didWriteData:totalBytesWritten:expectedTotalBytes:)]) {
        [delegate operation:self didWriteData:0 totalBytesWritten:totalBytes expectedTotalBytes:totalBytes];
    }
}

- (void)canceled {
    // Code for being cancelled
    error_ = [[NSError alloc] initWithDomain:@"KDownloadOperation"
                                        code:123
                                    userInfo:nil];
    
    [self done];
}

- (void)start
{
    // Ensure that this operation starts on the main thread
    if (![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(start)
                               withObject:nil waitUntilDone:NO];
        return;
    }
    
    // Ensure that the operation should exute
    if( finished_ || [self isCancelled] ) { [self done]; return; }
    
    // From this point on, the operation is officially executing--remember, isExecuting
    // needs to be KVO compliant!
    [self willChangeValueForKey:@"isExecuting"];
    executing_ = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    // Create the NSURLConnection--this could have been done in init, but we delayed
    // until no in case the operation was never enqueued or was cancelled before starting
    connection_ = [[NSURLConnection alloc] initWithRequest:connectionURLRequest_
                                                  delegate:self];
}

#pragma mark -
#pragma mark Overrides

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return executing_;
}

- (BOOL)isFinished
{
    return finished_;
}

#pragma mark -
#pragma mark Delegate Methods for NSURLConnection

// The connection failed
- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    // Check if the operation has been cancelled
    if([self isCancelled]) {
        [self canceled];
        return;
    }
    else {
        data_ = nil;
        [self done];
    }
}

// The connection received more data
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Check if the operation has been cancelled
    if([self isCancelled]) {
        [self canceled];
        return;
    }
    
//    [data_ appendData:data];
    
    NSUInteger length = [data length];
    totalBytes += length;
    [stream_ write:[data bytes] maxLength:length];

    if ([delegate respondsToSelector:@selector(operation:didWriteData:totalBytesWritten:expectedTotalBytes:)]) {
        [delegate operation:self didWriteData:length totalBytesWritten:totalBytes expectedTotalBytes:0];
    }
}

// Initial response
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // Check if the operation has been cancelled
    if([self isCancelled]) {
        [self canceled];
        return;
    }
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    NSInteger statusCode = [httpResponse statusCode];
    if( statusCode == 200 ) {
        NSUInteger contentSize = [httpResponse expectedContentLength] > 0 ? [httpResponse expectedContentLength] : 0;
        data_ = [[NSMutableData alloc] initWithCapacity:contentSize];
    } else {

        NSString* statusError  = [NSString stringWithFormat:NSLocalizedString(@"HTTP Error: %ld", nil), statusCode];
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:statusError forKey:NSLocalizedDescriptionKey];
        error_ = [[NSError alloc] initWithDomain:@"KDownloadOperation"
                                            code:statusCode
                                        userInfo:userInfo];
        [self done];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Check if the operation has been cancelled
    if([self isCancelled]) {
        [self canceled];
        return;
    }
    else {
        [self done];
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

@end
