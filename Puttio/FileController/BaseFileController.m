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
#include "FileSizeUtils.h"

#import "WatchedItem.h"
#import "WatchedList.h"
#import "NSManagedObject+ActiveRecord.h"

@implementation BaseFileController

@synthesize file, infoController;

+ (id)controller { return [[self alloc] init]; }

+ (BOOL)fileSupportedByController:(File *)file { return NO; }

- (NSString *)primaryButtonText { return @"PRIMARY"; }
- (void)primaryButtonAction:(id)sender {}

- (BOOL)supportsSecondaryButton { return NO; }
- (NSString *)secondaryButtonText { return @"SECONDARY"; }
- (void)secondaryButtonAction:(id)sender {}

-(NSString *)descriptiveTextForFile { return @"NO TEXT SET"; }

- (void)getInfoWithBlock:(void(^)(id infoObject))onComplete {
    NSLog(@"info!");
//    [[PutIOClient sharedClient] getInfoForFile:_file :^(id userInfoObject) {
//        NSLog(@"asdafsfAF");
//        if (![userInfoObject isMemberOfClass:[NSError class]]) {
//            fileSize = [[[userInfoObject valueForKeyPath:@"size"] objectAtIndex:0] intValue];
//            self.infoController.titleLabel.text = [[userInfoObject valueForKeyPath:@"name"] objectAtIndex:0]; 
//            self.infoController.fileSizeLabel.text = unitStringFromBytes(fileSize);
//            NSLog(@"%@ %s\n%@", NSStringFromSelector(_cmd), __FILE__, self);
//
//            onComplete(userInfoObject);
//        }
//    }];
}

- (void)downloadFileAtPath:(NSString*)path WithCompletionBlock:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success andFailureBlock:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  
    struct statfs tStats;  
    statfs([[paths lastObject] cString], &tStats);  
    uint64_t totalSpace = tStats.f_bavail * tStats.f_bsize;  

    if (fileSize < totalSpace) {
        [self.infoController disableButtons];
        [self.infoController showProgress];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[PutIOClient appendOauthToken:path]]];
        downloadOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [downloadOperation setDownloadProgressBlock:^(NSInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead) {
            infoController.progressView.progress = (float)totalBytesRead/totalBytesExpectedToRead;
        }];
        
        [downloadOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.infoController enableButtons];
            success(operation, responseObject);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            failure(operation, error); 
        }];
        
        [downloadOperation start];
        
    }else {        
        NSString *message = [NSString stringWithFormat:@"Your iPad doesn't have enough free disk space to download."];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not enough disk space" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

- (void) markFileAsViewed {
    WatchedList *list = [WatchedList findFirstByAttribute:@"folderID" withValue:_file.folder.id];
    if (!list) {
        list = [WatchedList object];
        list.folderID = _file.folder.id;
    }
    WatchedItem *item = [WatchedItem object];
    item.fileID = _file.id;
    [list addItemsObject:item];
    
    [[WatchedItem managedObjectContext] save:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORReloadGridNotification object:nil];
}

- (void)viewWillDissapear {
    if ([downloadOperation isExecuting]) {
        [downloadOperation cancel];        
    }
}
@end
