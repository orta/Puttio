//
//  FileInfoViewController.m
//  Puttio
//
//  Created by orta therox on 01/04/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "FileInfoViewController.h"
#import "UIImageView+AFNetworking.h"

// File Controllers
#import "VideoFileController.h"

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    primaryButton.enabled = NO;
    progressView.hidden = YES;
    fileSizeLabel.text = @"";
    titleLabel.text = @"";
    additionalInfoLabel.text = @"";
}

- (void)setItem:(File *)item {
    if (![item conformsToProtocol:@protocol(ORDisplayItemProtocol)]) {
        [NSException raise:@"File Info item should conform to ORDisplayItemProtocol" format:@"File Info item should conform to ORDisplayItemProtocol"];
    }
    
    fileControllers = [NSArray arrayWithObjects:[VideoFileController class], nil];
    for (Class <FileController> klass in fileControllers) {
        if ([klass fileSupportedByController: item]) {
            fileController = [klass controller];
        }
    }
    
    NSObject <ORDisplayItemProtocol> *object = item;
    
    fileController.infoController = self;
    fileController.file = object;
    
    titleLabel.text = object.displayName;
    _item = item;
    [thumbnailImageView setImageWithURL:[NSURL URLWithString:[PutIOClient appendOauthToken:object.screenShotURL]]];

    primaryButton.titleLabel.text = [fileController primaryButtonText];
    
    secondaryButton.hidden = ![fileController supportsSecondaryButton]; 
    secondaryButton.titleLabel.text = [fileController secondaryButtonText];
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

- (IBAction)backButton:(id)sender {
    
}

- (IBAction)primaryButtonTapped:(id)sender {
    [fileController primaryButtonAction:sender];
}

- (IBAction)secondaryButtonTapped:(id)sender {
    [fileController secondaryButtonAction:sender];
}

- (void)hideProgressInfo {
    self.progressView.hidden = NO;
    self.progressView.progress = 0;    
}

@end
