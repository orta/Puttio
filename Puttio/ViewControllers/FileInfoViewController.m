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

@interface FileInfoViewController() {
    id _item;
    NSString *streamPath;
    BOOL stopRefreshing;
}
@end


@implementation FileInfoViewController 
@synthesize titleLabel;
@synthesize additionalInfoLabel;
@synthesize streamButton;
@synthesize thumbnailImageView;
@synthesize progressView;
@dynamic item;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    streamButton.enabled = NO;
    progressView.hidden = YES;
}

- (void)setItem:(id)item {
    if (![item conformsToProtocol:@protocol(ORDisplayItemProtocol)]) {
        [NSException raise:@"File Info item should conform to ORDisplayItemProtocol" format:@"File Info item should conform to ORDisplayItemProtocol"];
    }
    NSObject <ORDisplayItemProtocol> *object = item;
    titleLabel.text = object.name;
    _item = item;
    additionalInfoLabel.text = object.description;
    [thumbnailImageView setImageWithURL:[NSURL URLWithString:[object.iconURL stringByReplacingOccurrencesOfString:@"shot/" withString:@"shot/b/"]]];
    if ([object.contentType isEqualToString:@"video/mp4"]) {
        [[PutIOClient sharedClient] getInfoForFile:_item :^(id userInfoObject) {
            if (![userInfoObject isMemberOfClass:[NSError class]]) {
                streamPath = [[userInfoObject valueForKey:@"stream_url"] objectAtIndex:0];
                streamButton.enabled = YES;
            }
        }];
    }else{
        [self getMP4Info];        
    }
}

- (void)getMP4Info {
    [[PutIOClient sharedClient] getMP4InfoForFile:_item :^(id userInfoObject) {
        if (![userInfoObject isMemberOfClass:[NSError class]]) {
            streamPath = [userInfoObject valueForKeyPath:@"mp4.stream_url"];
            if (streamPath) {
                streamButton.enabled = YES;
            }else{
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
    [super viewDidUnload];
}

- (IBAction)backButton:(id)sender {
    
}

- (IBAction)streamButton:(id)sender {
    if (streamPath) {
        [MoviePlayer streamMovieAtPath:streamPath];
    }
}
@end
