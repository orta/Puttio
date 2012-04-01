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
}
@end


@implementation FileInfoViewController 
@synthesize titleLabel;
@synthesize additionalInfoLabel;
@synthesize streamButton;
@synthesize thumbnailImageView;
@dynamic item;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    streamButton.enabled = NO;
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
    
    
    [[PutIOClient sharedClient] getMP4InfoForFile:_item :^(id userInfoObject) {
        if (![userInfoObject isMemberOfClass:[NSError class]]) {
            NSLog(@"JSON for MP4 - %@", userInfoObject);
            streamPath = [userInfoObject valueForKeyPath:@"mp4.stream_url"];
            if (streamPath) {
                streamButton.enabled = YES;
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
