//
//  FileInfoViewController.m
//  Puttio
//
//  Created by orta therox on 01/04/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "FileInfoViewController.h"
#import "UIImageView+AFNetworking.h"
#import "MoviePlayer.h"
#import "FileSizeUtils.h"

#include <sys/param.h>  
#include <sys/mount.h>  

@interface FileInfoViewController() {
    File *_item;
    NSString *streamPath;
    NSString *downloadPath;
    NSInteger fileSize;
    BOOL fileDownloaded;
    BOOL stopRefreshing;
}
@end


@implementation FileInfoViewController 
@synthesize titleLabel;
@synthesize additionalInfoLabel;
@synthesize fileSizeLabel;
@synthesize streamButton;
@synthesize downloadButton;
@synthesize thumbnailImageView;
@synthesize progressView;
@dynamic item;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    streamButton.enabled = NO;
    progressView.hidden = YES;
    fileSizeLabel.text = @"";
    titleLabel.text = @"";
    additionalInfoLabel.text = @"";
}

- (void)setItem:(File *)item {
    if (![item conformsToProtocol:@protocol(ORDisplayItemProtocol)]) {
        [NSException raise:@"File Info item should conform to ORDisplayItemProtocol" format:@"File Info item should conform to ORDisplayItemProtocol"];
    }
    NSObject <ORDisplayItemProtocol> *object = item;
    titleLabel.text = object.name;
    _item = item;
    [thumbnailImageView setImageWithURL:[NSURL URLWithString:[PutIOClient appendOauthToken:object.screenShotURL]]];

    [self getFileInfo];
    [self getMP4Info];        
}

- (void)getFileInfo {
    [[PutIOClient sharedClient] getInfoForFile:_item :^(id userInfoObject) {
        if (![userInfoObject isMemberOfClass:[NSError class]]) {

            if ([self.item.contentType isEqualToString:@"video/mp4"]) {
                streamPath = [[userInfoObject valueForKey:@"stream_url"] objectAtIndex:0];
                downloadPath = [[userInfoObject valueForKeyPath:@"mp4_url"] objectAtIndex:0];                
            }

            titleLabel.text = [[userInfoObject valueForKeyPath:@"name"] objectAtIndex:0]; 
            fileSize = [[[userInfoObject valueForKeyPath:@"size"] objectAtIndex:0] intValue];
            fileSizeLabel.text = unitStringFromBytes(fileSize);

            additionalInfoLabel.text = [[userInfoObject valueForKeyPath:@"content_type"] objectAtIndex:0];
            
            streamButton.enabled = !!streamPath;
            downloadButton.enabled = !!downloadPath;
        }
    }];
}

- (void)getMP4Info {
    [[PutIOClient sharedClient] getMP4InfoForFile:_item :^(id userInfoObject) {
        if (![userInfoObject isMemberOfClass:[NSError class]]) {
            if (![self.item.contentType isEqualToString:@"video/mp4"]) {
                streamPath = [userInfoObject valueForKeyPath:@"mp4.stream_url"];
                downloadPath = [userInfoObject valueForKeyPath:@"mp4.download_url"];
            }
            
            streamButton.enabled = !!streamPath;
            downloadButton.enabled = !!downloadPath;

            if(!streamPath || !downloadPath) {
                NSString *status = [userInfoObject valueForKeyPath:@"mp4.status"];
                if ([status isEqualToString:@"NotAvailable"]) {
                    additionalInfoLabel.text = @"Requested an iPad version (this takes a *very* long time.)";
                    [[PutIOClient sharedClient] requestMP4ForFile:_item];
                    [self performSelector:@selector(getMP4Info) withObject:self afterDelay:30];
                }
                if ([status isEqualToString:@"CONVERTING"]) {
                    additionalInfoLabel.text = @"Converting to iPad version (this takes a *very* long time.)";
                    if ([userInfoObject valueForKeyPath:@"mp4.percent_done"] != [NSNull null]) {
                        progressView.hidden = NO;
                        progressView.progress = [[userInfoObject valueForKeyPath:@"mp4.percent_done"] floatValue] / 100;
                    }
                    if (!stopRefreshing) {
                        #warning this loop can run multiple times 
                        [self performSelector:@selector(getMP4Info) withObject:self afterDelay:1];                    
                    }
                }
            }
        }
    }];
}

- (id)item {
    return _item;
}

- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setThumbnailImageView:nil];
    [self setAdditionalInfoLabel:nil];
    [self setStreamButton:nil];
    [self setProgressView:nil];
    stopRefreshing = YES;
    [self setFileSizeLabel:nil];
    [self setDownloadButton:nil];
    [super viewDidUnload];
}

- (IBAction)backButton:(id)sender {
    
}

- (IBAction)streamTapped:(id)sender {
    if (streamPath) {
        [MoviePlayer streamMovieAtPath:streamPath];
    }
}

- (IBAction)downloadTapped:(id)sender {
    if (!fileDownloaded) {
        if (downloadPath) {
            self.progressView.hidden = NO;
            self.progressView.progress = 0;
            self.additionalInfoLabel.text = @"Downloading";
            self.downloadButton.enabled = NO;
            self.streamButton.enabled = NO;
            [self downloadItem];
        }                
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"photos:"]];
    }
}

- (void)downloadItem {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);  
    struct statfs tStats;  
    statfs([[paths lastObject] cString], &tStats);  
    uint64_t totalSpace = tStats.f_bavail * tStats.f_bsize;  

//    NSLog(@" %llu total", totalSpace);
//    NSLog(@" %i ", fileSize);
    
    if (fileSize < totalSpace) {
        NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:ORStreamTokenDefault];    
        NSString* address= [NSString stringWithFormat:@"%@/atk/%@", downloadPath, token];
        NSLog(@"downloading %@", address);
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:address]];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

        [operation setDownloadProgressBlock:^(NSInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead) {
            progressView.progress = (float)totalBytesRead/totalBytesExpectedToRead;
        }];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:_item.id];
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
                        self.additionalInfoLabel.text = @"Downloaded - open in Photos";
                        self.downloadButton.titleLabel.text = @"Photos!";
                        fileDownloaded = YES;
                    }
                }];
            }
            progressView.hidden = YES;
            self.downloadButton.enabled = YES;
            self.streamButton.enabled = NO;
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", NSStringFromSelector(_cmd));
            NSLog(@"mega fail");
            progressView.hidden = YES;
            self.downloadButton.enabled = YES;
            self.streamButton.enabled = NO;

        }];
        [operation start];
    }else {        
        NSString *message = [NSString stringWithFormat:@"Your iPad doesn't have enough free disk space to sync."];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not enough disk space" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

@end
