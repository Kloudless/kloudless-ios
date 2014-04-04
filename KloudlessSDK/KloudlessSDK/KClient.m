//
//  KClient.m
//  WebviewTest
//
//  Created by Timothy Liu on 4/3/14.
//  Copyright (c) 2014 Juan Gonzalez. All rights reserved.
//

#import "KClient.h"

@interface KClient ()

- (NSMutableURLRequest *)requestWithHost:(NSString*)host path:(NSString*)path
                             parameters:(NSDictionary*)params;
- (NSMutableURLRequest *)requestWithHost:(NSString*)host path:(NSString*)path
                             parameters:(NSDictionary*)params method:(NSString*)method;

- (void)checkForAuthenticationFailure:(KRequest *)request;

@end

@implementation KClient

NSString *kSDKVersion = @"0.0.1";
NSString *kProtocol = @"http";
NSString *kAPIHost = @"localhost:8002";
NSString *kWebHost = @"localhost:8000";
NSString *kDBDropboxAPIVersion = @"0";

- (id)initWithKey:(NSString *)key
{
    if (!key) {
        return nil;
    }
    
    if ((self = [super init])) {
        _key = key;
        _requests = [[NSMutableSet alloc] init];
    }
    return self;
}

#pragma mark Kloudless API Methods /accounts

- (void)listAccounts
{
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:@"accounts" parameters:nil];
    
    KRequest* request =
    [[KRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidListAccounts:)];
    
    [_requests addObject:request];
}

- (void)requestDidListAccounts:(KRequest*)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:listAccountsFailedWithError:)]) {
            [delegate restClient:self listAccountsFailedWithError:request.error];
        }
    } else {
        NSDictionary *accounts = (NSDictionary *)[request resultJSON];
        if ([delegate respondsToSelector:@selector(restClient:listAccountsLoaded:)]) {
            [delegate restClient:self listAccountsLoaded:accounts];
        }
    }
    
    [_requests removeObject:request];
}

- (void)getAccount:(NSString *)accountId
{
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@", accountId];
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath parameters:nil];
    
    KRequest* request =
    [[KRequest alloc] initWithURLRequest:urlRequest andInformTarget:self
                                selector:@selector(requestDidGetAccount:)];
    
    [_requests addObject:request];
}

- (void)requestDidGetAccount:(KRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:getAccountFailedWithError:)]) {
            [delegate restClient:self getAccountFailedWithError:request.error];
        }
    } else {
        NSDictionary *accountInfo = (NSDictionary *)[request resultJSON];
        if ([delegate respondsToSelector:@selector(restClient:getAccountLoaded:)]) {
            [delegate restClient:self getAccountLoaded:accountInfo];
        }
    }
    
    [_requests removeObject:request];
}

- (void)deleteAccount:(NSString *)accountId
{
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@", accountId];
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath parameters:nil method:@"DELETE"];
    
    KRequest* request =
    [[KRequest alloc] initWithURLRequest:urlRequest andInformTarget:self
                                selector:@selector(requestDidDeleteAccount:)];
    
    [_requests addObject:request];
}

- (void)requestDidDeleteAccount:(KRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:deleteAccountFailedWithError:)]) {
            [delegate restClient:self deleteAccountFailedWithError:request.error];
        }
    } else {
        NSDictionary *response = [NSDictionary dictionaryWithObject:@"true" forKey:@"success"];
        if ([delegate respondsToSelector:@selector(restClient:deleteAccountLoaded:)]) {
            [delegate restClient:self deleteAccountLoaded:response];
        }
    }
    
    [_requests removeObject:request];
}

#pragma mark Kloudless API Methods /accounts/{account_id}/files/{file_id}

- (void)getFile:(NSString *)accountId withFileId:(NSString *)fileId
{
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@/files/%@", accountId, fileId];
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath parameters:nil];
    
    KRequest* request =
    [[KRequest alloc] initWithURLRequest:urlRequest andInformTarget:self
                                selector:@selector(requestDidGetFile:)];
    
    [_requests addObject:request];
}

- (void)requestDidGetFile:(KRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:getFileFailedWithError:)]) {
            [delegate restClient:self getFileFailedWithError:request.error];
        }
    } else {
        NSDictionary *fileInfo = (NSDictionary *)[request resultJSON];
        if ([delegate respondsToSelector:@selector(restClient:getFileLoaded:)]) {
            [delegate restClient:self getFileLoaded:fileInfo];
        }
    }
    
    [_requests removeObject:request];
}

- (void)updateFile:(NSString *)accountId withFileId:(NSString *)fileId andParams:(NSDictionary *)params
{
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@/files/%@", accountId, fileId];
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath parameters:params method:@"PATCH"];
    
    KRequest* request =
    [[KRequest alloc] initWithURLRequest:urlRequest andInformTarget:self
                                selector:@selector(requestDidUpdateFile:)];
    
    [_requests addObject:request];
}

- (void)requestDidUpdateFile:(KRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:updateFileFailedWithError:)]) {
            [delegate restClient:self updateFileFailedWithError:request.error];
        }
    } else {
        NSDictionary *fileInfo = (NSDictionary *)[request resultJSON];
        if ([delegate respondsToSelector:@selector(restClient:updateFileLoaded:)]) {
            [delegate restClient:self updateFileLoaded:fileInfo];
        }
    }
    
    [_requests removeObject:request];
}

- (void)uploadFile:(NSString *)accountId withFileInfo:(NSString *)fileInfo andData:(NSData *)data
{
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@/files", accountId];

    // add file/filename/metadata parameters
    // parse fileInfo into JSON to find name
    
    NSError *error;
    NSDictionary *fileParams = [NSJSONSerialization JSONObjectWithData:[fileInfo dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    NSString *name = [fileParams objectForKey:@"name"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]
                                   initWithObjectsAndKeys:name, @"name", fileInfo, @"metadata", data, @"file", nil];
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath parameters:params method:@"POST"];
    
    KRequest* request =
    [[KRequest alloc] initWithURLRequest:urlRequest andInformTarget:self
                                selector:@selector(requestDidUploadFile:)];
    
    [_requests addObject:request];
}

- (void)requestDidUploadFile:(KRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:uploadFileFailedWithError:)]) {
            [delegate restClient:self uploadFileFailedWithError:request.error];
        }
    } else {
        NSDictionary *fileInfo = (NSDictionary *)[request resultJSON];
        if ([delegate respondsToSelector:@selector(restClient:uploadFileLoaded:)]) {
            [delegate restClient:self uploadFileLoaded:fileInfo];
        }
    }
    
    [_requests removeObject:request];
}

- (void)downloadFile:(NSString *)accountId withFileId:(NSString *)fileId
{
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@/files/%@/contents", accountId, fileId];
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath parameters:nil];
    
    KRequest* request =
    [[KRequest alloc] initWithURLRequest:urlRequest andInformTarget:self
                                selector:@selector(requestDidDownloadFile:)];
    
    [_requests addObject:request];
}

- (void)requestDidDownloadFile:(KRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:downloadFileFailedWithError:)]) {
            [delegate restClient:self downloadFileFailedWithError:request.error];
        }
    } else {
        NSData *fileData = [request resultData];
        if ([delegate respondsToSelector:@selector(restClient:downloadFileLoaded:)]) {
            [delegate restClient:self downloadFileLoaded:fileData];
        }
    }
    
    [_requests removeObject:request];
}

- (void)deleteFile:(NSString *)accountId withFileId:(NSString *)fileId
{
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@/files/%@", accountId, fileId];
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath parameters:nil method:@"DELETE"];
    
    KRequest* request =
    [[KRequest alloc] initWithURLRequest:urlRequest andInformTarget:self
                                selector:@selector(requestDidDeleteFile:)];
    
    [_requests addObject:request];
}

- (void)requestDidDeleteFile:(KRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:deleteFileFailedWithError:)]) {
            [delegate restClient:self deleteFileFailedWithError:request.error];
        }
    } else {
        NSDictionary *response = [NSDictionary dictionaryWithObject:@"true" forKey:@"success"];
        if ([delegate respondsToSelector:@selector(restClient:deleteFileLoaded:)]) {
            [delegate restClient:self deleteFileLoaded:response];
        }
    }
    
    [_requests removeObject:request];
}

#pragma mark Kloudless API Methods /accounts/{account_id}/folders/{folder_id}

- (void)getFolder:(NSString *)accountId withFolderId:(NSString *)folderId
{
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@/folders/%@", accountId, folderId];
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath parameters:nil];
    
    KRequest* request =
    [[KRequest alloc] initWithURLRequest:urlRequest andInformTarget:self
                                selector:@selector(requestDidGetFolder:)];
    
    [_requests addObject:request];
}

- (void)requestDidGetFolder:(KRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:getFileFailedWithError:)]) {
            [delegate restClient:self getFileFailedWithError:request.error];
        }
    } else {
        NSDictionary *fileInfo = (NSDictionary *)[request resultJSON];
        if ([delegate respondsToSelector:@selector(restClient:getFileLoaded:)]) {
            [delegate restClient:self getFileLoaded:fileInfo];
        }
    }
    
    [_requests removeObject:request];
}

- (void)updateFolder:(NSString *)accountId withFolderId:(NSString *)folderId andParams:(NSDictionary *)params
{
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@/folders/%@", accountId, folderId];
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath parameters:params method:@"PATCH"];
    
    KRequest* request =
    [[KRequest alloc] initWithURLRequest:urlRequest andInformTarget:self
                                selector:@selector(requestDidUpdateFolder:)];
    
    [_requests addObject:request];
}

- (void)requestDidUpdateFolder:(KRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:updateFolderFailedWithError:)]) {
            [delegate restClient:self updateFolderFailedWithError:request.error];
        }
    } else {
        NSDictionary *folderInfo = (NSDictionary *)[request resultJSON];
        if ([delegate respondsToSelector:@selector(restClient:updateFolderLoaded:)]) {
            [delegate restClient:self updateFolderLoaded:folderInfo];
        }
    }
    
    [_requests removeObject:request];
}

- (void)createFolder:(NSString *)accountId andParams:(NSDictionary *)params
{
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@/folders", accountId];
    
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath parameters:params method:@"POST"];
    
    KRequest* request =
    [[KRequest alloc] initWithURLRequest:urlRequest andInformTarget:self
                                selector:@selector(requestDidCreateFolder:)];
    
    [_requests addObject:request];
}

- (void)requestDidCreateFolder:(KRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:createFolderFailedWithError:)]) {
            [delegate restClient:self createFolderFailedWithError:request.error];
        }
    } else {
        NSDictionary *folderInfo = (NSDictionary *)[request resultJSON];
        if ([delegate respondsToSelector:@selector(restClient:createFolderLoaded:)]) {
            [delegate restClient:self createFolderLoaded:folderInfo];
        }
    }
    
    [_requests removeObject:request];
}

- (void)getFolderContents:(NSString *)accountId withFolderId:(NSString *)folderId
{
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@/folders/%@/contents", accountId, folderId];
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath parameters:nil];
    
    KRequest* request =
    [[KRequest alloc] initWithURLRequest:urlRequest andInformTarget:self
                                selector:@selector(requestDidGetFolderContents:)];
    
    [_requests addObject:request];
}

- (void)requestDidGetFolderContents:(KRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:getFolderContentsFailedWithError:)]) {
            [delegate restClient:self getFolderContentsFailedWithError:request.error];
        }
    } else {
        NSDictionary *folderContents = (NSDictionary *)[request resultJSON];
        if ([delegate respondsToSelector:@selector(restClient:getFolderContentsLoaded:)]) {
            [delegate restClient:self getFolderContentsLoaded:folderContents];
        }
    }
    
    [_requests removeObject:request];
}

- (void)deleteFolder:(NSString *)accountId withFolderId:(NSString *)folderId
{
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@/folders/%@", accountId, folderId];
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath parameters:nil method:@"DELETE"];
    
    KRequest* request =
    [[KRequest alloc] initWithURLRequest:urlRequest andInformTarget:self
                                selector:@selector(requestDidDeleteFolder:)];
    
    [_requests addObject:request];
}

- (void)requestDidDeleteFolder:(KRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:deleteFolderFailedWithError:)]) {
            [delegate restClient:self deleteFolderFailedWithError:request.error];
        }
    } else {
        NSDictionary *response = [NSDictionary dictionaryWithObject:@"true" forKey:@"success"];
        if ([delegate respondsToSelector:@selector(restClient:deleteFolderLoaded:)]) {
            [delegate restClient:self deleteFolderLoaded:response];
        }
    }
    
    [_requests removeObject:request];
}

#pragma mark Kloudless API Methods /accounts

- (void)listLinks:(NSString *)accountId
{
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@/links", accountId];
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath parameters:nil];
    
    KRequest* request =
    [[KRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidListLinks:)];
    
    [_requests addObject:request];
}

- (void)requestDidListLinks:(KRequest*)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:listLinksFailedWithError:)]) {
            [delegate restClient:self listLinksFailedWithError:request.error];
        }
    } else {
        NSDictionary *links = (NSDictionary *)[request resultJSON];
        if ([delegate respondsToSelector:@selector(restClient:listLinksLoaded:)]) {
            [delegate restClient:self listLinksLoaded:links];
        }
    }
    
    [_requests removeObject:request];
}

- (void)getLink:(NSString *)accountId withLinkId:(NSString *)linkId
{
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@/links/%@", accountId, linkId];
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath parameters:nil];
    
    KRequest* request =
    [[KRequest alloc] initWithURLRequest:urlRequest andInformTarget:self
                                selector:@selector(requestDidGetLink:)];
    
    [_requests addObject:request];
}

- (void)requestDidGetLink:(KRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:getLinkFailedWithError:)]) {
            [delegate restClient:self getLinkFailedWithError:request.error];
        }
    } else {
        NSDictionary *linkInfo = (NSDictionary *)[request resultJSON];
        if ([delegate respondsToSelector:@selector(restClient:getLinkLoaded:)]) {
            [delegate restClient:self getLinkLoaded:linkInfo];
        }
    }
    
    [_requests removeObject:request];
}

- (void)createLink:(NSString *)accountId andParams:(NSDictionary *)params
{
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@/links", accountId];
    
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath parameters:params method:@"POST"];
    
    KRequest* request =
    [[KRequest alloc] initWithURLRequest:urlRequest andInformTarget:self
                                selector:@selector(requestDidCreateLink:)];
    
    [_requests addObject:request];
}

- (void)requestDidCreateLink:(KRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:createLinkFailedWithError:)]) {
            [delegate restClient:self createLinkFailedWithError:request.error];
        }
    } else {
        NSDictionary *linkInfo = (NSDictionary *)[request resultJSON];
        if ([delegate respondsToSelector:@selector(restClient:createLinkLoaded:)]) {
            [delegate restClient:self createLinkLoaded:linkInfo];
        }
    }
    
    [_requests removeObject:request];
}

- (void)deleteLink:(NSString *)accountId withLinkId:(NSString *)linkId
{
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@/links/%@", accountId, linkId];
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath parameters:nil method:@"DELETE"];
    
    KRequest* request =
    [[KRequest alloc] initWithURLRequest:urlRequest andInformTarget:self
                                selector:@selector(requestDidDeleteLink:)];
    
    [_requests addObject:request];
}

- (void)requestDidDeleteLink:(KRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:deleteLinkFailedWithError:)]) {
            [delegate restClient:self deleteLinkFailedWithError:request.error];
        }
    } else {
        NSDictionary *response = [NSDictionary dictionaryWithObject:@"true" forKey:@"success"];
        if ([delegate respondsToSelector:@selector(restClient:deleteLinkLoaded:)]) {
            [delegate restClient:self deleteLinkLoaded:response];
        }
    }
    
    [_requests removeObject:request];
}


#pragma mark private methods

+ (NSString*)escapePath:(NSString*)path {
    CFStringEncoding encoding = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
    NSString *escapedPath =
    (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                          (CFStringRef)path,
                                                                          NULL,
                                                                          (CFStringRef)@":?=,!$&'()*+;[]@#~",
                                                                          encoding));
    
    return escapedPath;
}

- (NSMutableURLRequest*)requestWithHost:(NSString*)host path:(NSString*)path
                             parameters:(NSDictionary*)params {
    
    return [self requestWithHost:host path:path parameters:params method:nil];
}

- (NSMutableURLRequest*)requestWithHost:(NSString*)host path:(NSString*)path
                             parameters:(NSDictionary*)params method:(NSString*)method {
    
    NSString* escapedPath = [KClient escapePath:path];
    NSString* urlString = [NSString stringWithFormat:@"%@://%@/v%@/%@",
                           kProtocol, host, kDBDropboxAPIVersion, escapedPath];
    NSLog(@"urlString: %@", urlString);
    
    NSURL* url = [NSURL URLWithString:urlString];

    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *authorization = [NSString stringWithFormat:@"AccountKey %@", _key];
    
    if (method) {
        [urlRequest setHTTPMethod:method];
    }

    if ([params count] > 0) {
        // no file param key, application/json, not uploading file
        if (![params objectForKey:@"file"]) {
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params
                                                               options: 0
                                                                 error: &error];
            NSString *paramString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [urlRequest setHTTPBody:[paramString dataUsingEncoding:NSUTF8StringEncoding]];
            [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        // if passed in a file parameter, treat as file upload with data, need multipart/form request
        } else {
            NSString *boundary = [[NSUUID UUID] UUIDString];
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];

            NSMutableData *body = [NSMutableData data];
            // grab file and name
            NSString *name = [params objectForKey:@"name"];
            NSData *file = [params objectForKey:@"file"];
            NSString *metadata = [params objectForKey:@"metadata"];
            
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@.jpg\"\r\n", name] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:file];
            
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"metadata\"\r\n\r\n%@",
                               metadata] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [urlRequest setHTTPBody:body];
            [urlRequest setValue:contentType forHTTPHeaderField:@"Content-Type"];
        }
    }
    
    [urlRequest setValue:authorization forHTTPHeaderField:@"Authorization"];
    
    return urlRequest;
}

- (void)checkForAuthenticationFailure:(KRequest *)request {

}

@synthesize delegate;

@end

