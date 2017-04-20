//
//  KClient.h
//  WebviewTest
//
//  Created by Timothy Liu on 4/3/14.
//  Copyright (c) 2015 Kloudless, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KRequest.h"
#import "KDownloadOperation.h"

@protocol KClientDelegate;
// @protocol KAccountInfo;
// @protocol KMetadata;

@interface KClient : NSObject {
    // TODO: move _key to a "session" object to store multiple account keys
    // or at least an account key container
    NSString *_token;
    NSString *_accountId;
    NSMutableSet *_requests;
    NSOperationQueue *_opQueue;
    int _opConnections;
    
    id<KClientDelegate> delegate;
}

- (id)initWithId:(NSString *)accountId andToken:(NSString *)token;
- (NSString*)verifyToken:(NSString *)token;

// Account Methods
- (void)listAccounts:(NSDictionary *)queryParams;
- (void)getAccount:(NSDictionary *)queryParams;
- (void)updateAccount:(NSDictionary *)bodyParams;
- (void)deleteAccount;

// File Methods
- (void)getFile:(NSString *)fileId;
- (void)updateFile:(NSString *)fileId bodyParameters:(NSDictionary *)bodyParams;
- (void)uploadFileData:(NSString *)fileInfo andData:(NSData *)data queryParameters:(NSDictionary *)queryParams;
- (void)updateFileData:(NSString *)fileId andData:(NSData *)data;
- (void)downloadFile:(NSString *)fileId;
// TODO: copyFile?
- (void)deleteFile:(NSString *)fileId;
- (void)getRecentFiles:(NSDictionary *)queryParams;
- (KDownloadOperation *)downloadFileOperation:(NSString *)fileId;


// Folder Methods
- (void)getFolder:(NSString *)folderId;
- (void)updateFolder:(NSString *)folderId bodyParameters:(NSDictionary *)bodyParams;
- (void)createFolder:(NSDictionary *)bodyParams queryParameters:(NSDictionary *)queryParams;
- (void)getFolderContents:(NSString *)folderId queryParameters:(NSDictionary *)queryParams;
// TODO: copyFolder?
- (void)deleteFolder:(NSString *)folderId;

// Link Methods
- (void)listLinks:(NSDictionary *)queryParams;
- (void)getLink:(NSString *)linkId queryParameters:(NSDictionary *)queryParams;
- (void)updateLink:(NSString *)linkId bodyParameters:(NSDictionary *)bodyParams;
- (void)createLink:(NSDictionary *)bodyParams;
- (void)deleteLink:(NSString *)linkId;

// Query Methods
- (void)search: (NSString *)query;

@property (nonatomic, retain) id<KClientDelegate> delegate;

@end

@protocol KClientDelegate <NSObject>

@optional
// Accounts
- (void)restClient:(KClient*)client listAccountsFailedWithError:(NSError*)error;
- (void)restClient:(KClient*)client listAccountsLoaded:(NSDictionary *)accounts;

- (void)restClient:(KClient*)client getAccountFailedWithError:(NSError*)error;
- (void)restClient:(KClient*)client getAccountLoaded:(NSDictionary *)accountInfo;

- (void)restClient:(KClient *)client updateAccountFailedWithError:(NSError *)error;
- (void)restClient:(KClient*)client updateAccountLoaded:(NSDictionary *)accountInfo;

- (void)restClient:(KClient*)client deleteAccountFailedWithError:(NSError*)error;
- (void)restClient:(KClient*)client deleteAccountLoaded:(NSDictionary *)response;

- (void)restClient:(KClient *)client searchAccountFailedWithError:(NSError *)error;
- (void)restClient:(KClient *)client searchAccountLoaded:(NSDictionary *)results;


// Files
- (void)restClient:(KClient*)client getFileFailedWithError:(NSError*)error;
- (void)restClient:(KClient*)client getFileLoaded:(NSDictionary *)fileInfo;

- (void)restClient:(KClient*)client updateFileFailedWithError:(NSError*)error;
- (void)restClient:(KClient*)client updateFileLoaded:(NSDictionary *)fileInfo;

- (void)restClient:(KClient*)client uploadFileDataFailedWithError:(NSError*)error;
- (void)restClient:(KClient*)client uploadFileDataLoaded:(NSDictionary *)fileInfo;

- (void)restClient:(KClient*)client updateFileDataFailedWithError:(NSError*)error;
- (void)restClient:(KClient*)client updateFileDataLoaded:(NSDictionary *)fileInfo;

- (void)restClient:(KClient*)client downloadFileFailedWithError:(NSError*)error;
- (void)restClient:(KClient*)client downloadFileLoaded:(NSData *)fileData;

- (void)restClient:(KClient*)client deleteFileFailedWithError:(NSError*)error;
- (void)restClient:(KClient*)client deleteFileLoaded:(NSDictionary *)response;

- (void)restClient:(KClient *)client recentFilesFailedWithError:(NSError *)error;
- (void)restClient:(KClient *)client recentFilesLoaded:(NSDictionary *)recentInfo;

// Folders
- (void)restClient:(KClient*)client getFolderFailedWithError:(NSError*)error;
- (void)restClient:(KClient*)client getFolderLoaded:(NSDictionary *)folderInfo;

- (void)restClient:(KClient*)client updateFolderFailedWithError:(NSError*)error;
- (void)restClient:(KClient*)client updateFolderLoaded:(NSDictionary *)folderInfo;

- (void)restClient:(KClient*)client createFolderFailedWithError:(NSError*)error;
- (void)restClient:(KClient*)client createFolderLoaded:(NSDictionary *)folderInfo;

- (void)restClient:(KClient*)client getFolderContentsFailedWithError:(NSError*)error;
- (void)restClient:(KClient*)client getFolderContentsLoaded:(NSDictionary *)folderContents;

- (void)restClient:(KClient*)client deleteFolderFailedWithError:(NSError*)error;
- (void)restClient:(KClient*)client deleteFolderLoaded:(NSDictionary *)response;

- (void)restClient:(KClient *)client copyFolderFailedWithError:(NSError *)error;
- (void)restClient:(KClient *)client copyFolderLoaded:(NSDictionary *)folderInfo;

// Links

- (void)restClient:(KClient*)client listLinksFailedWithError:(NSError*)error;
- (void)restClient:(KClient*)client listLinksLoaded:(NSDictionary *)links;

- (void)restClient:(KClient*)client getLinkFailedWithError:(NSError*)error;
- (void)restClient:(KClient*)client getLinkLoaded:(NSDictionary *)linkInfo;

- (void)restClient:(KClient *)client updateLinkFailedWithError:(NSError *)error;
- (void)restClient:(KClient *)client updateLinkLoaded:(NSDictionary *)linkInfo;

- (void)restClient:(KClient*)client createLinkFailedWithError:(NSError*)error;
- (void)restClient:(KClient*)client createLinkLoaded:(NSDictionary *)linkInfo;

- (void)restClient:(KClient*)client deleteLinkFailedWithError:(NSError*)error;
- (void)restClient:(KClient*)client deleteLinkLoaded:(NSDictionary *)response;

// Download
- (void)restClient:(KClient *)client operation:(KDownloadOperation *)operation downloadedFileAtPath:(NSString *)path;
- (void)restClient:(KClient *)client operation:(KDownloadOperation *)operation downloadErrored:(NSError *)error;
- (void)restClient:(KClient *)client operation:(KDownloadOperation *)operation didWriteData:(long long)bytesWritten
 totalBytesWritten:(long long)totalBytesWritten expectedTotalBytes:(long long)expectedTotalBytes;

// Query
- (void)restClient:(KClient*)client searchFailedWithError:(NSError*)error;
- (void)restClient:(KClient*)client searchLoaded:(NSDictionary *)response;

@end