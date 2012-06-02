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
#import "ComicFileController.h"

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
    progressView.hidden = YES;
    fileSizeLabel.text = @"";
    titleLabel.text = @"";
    additionalInfoLabel.text = @"";
}

- (void)setItem:(File *)item {
    if (![item conformsToProtocol:@protocol(ORDisplayItemProtocol)]) {
        [NSException raise:@"File Info item should conform to ORDisplayItemProtocol" format:@"File Info item should conform to ORDisplayItemProtocol"];
    }
    
    fileControllers = [NSArray arrayWithObjects:[VideoFileController class], [ComicFileController class], nil];
    for (Class <FileController> klass in fileControllers) {
        if ([klass fileSupportedByController: item]) {
            fileController = [klass controller];
            break;
        }
    }
        
    NSObject <ORDisplayItemProtocol> *object = item;
    
    fileController.infoController = self;
    fileController.file = object;
    
    titleLabel.text = object.displayName;
    _item = item;
    [thumbnailImageView setImageWithURL:[NSURL URLWithString:[PutIOClient appendOauthToken:object.screenShotURL]]];

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
}

- (void)disableButtons {
    primaryButton.enabled = NO;
    secondaryButton.enabled = NO;
}

- (void)showProgress {
    progressView.progress = 0;
    progressView.hidden = NO;
    [self disableButtons];
}

- (void)hideProgress {
    progressView.hidden = YES;    
}


@end
