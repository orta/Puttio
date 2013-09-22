//
//  BaseFileController.m
//  Puttio
//
//  Created by orta therox on 26/05/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "BaseFileController.h"
#import "AFNetworking.h"
#include <sys/param.h>  
#include <sys/mount.h>  
#import "FileInfoViewController.h"

#import "WatchedItem.h"
#import "WatchedList.h"
#import "NSManagedObject+ActiveRecord.h"
#import "FileDownloadProcess.h"
#import "ORFileDownloadOperation.h"
#import "NSFileManager+SkipBackup.h"

@interface BaseFileController (){

    BOOL shouldCancelOnHide;
}
@property (nonatomic, strong) ORFileDownloadOperation *downloadOperation;
@property (nonatomic, strong) FileDownloadProcess *fileDownloadProcess;

@end

@implementation BaseFileController

@synthesize infoController;

+ (id)controller { return [[self alloc] init]; }

+ (BOOL)fileSupportedByController:(File *)file { return NO; }

- (NSString *)primaryButtonText { return @"PRIMARY"; }
- (void)primaryButtonAction:(id)sender {}

- (BOOL)supportsSecondaryButton { return NO; }
- (NSString *)secondaryButtonText { return @"SECONDARY"; }
- (void)secondaryButtonAction:(id)sender {}

-(NSString *)descriptiveTextForFile { return @"NO TEXT SET"; }

- (void)downloadFileAtAddress:(NSString *)address to:(NSString *)path backgroundable:(BOOL)showTransferInBG withCompletionBlock:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success andFailureBlock:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    shouldCancelOnHide = !showTransferInBG;
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    struct statfs tStats;  
    statfs([[paths lastObject] cString], &tStats);  
    uint64_t totalSpace = tStats.f_bavail * tStats.f_bsize;
    __weak __typeof(self)weakSelf = self;


    __block FileInfoViewController *blockInfoController = infoController;
    if (fileSize < totalSpace) {
        [self.infoController disableButtons];
        [self.infoController showProgress];
        
        NSURL *addressURL = [NSURL URLWithString:[PutIOClient appendOauthToken:address]];
        self.downloadOperation = [ORFileDownloadOperation fileDownloadFromURL:addressURL toLocalPath:path];
                             
        if (showTransferInBG) {
           self.fileDownloadProcess = [FileDownloadProcess processWithHTTPRequest:self.downloadOperation andFile:_file];
        }

        [self.downloadOperation setDownloadProgressBlock: ^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            CGFloat progress = (float)totalBytesRead/totalBytesExpectedToRead;
            if (blockInfoController) {
                blockInfoController.progressView.progress = progress;
            }
            weakSelf.fileDownloadProcess.processProgress = progress;
        }];
        
        [self.downloadOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [[NSFileManager defaultManager] addSkipBackupAttributeToFileAtPath:path];
            if (blockInfoController) {
                [blockInfoController enableButtons];
            }
            success(operation, responseObject);
            weakSelf.fileDownloadProcess.finished = YES;
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            failure(operation, error); 
        }];
        
        [self.downloadOperation start];
        
    }else {
        NSString *message = [NSString stringWithFormat:@"Your %@ doesn't have enough free disk space to download.", [UIDevice deviceString]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not enough disk space" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

- (void) markFileAsViewed {
    [self performSelectorOnMainThread:@selector(_markFileAsViewed) withObject:nil waitUntilDone:YES];
}

- (void)_markFileAsViewed {
    WatchedList *list = [WatchedList findFirstByAttribute:@"folderID" withValue:_file.folder.id];
    if (!list) {
        list = [WatchedList object];
        list.folderID = _file.folder.id;
    }
    WatchedItem *item = [WatchedItem object];
    item.fileID = _file.id;
    [list addItemsObject:item];

    if ([[WatchedItem managedObjectContext] persistentStoreCoordinator].persistentStores.count) {
        [[WatchedItem managedObjectContext] save:nil];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:ORReloadGridNotification object:nil];
}

- (void)viewWillDissapear {
    if (self.downloadOperation && shouldCancelOnHide) {
        [self.downloadOperation cancel];
    }
}

@end
