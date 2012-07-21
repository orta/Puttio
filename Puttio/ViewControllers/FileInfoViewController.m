//
//  FileInfoViewController.m
//  Puttio
//
//  Created by orta therox on 01/04/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "FileInfoViewController.h"
#import "UIImageView+AFNetworking.h"
#import "AFHTTPClient.h"

// File Controllers
#import "VideoFileController.h"
#import "UnknownFileController.h"

@interface FileInfoViewController() {
    NSArray *fileControllers;
    NSObject <FileController>*fileController;
    
    File *_item;
    BOOL fileDownloaded;
    BOOL stopRefreshing;
}
@end


@implementation FileInfoViewController 
@synthesize titleLabel;
@synthesize additionalInfoLabel;
@synthesize fileSizeLabel;
@synthesize primaryButton;
@synthesize secondaryButton;
@synthesize thumbnailImageView;
@synthesize progressView;
@dynamic item;

- (void)viewDidLoad {
    [super viewDidLoad];
    fileSizeLabel.text = @"";
    titleLabel.text = @"";
    additionalInfoLabel.text = @"";

    primaryButton.alpha = 0;
    secondaryButton.alpha = 0;
    fileSizeLabel.alpha = 0;
    additionalInfoLabel.alpha = 0;

    progressView.isLandscape = YES;
    progressView.alpha = 0;
    progressView.progress = 0;

    if ([UIDevice isPhone]) {
        CGRect imageFrame = thumbnailImageView.frame;
        imageFrame.origin.y = 0;
    }
}

- (void)setItem:(File *)item {
    if (![item conformsToProtocol:@protocol(ORDisplayItemProtocol)]) {
        [NSException raise:@"File Info item should conform to ORDisplayItemProtocol" format:@"File Info item should conform to ORDisplayItemProtocol"];
    }

    fileControllers = @[[VideoFileController class], [UnknownFileController class]];
    for (Class <FileController> klass in fileControllers) {
        if ([klass fileSupportedByController: item]) {
            fileController = [klass controller];
            break;
        }
    }
        
    NSObject <ORDisplayItemProtocol> *object = item;
    
    fileController.infoController = self;
    fileController.file = (File*)object;
    
    titleLabel.text = object.displayName;
    _item = item;
    [thumbnailImageView setImageWithURL:[NSURL URLWithString:[PutIOClient appendOauthToken:object.screenShotURL]]];
    additionalInfoLabel.text = [fileController descriptiveTextForFile];
    
    [primaryButton setTitle:[fileController primaryButtonText] forState:UIControlStateNormal];

    secondaryButton.hidden = ![fileController supportsSecondaryButton]; 
    [secondaryButton setTitle:[fileController secondaryButtonText] forState:UIControlStateNormal];
}

- (id)item {
    return _item;
}

- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setThumbnailImageView:nil];
    [self setAdditionalInfoLabel:nil];
    [self setPrimaryButton:nil];
    [self setProgressView:nil];
    stopRefreshing = YES;
    [self setFileSizeLabel:nil];
    [self setSecondaryButton:nil];
    [super viewDidUnload];
}

- (IBAction)primaryButtonTapped:(id)sender {
    [fileController primaryButtonAction:sender];
}

- (IBAction)secondaryButtonTapped:(id)sender {
    [fileController secondaryButtonAction:sender];
}

- (void)setProgressInfoHidden:(BOOL)hidden {
    self.progressView.hidden = hidden;
    self.progressView.progress = 0;    
}

- (void)enableButtons {
    primaryButton.enabled = YES;
    secondaryButton.enabled = YES;
    primaryButton.alpha = 1;
    secondaryButton.alpha = 1;
}

- (void)disableButtons {
    primaryButton.enabled = NO;
    secondaryButton.enabled = NO;
    primaryButton.alpha = 0.5;
    secondaryButton.alpha = 0.5;
}

- (void)showProgress {
    progressView.progress = 0;
    if (progressView.alpha == 0) {
        [UIView animateWithDuration:0.3 animations:^{
            progressView.alpha = 1;
        }];
    }
    [self disableButtons];
}

- (void)hideProgress {
    progressView.alpha = 0;
}

- (void)zoomViewDidFinishZooming:(ModalZoomView *)zoomView {
    [UIView animateWithDuration:0.3 animations:^{
        primaryButton.alpha = 1;
        secondaryButton.alpha = 1;
        fileSizeLabel.alpha = 1;
        additionalInfoLabel.alpha = 1;
    }];    
}

- (void)zoomViewWillDissapear:(ModalZoomView *)zoomView {
    [fileController viewWillDissapear];
    [UIView animateWithDuration:0.1 animations:^{
        primaryButton.alpha = 0;
        secondaryButton.alpha = 0;
        fileSizeLabel.alpha = 0;
        additionalInfoLabel.alpha = 0;
        progressView.alpha = 0;
    }];
}
@end
