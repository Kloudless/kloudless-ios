//
//  ViewController.hKloudlessSDK.framework
//  KTester
//
//  Created by Timothy Liu on 4/5/14.
//  Copyright (c) 2014 Kloudless, Inc. All rights reserved.
//

#import <KloudlessSDK/KloudlessSDK.h>
#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIWebViewDelegate, KClientDelegate> {
    NSString *accountId;
    NSString *accountKey;
    
    KClient *client;
}
@property (nonatomic, retain) NSString *accountId;
@property (nonatomic, retain) NSString *accountKey;
@property (nonatomic, retain) KClient *client;

// authentication
@property (nonatomic, weak) IBOutlet UIButton *linkKloudless;
@property (nonatomic, weak) IBOutlet UIButton *unlinkAll;

// accounts
@property (nonatomic, weak) IBOutlet UIButton *listAccounts;
@property (nonatomic, weak) IBOutlet UIButton *getAccountInfo;
@property (nonatomic, weak) IBOutlet UIButton *deleteAccount;

// files
@property (nonatomic, weak) IBOutlet UIButton *getFileInfo;
@property (nonatomic, weak) IBOutlet UIButton *updateFile;
@property (nonatomic, weak) IBOutlet UIButton *uploadFile;
@property (nonatomic, weak) IBOutlet UIButton *downloadFile;
@property (nonatomic, weak) IBOutlet UIButton *deleteFile;


// folders
@property (nonatomic, weak) IBOutlet UIButton *getFolderInfo;
@property (nonatomic, weak) IBOutlet UIButton *updateFolder;
@property (nonatomic, weak) IBOutlet UIButton *createFolder;
@property (nonatomic, weak) IBOutlet UIButton *getFolderContents;
@property (nonatomic, weak) IBOutlet UIButton *deleteFolder;


// links
@property (nonatomic, weak) IBOutlet UIButton *listLinks;
@property (nonatomic, weak) IBOutlet UIButton *getLinkInfo;
@property (nonatomic, weak) IBOutlet UIButton *createLink;
@property (nonatomic, weak) IBOutlet UIButton *deleteLink;

// Concurrent downloads
@property (nonatomic, weak) IBOutlet UIButton *downloadAll;

@end
