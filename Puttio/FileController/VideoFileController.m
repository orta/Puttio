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
    BOOL _requested;
    BOOL _hidden;
    BOOL _addedProcess;
    
    UIDocumentInteractionController *_docController;
    OROpenSubtitleDownloader *_subtitleDownloader;
    NSArray *_subtitleResults;
}

+ (BOOL)fileSupportedByController:(File *)aFile {
    NSSet *fileTypes = [NSSet setWithObjects: @"avi", @"mv4", @"m4v", @"mov", @"wmv", @"mkv", @"mp4", @"rmvb", @"mpeg", @"mpg", @"m4b", @"mp3", nil];

    if ([fileTypes containsObject:aFile.extension]) {
        return YES;
    }

    return NO;
}

- (void)setFile:(File *)aFile {
    _file = aFile;
    _requested = NO;
    
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
        if ([_file.isMP4Available boolValue]) {
            [self.infoController hideProgress];
            [self.infoController enableButtons];
        }else{
            [self getMP4Info];
        }
    }
}

- (void)setupSecondaryButton {
    BOOL fileExists = [LocalFile localFileExists:_file];
    NSString *filePath = [LocalFile localPathForMovieWithFile:_file];
    if (fileExists) {
        if ([self canOpenDocumentWithFilePath:filePath inView:self.infoController.secondaryButton]) {
            self.infoController.secondaryButton.enabled = YES;
            [self.infoController.secondaryButton setTitle:@"Other App" forState:UIControlStateNormal];
        } else {
            self.infoController.secondaryButton.enabled = NO;
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
        [MoviePlayer streamMovieAtPath:[NSString stringWithFormat:@"https://put.io/v2/files/%@/stream", _file.id] withFile:_file];
    }else{
        [MoviePlayer streamMovieAtPath:[NSString stringWithFormat:@"https://put.io/v2/files/%@/mp4/stream", _file.id] withFile:_file];
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
    return ([LocalFile localFileExists:_file])? @"Other App" : @"Download";
}

- (void)secondaryButtonAction:(id)sender {
    if ([LocalFile localFileExists:_file]) {
        NSLog(@"found existing local file");
        [self sendVideoToOtherAppWithFilePath:[LocalFile localPathForMovieWithFile:_file]];
        return;
    }

    if([self deviceHasEnoughSpace]){
        if ([UIDevice isPad]) {
            self.infoController.additionalInfoLabel.text = @"Downloading - You can close this popover and it will download as long as you are in the app.";
        } else {
            self.infoController.additionalInfoLabel.text = @"Downloading - Popover can be closed, but not the app.";
        }
        [self getSubtitleInfo];
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

- (NSString *)localPathForFileWithExtension:(NSString *)extension {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:_file.id];
    return [NSString stringWithFormat:@"%@.%@", filePath, extension];
}

- (void)downloadFile {
    NSString *requestURL = nil;
    if (_isMP4) {
        requestURL = [NSString stringWithFormat:@"https://put.io/v2/files/%@/download", _file.id];   
    }else{
        requestURL = [NSString stringWithFormat:@"https://put.io/v2/files/%@/mp4/download", _file.id];   
    }

    [self downloadScreenshot];
    [self downloadSubtitles];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];

    NSString *localMP4Path = [self localPathForFileWithExtension:@"mp4"];
    
    [self downloadFileAtAddress:requestURL to:localMP4Path backgroundable:YES withCompletionBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

        // This'll store the text file
        [LocalFile finalizeFile:_file];

        if (self.infoController) {
            // Set the UI state
            self.infoController.additionalInfoLabel.text = @"Downloaded - It's in your media library!";
            [self.infoController enableButtons];
            [self.infoController hideProgress];

            [self setupSecondaryButton];

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

- (void)downloadScreenshot {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_file.screenshot]];
    AFHTTPRequestOperation *screenShotOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [screenShotOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSString *screenShotPath = [self localPathForFileWithExtension:@"jpg"];
        [operation.responseData writeToFile:screenShotPath atomically:YES];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"screenshot op died");
    }];
    [screenShotOperation start];
}

#pragma mark -
#pragma mark Subtitles

- (void)getSubtitleInfo {
    _subtitleDownloader = [[OROpenSubtitleDownloader alloc] init];

    NSString *subtitleLanguage = [[NSUserDefaults standardUserDefaults] objectForKey:ORSubtitleLanguageDefault];
    // we always have a prefix comma in the default

    if (subtitleLanguage.length == 0) {
        return;
    }

    if (!subtitleLanguage) {
        subtitleLanguage = @",eng";
    }
    _subtitleDownloader.languageString = [subtitleLanguage substringFromIndex:1];
    _subtitleDownloader.delegate = self;
}

- (void)openSubtitlerDidLogIn:(OROpenSubtitleDownloader *)downloader {
    [_subtitleDownloader searchForSubtitlesWithHash:_file.opensubtitlesHash andFilesize:_file.size :^(NSArray *subtitles) {
        _subtitleResults = subtitles;
    }];
}

- (void)downloadSubtitles {
    if (_subtitleResults.count) {
        NSString *srtPath = [self localPathForFileWithExtension:@"srt"];
        [_subtitleDownloader downloadSubtitlesForResult:_subtitleResults[0] toPath:srtPath :^ {
            NSLog(@"downloaded");
        }];
    }
}

- (void)getMP4Info {
    if (_file == nil) {
        NSLog(@"getting info for nil");
        return;
    }
    if(_hidden) return;
    
    [[PutIOClient sharedClient] getMP4InfoForFile:_file :^(PKMP4Status *status) {
        NSLog(@"Status %@", status);
            
        switch (status.mp4Status) {
                
            case PKMP4StatusCompleted:
                [self.infoController enableButtons];
                [self.infoController hideProgress];
                break;

            case PKMP4StatusQueued:
                self.infoController.additionalInfoLabel.text = [NSString stringWithFormat:@"Request for an %@ version has been recieved and is queued, this could take a while.", [UIDevice deviceString]];
                if(!_addedProcess){
                    [ConvertToMP4Process processWithFile:_file];
                    _addedProcess = YES;
                }
                [self performSelector:@selector(getMP4Info) withObject:self afterDelay:2];

                break;
                
            case PKMP4StatusConverting:
                self.infoController.additionalInfoLabel.text = [NSString stringWithFormat:@"Converting to %@ version right now.", [UIDevice deviceString]];

                if (status.progress) {
                    [self.infoController showProgress];
                    self.infoController.progressView.progress = status.progress.integerValue / 100;
                }
                [self performSelector:@selector(getMP4Info) withObject:self afterDelay:2];


            case PKMP4StatusNotAvailable:{
                if (!_requested) {
                    _requested = YES;
                    [[PutIOClient sharedClient] requestMP4ForFile:_file :^(PKMP4Status *status) {
                        [self performSelector:@selector(getMP4Info) withObject:self afterDelay:2];
                        [ConvertToMP4Process processWithFile:_file];
                        _addedProcess = YES;
                        
                    } failure:^(NSError *error) {
                        ARLog(@"Error requesting MP4Status");
                    }];
                }
                self.infoController.additionalInfoLabel.text = [NSString stringWithFormat:@"Requesting an %@ version.", [UIDevice deviceString]];
                [self performSelector:@selector(getMP4Info) withObject:self afterDelay:2];
                break;
            }
            default:
                self.infoController.additionalInfoLabel.text = [NSString stringWithFormat:@"Converting for %@ has failed.", [UIDevice deviceString]];
                [self.infoController disableButtons];
                break;
        }

        [self setupSecondaryButton];
    } failure:^(NSError *error) {
        [self performSelector:@selector(getMP4Info) withObject:self afterDelay:2];
    }];
    
}

- (void)viewWillDissapear {
    _hidden = YES;
}


#pragma mark -
#pragma mark Document related stuff

- (void)sendVideoToOtherAppWithFilePath:(NSString *)downloadedFilepath {
    NSURL *downloadURL = [NSURL fileURLWithPath:downloadedFilepath isDirectory:NO];
    _docController = [UIDocumentInteractionController interactionControllerWithURL:downloadURL];
    _docController.delegate = self;

    UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    CGRect rect = [rootView convertRect:self.infoController.secondaryButton.frame fromView:self.infoController.view];
    [_docController presentOpenInMenuFromRect:rect inView:rootView animated:YES];
}

- (BOOL)canOpenDocumentWithFilePath:(NSString *)path inView:(UIView*)view {
    if (!view.window) return NO;
    
    BOOL canOpen = NO;
    UIDocumentInteractionController* docController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:path]];
    if (docController) {
        docController.delegate = self;
        canOpen = [docController presentOpenInMenuFromRect:CGRectMake(0, 0, 1, 1) inView:view animated:NO];
        [docController dismissMenuAnimated:NO];
    }
    return canOpen;
}


-(void)documentInteractionController:(UIDocumentInteractionController *)controller
       willBeginSendingToApplication:(NSString *)application {
    self.infoController.additionalInfoLabel.text = [NSString stringWithFormat:@"Sending file to %@", application];
    [self markFileAsViewed];
}

@end
