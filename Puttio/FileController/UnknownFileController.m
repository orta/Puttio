//
//  UnknownFileController.m
//  Puttio
//
//  Created by orta therox on 10/06/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "UnknownFileController.h"
#import "FileInfoViewController.h"
#import "AFNetworking.h"

@interface UnknownFileController (){
    UIDocumentInteractionController *_docController;
    NSString *downloadedFilepath;
}
-(BOOL)canOpenDocumentWithURL:(NSURL*)url inView:(UIView*)view;
@end

@implementation UnknownFileController

+ (BOOL)fileSupportedByController:(File *)aFile {
    return YES;
}


- (void)setFile:(File *)aFile {
    _file = aFile;
    
    [self.infoController showProgress];
    [self.infoController disableButtons];
    NSString *requestURL = [NSString stringWithFormat:@"https://put.io/v2/files/%@/download", _file.id];


    [self downloadFileAtPath:requestURL backgroundable:NO withCompletionBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        downloadedFilepath = [NSTemporaryDirectory() stringByAppendingPathComponent:_file.name];
        [operation.responseData writeToFile:downloadedFilepath atomically:YES];

        NSURL *downloadURL = [NSURL fileURLWithPath:downloadedFilepath isDirectory:NO];
        if ([[NSFileManager defaultManager] fileExistsAtPath:downloadedFilepath]) {
            BOOL canOpen = [self canOpenDocumentWithURL:downloadURL inView:self.infoController.view];
            if (canOpen) {
                self.infoController.primaryButton.enabled = YES;
                [self primaryButtonAction:self.infoController.primaryButton];
            }else{
                self.infoController.additionalInfoLabel.text = @"There isn't an app to open this file";
                self.infoController.additionalInfoLabel.textAlignment = UITextAlignmentCenter;
                self.infoController.primaryButton.hidden = YES;
            }
        }
    } andFailureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.infoController.additionalInfoLabel.text = @"Download has failed";
        [self.infoController hideProgress];
    }];
}

- (File *)file {
    return _file;
}

- (NSString *)descriptiveTextForFile {
    return [NSString stringWithFormat: @"Open %@ in External app", _file.displayName];
}

- (NSString *)primaryButtonText {
    return @"Other App";
}

- (void)primaryButtonAction:(id)sender {
    NSURL *downloadURL = [NSURL fileURLWithPath:downloadedFilepath isDirectory:NO];    
    _docController = [UIDocumentInteractionController interactionControllerWithURL:downloadURL];
    _docController.delegate = self;

    UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    CGRect rect = [rootView convertRect:self.infoController.primaryButton.frame fromView:self.infoController.view];
    [_docController presentOpenInMenuFromRect:rect inView:rootView animated:YES];
}

- (BOOL)supportsSecondaryButton {
    return NO;
}

- (NSString *)secondaryButtonText {
    return @"Download";
}

#pragma mark -
#pragma mark Document related stuff

-(BOOL)canOpenDocumentWithURL:(NSURL*)url inView:(UIView*)view {
    BOOL canOpen = NO;
    UIDocumentInteractionController* docController = [UIDocumentInteractionController interactionControllerWithURL:url];
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
