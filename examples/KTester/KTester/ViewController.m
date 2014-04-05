//
//  ViewController.m
//  KTester
//
//  Created by Timothy Liu on 4/5/14.
//  Copyright (c) 2014 Kloudless, Inc. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize linkKloudless;
@synthesize listAccounts, getAccountInfo, deleteAccount;
@synthesize getFileInfo, updateFile, uploadFile, downloadFile, deleteFile;
@synthesize getFolderInfo, updateFolder, createFolder, getFolderContents, deleteFolder;
@synthesize listLinks, getLinkInfo, createLink, deleteLink;

@synthesize accountId, accountKey, client;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    // Auth
    [linkKloudless addTarget:self action:@selector(didPressLink:) forControlEvents:UIControlEventTouchUpInside];
    
    // Accounts
    [listAccounts addTarget:self action:@selector(testListAccounts:) forControlEvents:UIControlEventTouchUpInside];
    [getAccountInfo addTarget:self action:@selector(testGetAccount:) forControlEvents:UIControlEventTouchUpInside];
    [deleteAccount addTarget:self action:@selector(testDeleteAccount:) forControlEvents:UIControlEventTouchUpInside];
    
    // Files
    [getFileInfo addTarget:self action:@selector(testGetFile:) forControlEvents:UIControlEventTouchUpInside];
    [updateFile addTarget:self action:@selector(testUpdateFile:) forControlEvents:UIControlEventTouchUpInside];
    [uploadFile addTarget:self action:@selector(testUploadFile:) forControlEvents:UIControlEventTouchUpInside];
    [downloadFile addTarget:self action:@selector(testDownloadFile:) forControlEvents:UIControlEventTouchUpInside];
    [deleteFile addTarget:self action:@selector(testDeleteFile:) forControlEvents:UIControlEventTouchUpInside];
    
    // Folders
    [getFolderInfo addTarget:self action:@selector(testGetFolder:) forControlEvents:UIControlEventTouchUpInside];
    [updateFolder addTarget:self action:@selector(testUpdateFolder:) forControlEvents:UIControlEventTouchUpInside];
    [createFolder addTarget:self action:@selector(testCreateFolder:) forControlEvents:UIControlEventTouchUpInside];
    [getFolderContents addTarget:self action:@selector(testGetFolderContents:) forControlEvents:UIControlEventTouchUpInside];
    [deleteFolder addTarget:self action:@selector(testDeleteFolder:) forControlEvents:UIControlEventTouchUpInside];
    
    // Links
    [listLinks addTarget:self action:@selector(testListLinks:) forControlEvents:UIControlEventTouchUpInside];
    [getLinkInfo addTarget:self action:@selector(testGetLink:) forControlEvents:UIControlEventTouchUpInside];
    [createLink addTarget:self action:@selector(testCreateLink:) forControlEvents:UIControlEventTouchUpInside];
    [deleteLink addTarget:self action:@selector(testDeleteLink:) forControlEvents:UIControlEventTouchUpInside];

}

/**
 Key method for the Kloudless SDK.  This method of your View Controller is necessary to
 handle when an account is authorized.  The Account id and Key are returned.
 */
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    KAuth *auth = [KAuth sharedAuth];
    
    if ([auth isLinked]) {
        accountId = [[auth accountIds] objectAtIndex:0];
        accountKey = [auth keyForAccountId:accountId];
        client = [[KClient alloc] initWithId:accountId
                                      andKey:accountKey];
        client.delegate = self;
    }
}

/**
 Key method to launch the Kloudless SDK Auth Controller.  Note: the default auth url allows a user to
 authenticate any of the default services.  There are a few customized urls you can use:
 
 Default:
 NSString *authUrl = @"https://api.kloudless.com/services/?app_id=%@&referrer=mobile&retrieve_account_key=true"

 Authenticate a set of services:
 NSString *authUrl = @"https://api.kloudless.com/services/?app_id=%@&referrer=mobile&retrieve_account_key=true&services=box,dropbox"

 Skip the user selecting and authenticate a specific service:
 NSString *authUrl = @"https://api.kloudless.com/services/dropbox?app_id=%@&referrer=mobile&retrieve_account_key=true"

 Note: Both retrieve_account_key and mobile need to be set to true and mobile respectively to retrieve authentication credentials.
 
 */
- (void)didPressLink:(id)sender {
    [[KAuth sharedAuth] authFromController:self andAuthUrl:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -mark custom account instance methods

-(void)testListAccounts:(id)sender
{
    [client listAccounts:nil];
}

- (void)restClient:(KClient*)client listAccountsLoaded:(NSDictionary *)accounts
{
    NSLog(@"Accounts: %@", accounts);
    
}

-(void)testGetAccount:(id)sender
{
    [client getAccount:nil];
}

- (void)restClient:(KClient*)client getAccountLoaded:(NSDictionary *)accountInfo
{
    NSLog(@"Account Info: %@", accountInfo);
}

-(void)testDeleteAccount:(id)sender
{
//    [client deleteAccount];
}

- (void)restClient:(KClient*)client deleteAccountLoaded:(NSDictionary *)response
{
    NSLog(@"Response: %@", response);
}

#pragma -mark custom file instance methods
-(void)testGetFile:(id)sender
{
    NSString *fileId = @"fL3Rlc3QgKDQpLmh0bWw=";
    [client getFile:fileId];
}

- (void)restClient:(KClient*)client getFileLoaded:(NSDictionary *)fileInfo
{
    NSLog(@"File Info: %@", fileInfo);
}

-(void)testUpdateFile:(id)sender
{
    NSString *fileId = @"fL3Rlc3QgKDQpLmh0bWw=";
    NSString *fileName = @"test (4).html";
    NSDictionary *params = [NSDictionary dictionaryWithObject:fileName forKey:@"name"];
    [client updateFile:fileId bodyParameters:params];
}

- (void)restClient:(KClient*)client updateFileLoaded:(NSDictionary *)fileInfo
{
    NSLog(@"File Info: %@", fileInfo);
}

-(void)testUploadFile:(id)sender
{
    
    NSString *metadata = [NSString stringWithFormat:@"{\"name\": \"upload.txt\", \"parent_id\": \"root\"}"];
    NSString *fileString = @"Hello, world!";
    NSData *fileData = [fileString dataUsingEncoding:NSUTF8StringEncoding];
    [client uploadFileData:metadata andData:fileData queryParameters:nil];
}

- (void)restClient:(KClient*)client uploadFileLoaded:(NSDictionary *)fileInfo
{
    NSLog(@"File Info: %@", fileInfo);
}

-(void)testDownloadFile:(id)sender
{
    NSString *fileId = @"fL3Rlc3QgKDQpLmh0bWw=";
    [client downloadFile:fileId];
    
}

- (void)restClient:(KClient*)client downloadFileLoaded:(NSData *)fileData
{
    NSLog(@"File Data: %@", [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding]);
}

-(void)testDeleteFile:(id)sender
{
    // TODO: tested, but please enter in new fileId
//    NSString *fileId = @"fL3Rlc3QgKDQpLmh0bWw=";
//    [client deleteFile:fileId];
}

- (void)restClient:(KClient*)client deleteFileLoaded:(NSDictionary *)response
{
    NSLog(@"Response: %@", response);
}

#pragma -mark custom folder instance methods
-(void)testGetFolder:(id)sender
{
    NSString *folderId = @"fL2E=";
    [client getFolder:folderId];
}

- (void)restClient:(KClient*)client getFolderLoaded:(NSDictionary *)folderInfo
{
    NSLog(@"Folder Info: %@", folderInfo);
}

-(void)testUpdateFolder:(id)sender
{
    NSString *folderId = @"fL2E=";
    NSString *folderName = @"Test Folder Name";
    
    NSDictionary *params = [NSDictionary dictionaryWithObject:folderName forKey:@"name"];
    [client updateFolder:folderId bodyParameters:params];
}

- (void)restClient:(KClient*)client updateFolderLoaded:(NSDictionary *)folderInfo
{
    NSLog(@"Folder Info: %@", folderInfo);
}

-(void)testCreateFolder:(id)sender
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"uploadfolder", @"name", @"root", @"parent_id", nil];
    [client createFolder:params queryParameters:nil];
}

- (void)restClient:(KClient*)client createFolderLoaded:(NSDictionary *)folderInfo
{
    NSLog(@"Folder Info: %@", folderInfo);
}

-(void)testGetFolderContents:(id)sender
{
    NSString *folderId = @"root";
    [client getFolderContents:folderId queryParameters:nil];
}

- (void)restClient:(KClient*)client getFolderContentsLoaded:(NSDictionary *)folderContents
{
    NSLog(@"Folder Contents: %@", folderContents);
}

-(void)testDeleteFolder:(id)sender
{
    // TODO: tested, but please enter in new fileId
//    NSString *folderId = @"fL2E=";
//    [client deleteFolder:folderId];
}

- (void)restClient:(KClient*)client deleteFolderLoaded:(NSDictionary *)response
{
    NSLog(@"Response: %@", response);
}

#pragma -mark custom account instance methods

-(void)testListLinks:(id)sender
{
    [client listLinks:nil];
}

- (void)restClient:(KClient*)client listLinksLoaded:(NSDictionary *)links
{
    NSLog(@"Links: %@", links);
    
}

-(void)testGetLink:(id)sender
{
    NSString *linkId = @"Dn1IJAkNGr3Keh3bKss0";
    [client getLink:linkId queryParameters:nil];
}

- (void)restClient:(KClient*)client getLinkLoaded:(NSDictionary *)linkInfo
{
    NSLog(@"Link Info: %@", linkInfo);
}

-(void)testCreateLink:(id)sender
{
    NSString *fileId = @"fL3Rlc3QgKDE2KS50eHQ=";
    NSDictionary *params = [NSDictionary dictionaryWithObject:fileId forKey:@"file_id"];
    [client createLink:params];
}

- (void)restClient:(KClient*)client createLinkLoaded:(NSDictionary *)linkInfo
{
    NSLog(@"Link Info: %@", linkInfo);
}

-(void)testDeleteLink:(id)sender
{
    // TODO: tested, but please enter in new linkId
//    NSString *linkId = @"Dn1IJAkNGr3Keh3bKss0";
//    [client deleteLink:linkId];
}

- (void)restClient:(KClient*)client deleteLinkLoaded:(NSDictionary *)response
{
    NSLog(@"Response: %@", response);
}

@end
