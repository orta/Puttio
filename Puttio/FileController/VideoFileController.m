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
#import "LocalFile.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import "MoviePlayer.h"
#import "ConvertToMP4Process.h"
#import "UIDevice+SpaceStats.h"

@implementation VideoFileController {
    BOOL _isMP4;
    BOOL requested;
}

+ (BOOL)fileSupportedByController:(File *)aFile {
    NSSet *fileTypes = [NSSet setWithObjects: @"avi", @"mv4", @"m4v", @"mov", @"wmv", @"mkv", @"mp4", @"rmvb", @"mpeg", @"mpg", nil];

    if ([fileTypes containsObject:aFile.extension]) {
        return YES;
    }

    return NO;
}

- (void)setFile:(File *)aFile {
    _file = aFile;
    [self.infoController disableButtons];

    self.infoController.titleLabel.text = _file.displayName;
    self.infoController.fileSizeLabel.text = [UIDevice humanStringFromBytes:[[_file size] doubleValue]];
    [self.infoController hideProgress];

    if ([_file.contentType isEqualToString:@"video/mp4"] ||
        [_file.contentType isEqualToString:@"video/quicktime"] ||
        [_file.extension.lowercaseString isEqualToString:@"mp4"]) {

        _isMP4 = YES;
        [self.infoController enableButtons];
        [self.infoController hideProgress];

    }else{
        if ([_file.hasMP4 boolValue]) {
            [self.infoController hideProgress];
            [self.infoController enableButtons];
        }else{
            [self getMP4Info];
        }
    }
}

- (NSString *)descriptiveTextForFile {
    return @"Stream or Download Video";
}

- (NSString *)primaryButtonText {
    return @"Stream";
}

- (void)primaryButtonAction:(id)sender {
    [MoviePlayer sharedPlayer].delegate = self;

    if (_isMP4) {
        [MoviePlayer streamMovieAtPath:[NSString stringWithFormat:@"https://put.io/v2/files/%@/stream", _file.id]];
    }else{
        [MoviePlayer streamMovieAtPath:[NSString stringWithFormat:@"https://put.io/v2/files/%@/mp4/stream", _file.id]];
    }
    
    [self markFileAsViewed];
}

- (void)moviePlayer:(MoviePlayer *)player didEndWithError:(NSString *)error {
    self.infoController.additionalInfoLabel.text = error;
}

- (BOOL)supportsSecondaryButton {
    return YES;
}

- (NSString *)secondaryButtonText {
    return @"Download";
}

- (void)secondaryButtonAction:(id)sender {
    if ([LocalFile findByAttribute:@"id" withValue:_file.id].count) {
        self.infoController.additionalInfoLabel.text = @"You have already downloaded this.";
        return;
    }

    if([self deviceHasEnoughSpace]){
        if ([UIDevice isPad]) {
            self.infoController.additionalInfoLabel.text = @"Downloading - You can close this popover and it will download as long as you are in the app.";
        } else {
            self.infoController.additionalInfoLabel.text = @"Downloading - Popover can be closed, but not the app.";
        }
        [self.infoController showProgress];
        [self downloadFile];
    } else {
        self.infoController.additionalInfoLabel.text = @"You do not have enough free space to download this.";
    }
}

- (BOOL)deviceHasEnoughSpace {
    double freeSpace = [UIDevice numberOfBytesFree];
    if (freeSpace > _file.size.doubleValue) {
        return YES;
    }
    return NO;
}

- (void)downloadFile {    
    NSString *requestURL;
    if (_isMP4) {
        requestURL = [NSString stringWithFormat:@"https://put.io/v2/files/%@/download", _file.id];   
    }else{
        requestURL = [NSString stringWithFormat:@"https://put.io/v2/files/%@/mp4/download", _file.id];   
    }

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_file.screenShotURL]];
    AFHTTPRequestOperation *screenShotOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [screenShotOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = paths[0];
        NSString *screenShotPath = [documentsDirectory stringByAppendingPathComponent:[_file.id stringByAppendingPathExtension:@"jpg"]];
        
        [operation.responseData writeToFile:screenShotPath atomically:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"screenshot op died");
    }];
    [screenShotOperation start];

    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:_file.id];
    NSString *fullPath = [NSString stringWithFormat:@"%@.mp4", filePath];
    
    [self downloadFileAtAddress:requestURL to:fullPath backgroundable:YES withCompletionBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

        // Give it a localfile core data entity
        LocalFile *localFile = [LocalFile localFileWithFile:_file];
        if ([[localFile managedObjectContext] persistentStoreCoordinator].persistentStores.count) {
            [[localFile managedObjectContext] save:nil];
        }
        
        if (self.infoController) {
            // Set the UI state
            self.infoController.additionalInfoLabel.text = @"Downloaded - It's in your media library!";
            [self.infoController enableButtons];
            [self.infoController hideProgress];

            self.infoController.progressInfoHidden = YES;
            self.infoController.secondaryButton.enabled = YES;
            self.infoController.primaryButton.enabled = NO;
        }

    } andFailureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", NSStringFromSelector(_cmd));
        NSLog(@"mega fail");
        NSLog(@"request %@", operation.request.URL);

        if (self.infoController) {
            self.infoController.additionalInfoLabel.text = @"Download failed!";
            [self.infoController hideProgress];
            self.infoController.secondaryButton.enabled = NO;
            self.infoController.primaryButton.enabled = YES;
        }
    }];
}

- (void)getMP4Info {
    if (_file == nil) {
        NSLog(@"getting info for nil");
    }

    [[PutIOClient sharedClient] getMP4InfoForFile:_file :^(id userInfoObject) {
        if (![userInfoObject isKindOfClass:[NSError class]]) {
            
            NSString *status = [userInfoObject valueForKeyPath:@"mp4.status"];
            
            if ([status isEqualToString:@"COMPLETED"]) {
                [self.infoController enableButtons];
                [self.infoController hideProgress];
            }else{
                [self.infoController disableButtons];

                if (!requested) {
                    [ConvertToMP4Process processWithFile:_file];
                    requested = YES;
                }
                
                if ([status isEqualToString:@"IN_QUEUE"]) {
                    self.infoController.additionalInfoLabel.text = [NSString stringWithFormat:@"Request for an %@ version has been recieved and is queued, this could take a while.", [UIDevice deviceString]];
                    [self performSelector:@selector(getMP4Info) withObject:self afterDelay:2];
                }
                
                else if ([status isEqualToString:@"NOT_AVAILABLE"]) {
                    self.infoController.additionalInfoLabel.text = [NSString stringWithFormat:@"Requested an %@ version.", [UIDevice deviceString]];

                    [[PutIOClient sharedClient] requestMP4ForFile:_file];
                    [self performSelector:@selector(getMP4Info) withObject:self afterDelay:2];
                }
                
                else if ([status isEqualToString:@"CONVERTING"]) {
                    self.infoController.additionalInfoLabel.text = [NSString stringWithFormat:@"Converting to %@ version right now.", [UIDevice deviceString]];

                    if ([userInfoObject valueForKeyPath:@"mp4.percent_done"] != [NSNull null]) {
                        [self.infoController showProgress];
                        self.infoController.progressView.progress = [[userInfoObject valueForKeyPath:@"mp4.percent_done"] floatValue] / 100;
                    }
                    [self performSelector:@selector(getMP4Info) withObject:self afterDelay:2];
                }

                else {
                    self.infoController.additionalInfoLabel.text = [NSString stringWithFormat:@"Converting for %@ has failed.", [UIDevice deviceString]];
                }
            }
        }
    }];
}

@end
