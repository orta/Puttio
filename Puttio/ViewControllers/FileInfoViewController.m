//
//  FileInfoViewController.m
//  Puttio
//
//  Created by orta therox on 01/04/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "FileInfoViewController.h"
#import "UIImageView+AFNetworking.h"
#import "MoviePlayer.h"
#import "FileSizeUtils.h"

@interface FileInfoViewController() {
    File *_item;
    NSString *streamPath;
    NSString *downloadPath;
    NSInteger fileSize;
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
    [thumbnailImageView setImageWithURL:[NSURL URLWithString:[object.iconURL stringByReplacingOccurrencesOfString:@"shot/" withString:@"shot/b/"]]];

    [self getFileInfo];
    [self getMP4Info];        
}

- (void)getFileInfo {
    [[PutIOClient sharedClient] getInfoForFile:_item :^(id userInfoObject) {
        if (![userInfoObject isMemberOfClass:[NSError class]]) {
            streamPath = [[userInfoObject valueForKey:@"stream_url"] objectAtIndex:0];
            downloadPath = [[userInfoObject valueForKeyPath:@"download_url"] objectAtIndex:0]; 
            
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
            streamPath = [userInfoObject valueForKeyPath:@"mp4.stream_url"];
            downloadPath = [userInfoObject valueForKeyPath:@"mp4.download_url"];

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
    if (downloadPath) {
        
    }
}
@end
