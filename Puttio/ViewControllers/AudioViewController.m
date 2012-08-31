//
//  AudioViewController.m
//  Puttio
//
//  Created by orta therox on 31/08/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "AudioViewController.h"
#import "ARTitleLabel.h"
#import <AVFoundation/AVFoundation.h>

@interface AudioViewController (){
    AVPlayer *_audioPlayer;
}

@property (weak, nonatomic) IBOutlet ARTitleLabel *titleLabel;

@end

@implementation AudioViewController

- (IBAction)closeButtonTapped:(id)sender {
    [ModalZoomView fadeOutViewAnimated:YES];
}

- (IBAction)playButtonTapped:(id)sender {
    NSString *address = [NSString stringWithFormat:@"https://put.io/v2/files/%@/stream", _item.id];
    NSURL *fileURL = [NSURL URLWithString:[PutIOClient appendOauthToken:address]];

    _audioPlayer = [[AVPlayer alloc] initWithURL:fileURL];
    [_audioPlayer play];
}

- (void)setItem:(NSObject<ORDisplayItemProtocol> *)item {
    _item = item;
    self.titleLabel.text = item.displayName;
}

- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [super viewDidUnload];
}
@end
