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

@implementation VideoFileController {
    BOOL _isMP4;
    BOOL _MP4Ready;
}

+ (BOOL)fileSupportedByController:(File *)aFile {
    NSSet *fileTypes = [NSSet setWithObjects: @"avi", @"mv4", @"m4v", @"mov", @"wmv", @"mkv", @"mp4", @"rmvb", nil];
    if ([fileTypes containsObject:aFile.extension]) {
        return YES;
    }
    return NO;
}

- (void)setFile:(File *)aFile {
    _file = aFile;
    
    [[PutIOClient sharedClient] getInfoForFile:_file :^(id userInfoObject) {
        if (![userInfoObject isMemberOfClass:[NSError class]]) {
            fileSize = [[[userInfoObject valueForKeyPath:@"size"] objectAtIndex:0] intValue];
            self.infoController.titleLabel.text = [[userInfoObject valueForKeyPath:@"name"] objectAtIndex:0]; 
            self.infoController.fileSizeLabel.text = unitStringFromBytes(fileSize);
            NSString *contentType = [[userInfoObject valueForKeyPath:@"content_type"] objectAtIndex:0];
            if ([contentType isEqualToString:@"video/mp4"]) {
                _isMP4 = YES;
                [self.infoController enableButtons];
                [self.infoController hideProgress];
            }else{
                [self getMP4Info];
            }
        }
    }];
    
//    [self getInfoWithBlock:^(id userInfoObject) {
//        NSString *contentType = [[userInfoObject valueForKeyPath:@"content_type"] objectAtIndex:0];
//        if ([contentType isEqualToString:@"video/mp4"]) {
//            _isMP4 = YES;
//            self.enableButtons = YES;
//        }
//                
//        self.infoController.additionalInfoLabel.text = contentType;            
//    }];
    
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
    self.infoController.additionalInfoLabel.text = @"Downloading";
    self.infoController.secondaryButton.enabled = NO;
    self.infoController.primaryButton.enabled = NO;

    [self downloadFile];
}

- (void)downloadFile {
    NSString *requestURL;
    if (_isMP4) {
        requestURL = [NSString stringWithFormat:@"http://put.io/v2/files/%@/download", _file.id];   
    }else{
        requestURL = [NSString stringWithFormat:@"http://put.io/v2/files/%@/mp4/download", _file.id];   
    }

    [self downloadFileAtPath:requestURL WithCompletionBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.infoController.additionalInfoLabel.text = @"Moving to Photos app";
        
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
                    self.infoController.additionalInfoLabel.text = @"Downloaded - it's available in Photos";
                    [self.infoController enableButtons];
                    [self.infoController hideProgress];
                }
            }];
        }
        
        self.infoController.progressInfoHidden = YES;
        self.infoController.secondaryButton.enabled = YES;
        self.infoController.primaryButton.enabled = NO;
        
    } andFailureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", NSStringFromSelector(_cmd));
        NSLog(@"mega fail");
        NSLog(@"request %@", operation.request.URL);
        
        self.infoController.additionalInfoLabel.text = @"Download failed!";
        self.infoController.progressView.hidden = YES;
        self.infoController.secondaryButton.enabled = NO;
        self.infoController.primaryButton.enabled = YES;

    }];
    
}

- (void)getMP4Info {
    [[PutIOClient sharedClient] getMP4InfoForFile:_file :^(id userInfoObject) {
        if (![userInfoObject isMemberOfClass:[NSError class]]) {
            
            NSString *status = [userInfoObject valueForKeyPath:@"mp4.status"];
            _MP4Ready = NO;
            
            if ([status isEqualToString:@"COMPLETED"]) {
                _MP4Ready = YES;
                [self.infoController enableButtons];
            }
            
            if ([status isEqualToString:@"NotAvailable"]) {
                self.infoController.additionalInfoLabel.text = @"Requested an iPad version (this takes a *very* long time.)";
                [[PutIOClient sharedClient] requestMP4ForFile:_file];
                [self performSelector:@selector(getMP4Info) withObject:self afterDelay:3];
            }
            
            if ([status isEqualToString:@"CONVERTING"]) {
                self.infoController.additionalInfoLabel.text = @"Converting to iPad version (this takes a *very* long time.)";
                if ([userInfoObject valueForKeyPath:@"mp4.percent_done"] != [NSNull null]) {
                    self.infoController.progressView.hidden = NO;
                    self.infoController.progressView.progress = [[userInfoObject valueForKeyPath:@"mp4.percent_done"] floatValue] / 100;
                }
                [self performSelector:@selector(getMP4Info) withObject:self afterDelay:1];                    
            }
        }
    }];
}

@end
