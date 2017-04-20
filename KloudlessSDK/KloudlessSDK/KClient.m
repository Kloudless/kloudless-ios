//
//  KClient.m
//  WebviewTest
//
//  Created by Timothy Liu on 4/3/14.
//  Copyright (c) 2015 Kloudless, Inc. All rights reserved.
//

#import "KAuth.h"
#import "KClient.h"

@interface KClient ()

- (NSMutableURLRequest *)requestWithHost:(NSString*)host
                                    path:(NSString*)path
                              bodyParameters:(NSDictionary*)bodyParams;

- (NSMutableURLRequest *)requestWithHost:(NSString*)host
                                    path:(NSString*)path
                          bodyParameters:(NSDictionary*)bodyParams
                                  method:(NSString*)method;

- (NSMutableURLRequest *)requestWithHost:(NSString*)host path:(NSString*)path
                          bodyParameters:(NSDictionary*)bodyParams
                                  method:(NSString*)method
                         queryParameters:(NSDictionary*)queryParams;

- (void)checkForAuthenticationFailure:(KRequest *)request;

@end

@implementation KClient

/**
 Initializes the Kloudless Client with Account Id and Bearer Token.  A developer can also trivially keep track clients based
 on the Kloudless Auth object that stores different account ids and tokens.
 @param NSString Account Id
 @param NSString Bearer Token
 @returns Kloudless Client
 @exception
 */
- (id)initWithId:(NSString *)accountId andToken:(NSString *)token
{
    if (!token || !accountId) {
        return nil;
    }
    
    if ((self = [super init])) {
        _token = token;
        _accountId = accountId;
        _requests = [[NSMutableSet alloc] init];
        _opQueue = [NSOperationQueue new];
        _opConnections = 8;
        [_opQueue setMaxConcurrentOperationCount:_opConnections];
    }
    return self;
}

- (NSString*)verifyToken:(NSString *) token
{
    _token = token;
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:@"oauth/token" bodyParameters:nil method:@"GET" queryParameters:nil];

    NSURLResponse* response = nil;
    NSError* error = nil;
    NSError* e = nil;
    NSData* data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    
    NSJSONSerialization *serialJSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    
    NSDictionary *tokenData = (NSDictionary *) serialJSON;
    NSString *accountId = [NSString stringWithFormat:@"%@", [tokenData objectForKey:@"account_id"]];
    return accountId;
}


#pragma mark Kloudless API Methods /accounts
/**
 Makes a Kloudless API request for account metadata of all accounts associated.  Since the iOS SDK uses Account Key authentication,
 only information for that account is available.

 urlParams may include:
    - active: boolean
    - page_size: number
    - page: number
 
 Responder: requestDidListAccounts
 @param NSDictionary of url parameters
 @returns NSDictionary accounts in @selector(listAccountsLoaded) of the form
    - total: total number of objects
    - count: number of objects on the page
    - page: page number
    - accounts: list of account objects (metadata)
 @exception
 */
- (void)listAccounts:(NSDictionary *)queryParams
{
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:@"accounts" bodyParameters:nil method:@"GET" queryParameters:queryParams];
    
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

/**
 Makes a Kloudless API request for account information specific to this account.  After authentication,
 the rest client should have the account id and account key set.
 @param NSDictionary queryParams
    - active: true or false
 @returns NSDictionary accountInfo in @selector(getAccountLoaded)
 @exception
 */
- (void)getAccount:(NSDictionary *)queryParams
{
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@", _accountId];
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath bodyParameters:nil method:@"GET" queryParameters:queryParams];
    
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

/**
 Makes a Kloudless API request to update the account information.  Typically, this involves updating Kloudless'
 knowledge of tokens if you refresh them or obtain new tokens for the account. Returns new account metadata.
 @param NSDictionary bodyParams
    - active
    - account
    - service
    - token
    - token_secret
    - refresh_token
    - token_expiry
    - refresh_token_expiry
 @returns NSDictionary accountInfo in @selector(updateAccountLoaded)
 @exception
 */
- (void)updateAccount:(NSDictionary *)bodyParams {
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@", _accountId];
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath bodyParameters:bodyParams method:@"PATCH"];

    KRequest* request =
    [[KRequest alloc] initWithURLRequest:urlRequest andInformTarget:self
                                selector:@selector(requestDidGetAccount:)];

    [_requests addObject:request];
}

- (void)requestDidUpdatAccount:(KRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:updateAccountFailedWithError:)]) {
            [delegate restClient:self updateAccountFailedWithError:request.error];
        }
    } else {
        NSDictionary *accountInfo = (NSDictionary *)[request resultJSON];
        if ([delegate respondsToSelector:@selector(restClient:updateAccountLoaded:)]) {
            [delegate restClient:self updateAccountLoaded:accountInfo];
        }
    }
    
    [_requests removeObject:request];
}

/**
 Makes a Kloudless API request to delete the account associated with the current account id and key.

 TODO: clear account id and key, ask for reauthentication
 @param
 @returns
 @exception
 */
- (void)deleteAccount
{
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@", _accountId];
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath bodyParameters:nil method:@"DELETE"];
    
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

/**
 Makes a Kloudless API request to search across accounts.  Since the iOS SDK uses Account Key authentication,
 the search is performed on the current account id.
 @param NSString search query (required)
 @param NSDictionary queryParams are additional query parameters
    - page_size
    - page
 @returns NSDictionary searchInfo in @selector(searchAccountLoaded)
 @exception
 */
- (void)searchAccount:(NSString *)query queryParameters:(NSDictionary *)queryParams
{
    NSMutableDictionary *newQueryParams = [NSMutableDictionary dictionary];
    [newQueryParams setObject:query forKey:@"query"];
    [newQueryParams addEntriesFromDictionary:queryParams];

    NSString *urlPath = [NSString stringWithFormat:@"accounts/storage/%@/search", _accountId];
    NSURLRequest* urlRequest =
        [self requestWithHost:kAPIHost path:urlPath bodyParameters:nil method:@"GET" queryParameters:queryParams];
    
    KRequest* request =
    [[KRequest alloc] initWithURLRequest:urlRequest andInformTarget:self selector:@selector(requestDidAccountSearch:)];
    
    [_requests addObject:request];
}


- (void)requestDidAccountSearch:(KRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:searchAccountFailedWithError:)]) {
            [delegate restClient:self searchAccountFailedWithError:request.error];
        }
    } else {
        NSDictionary *searchInfo = (NSDictionary *)[request resultJSON];
        if ([delegate respondsToSelector:@selector(restClient:searchAccountLoaded:)]) {
            [delegate restClient:self searchAccountLoaded:searchInfo];
        }
    }
}

#pragma mark Kloudless API Methods /accounts/{account_id}/files/{file_id}

/**
 Makes a Kloudless API Request for file metadata given a file id.  The fileInfo Dictionary contains:
    - id
    - name
    - size
    - type
    - created
    - modified
    - account id
    - parent
        - id
        - name
    - mime_type
 @param NSString file id
 @returns NSDictionary of file metadata in @selector(getFileLoaded)
 @exception
 */
- (void)getFile:(NSString *)fileId
{
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@/storage/files/%@", _accountId, fileId];
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath bodyParameters:nil];
    
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

/**
 Makes a Kloudless API Request to rename or move a file. Parameters to be sent in the body can include:
    - name (new name)
    - account (new account location)
    - parent_id (new parent location)
 @param NSDictionary bodyParams
 @returns NSDictionary of new file metadata in @selector(updateFileLoaded)
 @exception
 */
- (void)updateFile:(NSString *)fileId bodyParameters:(NSDictionary *)bodyParams
{
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@/storage/files/%@", _accountId, fileId];
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath bodyParameters:bodyParams method:@"PATCH"];
    
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

/**
 Makes a Kloudless API Request to upload a file to this specific account with file metadata. fileInfo is a JSON string containing:
    - name
    - parent_id
 @param fileInfo (metadata)
 @param data (file contents)
 @param queryParams
    - overwrite: true or false whether to overwrite an existing file
 @returns NSDictionary of new file metadata in @selector(uploadFileLoaded)
 @exception
 */
- (void)uploadFileData:(NSString *)fileInfo andData:(NSData *)data queryParameters:(NSDictionary *)queryParams
{
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@/storage/files", _accountId];
   
    NSError *error;
    NSDictionary *fileParams = [NSJSONSerialization JSONObjectWithData:[fileInfo dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    NSString *name = [fileParams objectForKey:@"name"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]
                                   initWithObjectsAndKeys:name, @"name", fileInfo, @"metadata", data, @"file", nil];
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath bodyParameters:params method:@"POST" queryParameters:queryParams];
    
    KRequest* request =
    [[KRequest alloc] initWithURLRequest:urlRequest andInformTarget:self
                                selector:@selector(requestDidUploadFile:)];
    
    [_requests addObject:request];
}

- (void)requestDidUploadFile:(KRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:uploadFileDataFailedWithError:)]) {
            [delegate restClient:self uploadFileDataFailedWithError:request.error];
        }
    } else {
        NSDictionary *fileInfo = (NSDictionary *)[request resultJSON];
        if ([delegate respondsToSelector:@selector(restClient:uploadFileDataLoaded:)]) {
            [delegate restClient:self uploadFileDataLoaded:fileInfo];
        }
    }
    
    [_requests removeObject:request];
}

/**
 Makes a Kloudless API Request to update file data for a specific file.
 @param fileId (the file identifier)
 @param data (file contents)
 @returns NSDictionary of new file metadata in @selector(uploadFileLoaded)
 @exception
 */
- (void)updateFileData:(NSString *)fileId andData:(NSData *)data
{
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@/storage/files/%@", _accountId, fileId];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]
                                   initWithObjectsAndKeys:data, @"file", nil];
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath bodyParameters:params method:@"PUT"];
    
    KRequest* request =
    [[KRequest alloc] initWithURLRequest:urlRequest andInformTarget:self
                                selector:@selector(requestDidUploadFile:)];
    
    [_requests addObject:request];
}

- (void)requestDidUpdateFileData:(KRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:updateFileDataFailedWithError:)]) {
            [delegate restClient:self updateFileDataFailedWithError:request.error];
        }
    } else {
        NSDictionary *fileInfo = (NSDictionary *)[request resultJSON];
        if ([delegate respondsToSelector:@selector(restClient:updateFileDataLoaded:)]) {
            [delegate restClient:self updateFileDataLoaded:fileInfo];
        }
    }
    
    [_requests removeObject:request];
}

/**
 Makes a Kloudless API Request to download a file.
 @param fileId (file id string)
 @returns NSData of file in @selector(downloadFileLoaded)
 @exception
 */
- (void)downloadFile:(NSString *)fileId
{
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@/storage/files/%@/contents", _accountId, fileId];
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath bodyParameters:nil];
    
    KRequest* request =
    [[KRequest alloc] initWithURLRequest:urlRequest andInformTarget:self
                                selector:@selector(requestDidDownloadFile:)];
    [_requests addObject:request];

}

- (KDownloadOperation *)downloadFileOperation:(NSString *)fileId
{
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@/storage/files/%@/contents", _accountId, fileId];
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath bodyParameters:nil];
    
    KDownloadOperation *operation = [[KDownloadOperation alloc] initWithURLRequest:urlRequest];
    [operation addObserver:self forKeyPath:@"isFinished" options:NSKeyValueObservingOptionNew context:NULL];
    [operation addObserver:self forKeyPath:@"isExecuting" options:NSKeyValueObservingOptionNew context:NULL];
    [_opQueue addOperation:operation]; // operation starts as soon as its added

    return operation;
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

/**
 TODO: copy file
 */

/**
 Makes a Kloudless API Request to delete a file.
 @param fileId (file id string)
 @returns a success or failed response
 @exception
 */
- (void)deleteFile:(NSString *)fileId
{
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@/storage/files/%@", _accountId, fileId];
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath bodyParameters:nil method:@"DELETE"];
    
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

/**
 Makes a Kloudless API request to return recently modified files.  Since the iOS SDK uses Account Key authentication,
 the search is performed on the current account id.
 @param NSDictionary queryParams
    - page_size: number
    - page: number
 @returns NSData of file in @selector(recentFilesLoaded)
 @exception
 */
- (void)getRecentFiles:(NSDictionary *)queryParams
{
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@/storage/recent", _accountId];
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath bodyParameters:nil method:@"GET" queryParameters:queryParams];
    
    KRequest* request =
    [[KRequest alloc] initWithURLRequest:urlRequest andInformTarget:self
                                selector:@selector(requestDidRecentFiles:)];
    
    [_requests addObject:request];
}

- (void)requestDidRecentFiles:(KRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:recentFilesFailedWithError:)]) {
            [delegate restClient:self recentFilesFailedWithError:request.error];
        }
    } else {
        NSDictionary *recentInfo = (NSDictionary *)[request resultJSON];
        if ([delegate respondsToSelector:@selector(restClient:recentFilesLoaded:)]) {
            [delegate restClient:self recentFilesLoaded:recentInfo];
        }
    }
    
    [_requests removeObject:request];
}

#pragma mark Kloudless API Methods /accounts/{account_id}/folders/{folder_id}

/**
 Makes a Kloudless API Request for folder metadata given a folder id.  The folderInfo Dictionary contains:
     - id
     - name
     - size
     - type
     - created
     - modified
     - account id
     - parent
        - id
        - name
     - mime_type
 @param NSString file id
 @returns NSDictionary of file metadata in @selector(getFileLoaded)
 @exception
 */
- (void)getFolder:(NSString *)folderId
{
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@/storage/folders/%@", _accountId, folderId];
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath bodyParameters:nil];
    
    KRequest* request =
    [[KRequest alloc] initWithURLRequest:urlRequest andInformTarget:self
                                selector:@selector(requestDidGetFolder:)];
    
    [_requests addObject:request];
}

- (void)requestDidGetFolder:(KRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:getFolderFailedWithError:)]) {
            [delegate restClient:self getFolderFailedWithError:request.error];
        }
    } else {
        NSDictionary *folderInfo = (NSDictionary *)[request resultJSON];
        if ([delegate respondsToSelector:@selector(restClient:getFolderLoaded:)]) {
            [delegate restClient:self getFolderLoaded:folderInfo];
        }
    }
    
    [_requests removeObject:request];
}

/**
 Makes a Kloudless API Request to rename or move a folder. Parameters can include:
    - name (new name)
    - parent_id (new parent location)
 @param NSDictionary parameters
 @returns NSDictionary of new folder metadata in @selector(updateFolderLoaded)
 @exception
 */
- (void)updateFolder:(NSString *)folderId bodyParameters:(NSDictionary *)bodyParams
{
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@/storage/folders/%@", _accountId, folderId];
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath bodyParameters:bodyParams method:@"PATCH"];
    
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

/**
 Makes a Kloudless API Request to create a folder.
 
 Body Parameters can include:
    - parent_id
    - name
 
 Query Parameters can include:
    - conflict_if_exists: if true, an existing folder with the same name will result in an error
 
 @param NSDictionary bodyParams
 @param NSDictionary queryParams
 @returns NSDictionary folderInfo metadata of the new folder created.
 @exception
 */
- (void)createFolder:(NSDictionary *)bodyParams queryParameters:(NSDictionary *)queryParams
{
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@/storage/folders", _accountId];
    
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath bodyParameters:bodyParams method:@"POST" queryParameters:queryParams];
    
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

/**
 Makes a Kloudless API Request to retrieve the contents of a specific folder.
 @param NSString folderId
 @param NSDictionary queryParams
    - page
    - page_size
 @returns NSDictionary folderContents containing the following information
    - count
    - objects
    - page
    - has_next
 @exception
 */
- (void)getFolderContents:(NSString *)folderId queryParameters:(NSDictionary *)queryParams
{
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@/storage/folders/%@/contents", _accountId, folderId];
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath bodyParameters:nil method:@"GET" queryParameters:queryParams];
    
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

/**
 TODO: copy folder
 */

/**
 Makes a Kloudless API Request to delete a folder
 @param NSString folderId
 @returns success or false of whether the foler was deleted
 @exception
 */
- (void)deleteFolder:(NSString *)folderId
{
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@/storage/folders/%@", _accountId, folderId];
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath bodyParameters:nil method:@"DELETE"];
    
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

#pragma mark Kloudless API Methods /accounts/{account_id}/links

/**
 Makes a Kloudless API Request to list links associated with the account.
 @param queryParams
    - active
    - page_size
    - page
 @returns NSDictionary links in @selector(listLinksLoaded)
    - total (total number of objects)
    - count (number of objects on this page)
    - page (page number)
    - objects (list of link objects)
 @exception
 */
- (void)listLinks:(NSDictionary *)queryParams
{
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@/storage/links", _accountId];
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath bodyParameters:nil method:@"GET" queryParameters:queryParams];
    
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

/**
 Makes a Kloudless API request to retrieve metadata of a link
 @param NSString linkId (identifier)
 @param NSDictionary queryParams
    - active (true or false)
 @returns NSDictionary linkInfo in @selector(getLinkLoaded)
 @exception
 */
- (void)getLink:(NSString *)linkId queryParameters:(NSDictionary *)queryParams;
{
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@/storage/links/%@", _accountId, linkId];
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath bodyParameters:nil method:@"GET" queryParameters:queryParams];
    
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

/**
 Makes a Kloudless API request to update metadata of a link
 @param NSString linkId (linkIdentifier)
 @param NSDictionary bodyParams
     - active (true or false)
     - password (password for the link)
     - expiration (ISO 8601 timestamp specifying when the link expires)
 @returns NSDictionary linkInfo of updated link in @selector(updateLinkLoaded)
 @exception <#throws#>
 */
- (void)updateLink:(NSString *)linkId bodyParameters:(NSDictionary *)bodyParams;
{
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@/storage/links/%@", _accountId, linkId];
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath bodyParameters:bodyParams method:@"PATCH"];
    
    KRequest* request =
    [[KRequest alloc] initWithURLRequest:urlRequest andInformTarget:self
                                selector:@selector(requestDidUpdateLink:)];
    
    [_requests addObject:request];
}

- (void)requestDidUpdateLink:(KRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:updateLinkFailedWithError:)]) {
            [delegate restClient:self updateLinkFailedWithError:request.error];
        }
    } else {
        NSDictionary *linkInfo = (NSDictionary *)[request resultJSON];
        if ([delegate respondsToSelector:@selector(restClient:updateLinkLoaded:)]) {
            [delegate restClient:self updateLinkLoaded:linkInfo];
        }
    }
    
    [_requests removeObject:request];
}

/**
 Makes a Kloudless API Request to create a link
 @param bodyParams
    - file_id (the file identifier you want to create a link for)
    - password (password for the link)
    - expiration (ISO 8601 timestamp specifying when the link expires)
    - direct (boolean specifying whether it's direct or not)
 @returns NSDictionary linkInfo metadata of newly created link in @selector(createLinkLoaded)
 @exception
 */
- (void)createLink:(NSDictionary *)bodyParams
{
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@/storage/links", _accountId];
    
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath bodyParameters:bodyParams method:@"POST"];
    
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

/**
 Makes a Kloudless API Request to delete a link
 @param NSString linkId (identifier)
 @returns success of true or false in @selector(deleteLinkLoaded)
 @exception
 */
- (void)deleteLink:(NSString *)linkId
{
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@/storage/links/%@", _accountId, linkId];
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath bodyParameters:nil method:@"DELETE"];
    
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


/**
 Search the files in the account(s).
 @param NSString query the query string
 */
- (void)search:(NSString *)query {
    NSString *urlPath = [NSString stringWithFormat:@"accounts/%@/storage/search/", _accountId];
    NSDictionary *queryParams = @{@"q": query};
    NSURLRequest* urlRequest =
    [self requestWithHost:kAPIHost path:urlPath bodyParameters:nil method:@"GET" queryParameters:queryParams];
    
    KRequest* request =
    [[KRequest alloc] initWithURLRequest:urlRequest andInformTarget:self
                                selector:@selector(requestDidQuery:)];
    
    [_requests addObject:request];
}

- (void)requestDidQuery:(KRequest *)request
{
    if (request.error) {
        [self checkForAuthenticationFailure:request];
        if ([delegate respondsToSelector:@selector(restClient:searchFailedWithError:)]) {
            [delegate restClient:self searchFailedWithError:request.error];
        }
    } else {
        NSDictionary *queryResult = (NSDictionary *)[request resultJSON];
        if ([delegate respondsToSelector:@selector(restClient:searchLoaded:)]) {
            [delegate restClient:self searchLoaded:queryResult];
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

- (NSMutableURLRequest*)requestWithHost:(NSString*)host
                                   path:(NSString*)path
                         bodyParameters:(NSDictionary*)bodyParams {

    return [self requestWithHost:host path:path bodyParameters:bodyParams method:nil];
}

- (NSMutableURLRequest*)requestWithHost:(NSString*)host
                                   path:(NSString*)path
                         bodyParameters:(NSDictionary*)bodyParams
                                 method:(NSString*)method {

    return [self requestWithHost:host path:path bodyParameters:bodyParams method:method queryParameters:nil ];
    
}

- (NSMutableURLRequest*)requestWithHost:(NSString*)host
                                   path:(NSString*)path
                         bodyParameters:(NSDictionary*)bodyParams
                                 method:(NSString*)method
                        queryParameters:(NSDictionary*)queryParams {
    
    NSString* escapedPath = [KClient escapePath:path];
    NSString* urlString = [NSString stringWithFormat:@"%@://%@/v%@/%@",
                           kProtocolHTTPS, host, kAPIVersion, escapedPath];

    // Adding URL Parameters if there are any
    NSMutableArray *paramParts = [NSMutableArray array];
    for (NSString *queryKey in queryParams) {
        NSString *queryValue = [queryParams objectForKey:queryKey];
        NSString *paramPart = [NSString stringWithFormat:@"%@=%@", [KClient escapePath:queryKey], [KClient escapePath:queryValue]];
        [paramParts addObject:paramPart];
    }
    if ([paramParts count] > 0) {
        urlString = [NSString stringWithFormat:@"%@?%@", urlString, [paramParts componentsJoinedByString:@"&"]];
    }
    
    NSURL* url = [NSURL URLWithString:urlString];
    NSLog(@"urlString: %@", urlString);

    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *authorization = [NSString stringWithFormat:@"Bearer %@", _token];
    
    if (method) {
        [urlRequest setHTTPMethod:method];
    }

    if ([bodyParams count] > 0) {
        // no file param key, application/json, not uploading file
        if (![bodyParams objectForKey:@"file"]) {
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyParams
                                                               options: 0
                                                                 error: &error];
            NSString *paramString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            [urlRequest setHTTPBody:[paramString dataUsingEncoding:NSUTF8StringEncoding]];
            [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        } else if ([bodyParams count] == 1) {
            // only the file parameter, must be a put request
            NSData *file = [bodyParams objectForKey:@"file"];
            NSMutableData *body = [NSMutableData data];
            [body appendData:file];
            [urlRequest setHTTPBody:body];
        } else {
            // if passed in a file parameter, treat as file upload with data, need multipart/form request

            NSString *boundary = [[NSUUID UUID] UUIDString];
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];

            NSMutableData *body = [NSMutableData data];
            // grab file and name
            NSString *name = [bodyParams objectForKey:@"name"];
            NSData *file = [bodyParams objectForKey:@"file"];
            NSString *metadata = [bodyParams objectForKey:@"metadata"];
            
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

#pragma mark -
#pragma KVO Observing
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)operation change:(NSDictionary *)change context:(void *)context {
    NSData *data = nil;
    NSError *error = nil;
    NSOutputStream *stream = nil;
    KDownloadOperation *downloadOperation;

    if ([operation isKindOfClass:[KDownloadOperation class]]) {
        downloadOperation = (KDownloadOperation *)operation;
        if ([operation isFinished]) {
            error = [downloadOperation error];
            data = [downloadOperation data];
            stream = [downloadOperation stream];
        } else if ([operation isExecuting]) {

        }
    }
    if (error != nil) {
        // handle error
        // Notify that we have got an error downloading this data;
        if ([delegate respondsToSelector:@selector(restClient:operation:downloadErrored:)]) {
            [delegate restClient:self operation:downloadOperation downloadErrored:error];
        }
    } else if (data != nil || stream != nil) {
        // Notify that we have got this source data;
        if ([delegate respondsToSelector:@selector(restClient:operation:downloadedFileAtPath:)]) {
            [delegate restClient:self operation:downloadOperation downloadedFileAtPath:[[operation fileURL] absoluteString]];
        }
    }
}

@synthesize delegate;

@end

