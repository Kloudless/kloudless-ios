//
//  KClient.h
//  WebviewTest
//
//  Created by Timothy Liu on 4/3/14.
//  Copyright (c) 2014 Juan Gonzalez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KRequest.h"

@protocol KClientDelegate;
// @protocol KAccountInfo;
// @protocol KMetadata;

@interface KClient : NSObject {
    // TODO: move _key to a "session" object to store multiple account keys
    // or at least an account key container
    NSString *_key;
    NSMutableSet *_requests;
    id<KClientDelegate> delegate;
}

- (id)initWithKey:(NSString *)key;

- (void)listAccounts;
- (void)getAccount:(NSString *)accountId;
- (void)deleteAccount:(NSString *)accountId;

- (void)getFile:(NSString *)accountId withFileId:(NSString *)fileId;
- (void)updateFile:(NSString *)accountId withFileId:(NSString *)fileId andParams:(NSDictionary *)params;
- (void)uploadFile:(NSString *)accountId withFileInfo:(NSString *)fileInfo andData:(NSData *)data;
- (void)downloadFile:(NSString *)accountId withFileId:(NSString *)fileId;
- (void)deleteFile:(NSString *)accountId withFileId:(NSString *)fileId;

- (void)getFolder:(NSString *)accountId withFolderId:(NSString *)folderId;
- (void)updateFolder:(NSString *)accountId withFolderId:(NSString *)folderId andParams:(NSDictionary *)params;
- (void)createFolder:(NSString *)accountId andParams:(NSDictionary *)params;
- (void)getFolderContents:(NSString *)accountId withFolderId:(NSString *)folderId;
- (void)deleteFolder:(NSString *)accountId withFolderId:(NSString *)folderId;

- (void)listLinks:(NSString *)accountId;
- (void)getLink:(NSString *)accountId withLinkId:(NSString *)linkId;
- (void)createLink:(NSString *)accountId andParams:(NSDictionary *)params;
- (void)deleteLink:(NSString *)accountId withLinkId:(NSString *)linkId;

@property (nonatomic, retain) id<KClientDelegate> delegate;

@end

@protocol KClientDelegate <NSObject>

@optional
// Accounts
- (void)restClient:(KClient*)client listAccountsFailedWithError:(NSError*)error;
- (void)restClient:(KClient*)client listAccountsLoaded:(NSDictionary *)accounts;

- (void)restClient:(KClient*)client getAccountFailedWithError:(NSError*)error;
- (void)restClient:(KClient*)client getAccountLoaded:(NSDictionary *)accountInfo;

- (void)restClient:(KClient*)client deleteAccountFailedWithError:(NSError*)error;
- (void)restClient:(KClient*)client deleteAccountLoaded:(NSDictionary *)response;

// Files
- (void)restClient:(KClient*)client getFileFailedWithError:(NSError*)error;
- (void)restClient:(KClient*)client getFileLoaded:(NSDictionary *)fileInfo;

- (void)restClient:(KClient*)client updateFileFailedWithError:(NSError*)error;
- (void)restClient:(KClient*)client updateFileLoaded:(NSDictionary *)fileInfo;

- (void)restClient:(KClient*)client uploadFileFailedWithError:(NSError*)error;
- (void)restClient:(KClient*)client uploadFileLoaded:(NSDictionary *)fileInfo;

- (void)restClient:(KClient*)client downloadFileFailedWithError:(NSError*)error;
- (void)restClient:(KClient*)client downloadFileLoaded:(NSData *)fileData;

- (void)restClient:(KClient*)client deleteFileFailedWithError:(NSError*)error;
- (void)restClient:(KClient*)client deleteFileLoaded:(NSDictionary *)response;

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


// Links

- (void)restClient:(KClient*)client listLinksFailedWithError:(NSError*)error;
- (void)restClient:(KClient*)client listLinksLoaded:(NSDictionary *)links;

- (void)restClient:(KClient*)client getLinkFailedWithError:(NSError*)error;
- (void)restClient:(KClient*)client getLinkLoaded:(NSDictionary *)linkInfo;

- (void)restClient:(KClient*)client createLinkFailedWithError:(NSError*)error;
- (void)restClient:(KClient*)client createLinkLoaded:(NSDictionary *)linkInfo;

- (void)restClient:(KClient*)client deleteLinkFailedWithError:(NSError*)error;
- (void)restClient:(KClient*)client deleteLinkLoaded:(NSDictionary *)response;


@end