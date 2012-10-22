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

@interface BaseFileController (){
    FileDownloadProcess *_fileDownloadProcess;
    ORFileDownloadOperation *downloadOperation;
    BOOL shouldCancelOnHide;
}
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
    __block FileInfoViewController *blockInfoController = infoController;
    if (fileSize < totalSpace) {
        [self.infoController disableButtons];
        [self.infoController showProgress];
        
        NSURL *addressURL = [NSURL URLWithString:[PutIOClient appendOauthToken:address]];
        downloadOperation = [ORFileDownloadOperation fileDownloadFromURL:addressURL toLocalPath:path];
                             
        if (showTransferInBG) {
            _fileDownloadProcess = [FileDownloadProcess processWithHTTPRequest:downloadOperation andFile:_file];
        }

        [downloadOperation setDownloadProgressBlock: ^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            CGFloat progress = (float)totalBytesRead/totalBytesExpectedToRead;
            if (blockInfoController) {
                blockInfoController.progressView.progress = progress;
            }
            _fileDownloadProcess.progress = progress;
        }];
        
        [downloadOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (blockInfoController) {
                [blockInfoController enableButtons];
            }
            success(operation, responseObject);
            _fileDownloadProcess.finished = YES;
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            failure(operation, error); 
        }];
        
        [downloadOperation start];
        
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
    if (downloadOperation && shouldCancelOnHide) {
        [downloadOperation cancel];
    }
}

@end
