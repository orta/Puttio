//
//  AudioViewController.m
//  Puttio
//
//  Created by orta therox on 31/08/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "AudioViewController.h"
#import "ARTitleLabel.h"
#import "ORFlatButton.h"
#import <AVFoundation/AVFoundation.h>
#import "ORSimpleProgress.h"

@interface SharedAVPlayer : NSObject
+ (SharedAVPlayer*) sharedPlayer;
@property (strong) AVPlayer *audioPlayer;
@property (strong) NSString *itemID;
@end

@implementation SharedAVPlayer
+ (SharedAVPlayer *)sharedPlayer {
    static SharedAVPlayer *_sharedPlayer = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedPlayer = [[self alloc] init];
    });

    return _sharedPlayer;
}
@end


@interface AudioViewController (){
    AVPlayer *_audioPlayer;
}
@property (weak, nonatomic) IBOutlet ORSimpleProgress *progressView;
@property (weak, nonatomic) IBOutlet ARTitleLabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet ORFlatButton *playButton;

@end

@implementation AudioViewController

- (void)setItem:(NSObject<ORDisplayItemProtocol> *)item {

    _item = item;
    self.titleLabel.text = item.displayName;
    _progressView.isLandscape = YES;
    if ([SharedAVPlayer sharedPlayer].audioPlayer) {
        
        if ([[SharedAVPlayer sharedPlayer].itemID isEqualToString:item.id]) {
            _audioPlayer = [SharedAVPlayer sharedPlayer].audioPlayer;
            [self syncProgress];
            [self hookInToAudioPlayer];
            [self updateButtonLabel];
        } else {
            _progressView.progress = 0;
        }
    } else {
      _progressView.progress = 0;
    }
}

- (void)zoomViewWillDissapear:(ModalZoomView *)zoomView {
    _audioPlayer = nil;
}

- (IBAction)playButtonTapped:(UIButton *)sender {
    if (!_audioPlayer) {
        [self start];
    }else {
        if ([_audioPlayer rate]) {
            [_audioPlayer pause];
        } else {
            [_audioPlayer play];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"rate"]) {
        [self updateButtonLabel];
    }
}

- (void)updateButtonLabel {
    if ([_audioPlayer rate]) {
        [_playButton setTitle:@"Pause" forState:UIControlStateNormal];
    }
    else {
        [_playButton setTitle:@"Play" forState:UIControlStateNormal];
    }
}

- (void)start {
    NSString *address = [NSString stringWithFormat:@"https://put.io/v2/files/%@/stream", _item.id];
    NSURL *fileURL = [NSURL URLWithString:[PutIOClient appendOauthToken:address]];

    _audioPlayer = [[AVPlayer alloc] initWithURL:fileURL];
    [self hookInToAudioPlayer];
    [_audioPlayer play];
    
    [SharedAVPlayer sharedPlayer].audioPlayer = _audioPlayer;
    [SharedAVPlayer sharedPlayer].itemID = _item.id;
}

- (void)hookInToAudioPlayer {
    __block AudioViewController *this = self;

    [_audioPlayer addObserver:self forKeyPath:@"rate" options:0 context:nil];
    [_audioPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.1, 100) queue:nil usingBlock:^(CMTime time) {
        if (this) {
            [this syncProgress];
        }
    }];

    [[AVAudioSession sharedInstance] setDelegate: self];
    // Allow the app sound to continue to play when the screen is locked.
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
}

- (void)syncProgress {
    CMTime playerDuration = [[_audioPlayer currentItem] duration];
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration) && (duration > 0)) {
        double time = CMTimeGetSeconds([_audioPlayer currentTime]);
        [_progressView setProgress:time / duration];
    }
}

- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setProgressView:nil];
    [self setSubtitleLabel:nil];
    [self setPlayButton:nil];
    [super viewDidUnload];
}
@end
