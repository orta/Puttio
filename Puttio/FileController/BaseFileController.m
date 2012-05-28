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

@implementation BaseFileController

@synthesize file, infoController;

+ (id)controller { return [[self alloc] init]; }

+ (BOOL)fileSupportedByController:(File *)file { return NO; }

- (NSString *)primaryButtonText { return @"PRIMARY"; }
- (void)primaryButtonAction:(id)sender {}

- (BOOL)supportsSecondaryButton { return NO; }
- (NSString *)secondaryButtonText { return @"SECONDARY"; }
- (void)secondaryButtonAction:(id)sender {}


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
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [operation setDownloadProgressBlock:^(NSInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead) {
            infoController.progressView.progress = (float)totalBytesRead/totalBytesExpectedToRead;
        }];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.infoController enableButtons];
            success(operation, responseObject);
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            failure(operation, error); 
        }];
        
        [operation start];
        
    }else {        
        NSString *message = [NSString stringWithFormat:@"Your iPad doesn't have enough free disk space to download."];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not enough disk space" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }    

    
}

@end
