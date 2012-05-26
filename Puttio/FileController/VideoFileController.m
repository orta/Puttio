//
//  VideoFileController.m
//  Puttio
//
//  Created by orta therox on 26/05/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "VideoFileController.h"
#import "FileInfoViewController.h"
#import "AFNetworking.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import "MoviePlayer.h"
#import "FileSizeUtils.h"

#include <sys/param.h>  
#include <sys/mount.h>  

@implementation VideoFileController {
    BOOL _isMP4;
    BOOL _MP4Ready;
    NSInteger fileSize;

    File *_file;
}

@synthesize infoController;
@dynamic file;

+ (id)controller {
    return [[self alloc] init];
}

+ (BOOL)fileSupportedByController:(File *)aFile {
    
    NSSet *fileTypes = [NSSet setWithObjects:@"avi", @"mv4", @"m4v", @"mkv", @"mp4", nil];
    if ([fileTypes containsObject:aFile.extension]) {
        return YES;
    }
    return NO;
}

- (void)setFile:(File *)aFile {
    _file = aFile;
    
    [self getFileInfo];
    [self getMP4Info];
}

- (NSString *)descriptiveTextForFile {
    return @"TEXT";
}

- (NSString *)primaryButtonText {
    return @"Stream";
}

- (void)primaryButtonAction:(id)sender {
    if (_isMP4) {
        [MoviePlayer streamMovieAtPath:[NSString stringWithFormat:@"http://put.io/v2/files/%@/stream", _file.id]];
    }else{
        [MoviePlayer streamMovieAtPath:[NSString stringWithFormat:@"http://put.io/v2/files/%@/mp4/stream", _file.id]];
    }
}

- (BOOL)supportsSecondaryButton {
    return YES;
}

- (NSString *)secondaryButtonText {
    return @"Download";
}

- (void)secondaryButtonAction:(id)sender {
    infoController.additionalInfoLabel.text = @"Downloading";
    infoController.secondaryButton.enabled = NO;
    infoController.primaryButton.enabled = NO;

    [self downloadFile];
}

- (void)downloadFile {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  
    struct statfs tStats;  
    statfs([[paths lastObject] cString], &tStats);  
    uint64_t totalSpace = tStats.f_bavail * tStats.f_bsize;  
    
    NSString *requestURL;
    if (_isMP4) {
        requestURL = [NSString stringWithFormat:@"http://put.io/v2/files/%@/download", _file.id];   
    }else{
        requestURL = [NSString stringWithFormat:@"http://put.io/v2/files/%@/mp4/download", _file.id];   
    }
    
    if (fileSize < totalSpace) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[PutIOClient appendOauthToken:requestURL]]];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [operation setDownloadProgressBlock:^(NSInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead) {
            infoController.progressView.progress = (float)totalBytesRead/totalBytesExpectedToRead;
        }];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            infoController.additionalInfoLabel.text = @"Moving to Photos app";
            
            NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:_file.id];
            NSString *fullPath = [NSString stringWithFormat:@"%@.mp4", filePath];
            
            [operation.responseData writeToFile:fullPath atomically:YES];
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];            
            NSURL *filePathURL = [NSURL fileURLWithPath:fullPath isDirectory:NO];
            if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:filePathURL]) {
                [library writeVideoAtPathToSavedPhotosAlbum:filePathURL completionBlock:^(NSURL *assetURL, NSError *error){
                    if (error) {
                        // TODO: error handling
                        NSLog(@"fail bail");
                        
                    } else {
                        // TODO: success handling
                        NSLog(@"success kid");
                        infoController.additionalInfoLabel.text = @"Downloaded - it's available in Photos";
                        
                        //                        fileDownloaded = YES;
                    }
                }];
            }
            infoController.progressView.hidden = YES;
            infoController.secondaryButton.enabled = YES;
            infoController.primaryButton.enabled = NO;
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", NSStringFromSelector(_cmd));
            NSLog(@"mega fail");
            NSLog(@"request %@", operation.request.URL);
            
            infoController.additionalInfoLabel.text = @"Download failed!";
            infoController.progressView.hidden = YES;
            infoController.secondaryButton.enabled = YES;
            infoController.primaryButton.enabled = NO;
        }];
        [operation start];
        
    }else {        
        NSString *message = [NSString stringWithFormat:@"Your iPad doesn't have enough free disk space to download."];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not enough disk space" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }    
}

- (void)getFileInfo {
    [[PutIOClient sharedClient] getInfoForFile:_file :^(id userInfoObject) {
        if (![userInfoObject isMemberOfClass:[NSError class]]) {
            NSString *contentType = [[userInfoObject valueForKeyPath:@"content_type"] objectAtIndex:0];
            if ([contentType isEqualToString:@"video/mp4"]) {
                _isMP4 = YES;
                self.enableButtons = YES;
            }
            
            infoController.titleLabel.text = [[userInfoObject valueForKeyPath:@"name"] objectAtIndex:0]; 
            fileSize = [[[userInfoObject valueForKeyPath:@"size"] objectAtIndex:0] intValue];
            infoController.fileSizeLabel.text = unitStringFromBytes(fileSize);
            
            infoController.additionalInfoLabel.text = contentType;            
        }
    }];
}

- (void)getMP4Info {
    [[PutIOClient sharedClient] getMP4InfoForFile:_file :^(id userInfoObject) {
        if (![userInfoObject isMemberOfClass:[NSError class]]) {
            NSString *status = [userInfoObject valueForKeyPath:@"mp4.status"];
            
            _MP4Ready = NO;
            if ([status isEqualToString:@"COMPLETED"]) {
                _MP4Ready = YES;
                self.enableButtons = YES;
            }
            
            if ([status isEqualToString:@"NotAvailable"]) {
                infoController.additionalInfoLabel.text = @"Requested an iPad version (this takes a *very* long time.)";
                [[PutIOClient sharedClient] requestMP4ForFile:_file];
                [self performSelector:@selector(getMP4Info) withObject:self afterDelay:3];
            }
            
            if ([status isEqualToString:@"CONVERTING"]) {
                infoController.additionalInfoLabel.text = @"Converting to iPad version (this takes a *very* long time.)";
                if ([userInfoObject valueForKeyPath:@"mp4.percent_done"] != [NSNull null]) {
                    infoController.progressView.hidden = NO;
                    infoController.progressView.progress = [[userInfoObject valueForKeyPath:@"mp4.percent_done"] floatValue] / 100;
                }
//                if (!stopRefreshing) {
//#warning this loop can run multiple times 
                    [self performSelector:@selector(getMP4Info) withObject:self afterDelay:1];                    
//                }
            }
        }
    }];
}

- (void)setEnableButtons:(BOOL)enable {
    infoController.primaryButton.enabled = enable;
    infoController.secondaryButton.enabled = enable;
}

@end
