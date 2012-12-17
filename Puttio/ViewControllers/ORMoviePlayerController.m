//
//  ORMoviePlayerController.m
//  Puttio
//
//  Created by orta therox on 15/05/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ORMoviePlayerController.h"
#import <AVFoundation/AVFoundation.h>

// Its worth noting that MPMobviewPlayerController is a view on the sim, and a window on the device

@implementation ORMoviePlayerController {
    OROpenSubtitleDownloader *_subtitleDownloader;
    NSArray *_subtitleResults;
    NSTimer *_subtitlesTimer;

    NSInteger _subtitlesIndex;
    UILabel *_subtitlesLabel;
    UIButton *_ccButton;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(airplayActiveDidChange) name:MPMoviePlayerIsAirPlayVideoActiveDidChangeNotification object:nil];

    self.moviePlayer.allowsAirPlay = YES;
    self.moviePlayer.fullscreen = YES;
    self.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    [self.moviePlayer prepareToPlay];
}

- (void)setFile:(File *)file {
    _file = file;

    _subtitleDownloader = [[OROpenSubtitleDownloader alloc] init];
    _subtitleDownloader.delegate = self;
}

- (void)openSubtitlerDidLogIn:(OROpenSubtitleDownloader *)downloader {
    [_subtitleDownloader searchForSubtitlesWithHash:_file.opensubtitlesHash andFilesize:_file.size :^(NSArray *subtitles) {
        
        _subtitleResults = subtitles;
        if (subtitles.count) {
            NSLog(@"subtitles found!");
            [self displayCCLogo];
        } else {
            NSLog(@"No subtitles found!");
        }
    }];
}

- (void)displayCCLogo {
    if (_ccButton) return;
    NSLog(@"%@ - %@", NSStringFromSelector(_cmd), self);
    
    _ccButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_ccButton setImage:[UIImage imageNamed:@"CCLogo"] forState:UIControlStateNormal];

    [_ccButton addTarget:self action:@selector(toggleCCView) forControlEvents:UIControlEventTouchUpInside];
    _ccButton.alpha = 0;

    UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;

    NSArray *windows = [[UIApplication sharedApplication] windows];
    UIWindow *mpw = [windows objectAtIndex:0];
    [self viewWillLayoutSubviews];
    [rootView addSubview:_ccButton];
    
    [UIView animateWithDuration:0.3 animations:^{
        _ccButton.alpha = 1;
    }];
}

- (void)toggleCCView {
    NSLog(@"%@ - %@", NSStringFromSelector(_cmd), self);
    if (!_subtitlesLabel) {
        [self addSubtitleView];
        [self getSubtitles];
    }
    
    [UIView animateWithDuration:0.15 animations:^{
        _subtitlesLabel.alpha = !_subtitlesLabel.alpha;
    }];
}

- (void)getSubtitles {
    NSString *srtPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"subtitles.srt"];

    [_subtitleDownloader downloadSubtitlesForResult:_subtitleResults[_subtitlesIndex] toPath:srtPath :^(NSString *pathForDownloadedFile) {
        NSString *stringSRT = [NSString stringWithContentsOfFile:pathForDownloadedFile encoding:NSASCIIStringEncoding error:nil];
        self.currentSubtitles = [[SubRip alloc] initWithString:stringSRT];
    }];
}

- (void)addSubtitleView {
    CGRect subsFrame = self.view.bounds;
    subsFrame.size.height = 44;
    subsFrame.origin.y = CGRectGetHeight(self.view.bounds) - subsFrame.size.height;

    _subtitlesLabel = [[UILabel alloc] initWithFrame: subsFrame];
    _subtitlesLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    _subtitlesLabel.textColor = [UIColor whiteColor];
    _subtitlesLabel.textAlignment = UITextAlignmentCenter;
    _subtitlesLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _subtitlesLabel.numberOfLines = 2;
    _subtitlesLabel.alpha = 0;

    NSArray *windows = [[UIApplication sharedApplication] windows];
    UIWindow *mpw = [windows objectAtIndex:1];
    [mpw addSubview:_subtitlesLabel];
}

- (void)setCurrentSubtitles:(SubRip *)currentSubtitles {
    _currentSubtitles = currentSubtitles;

    if (!_subtitlesTimer) {
        _subtitlesTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(tick) userInfo:nil repeats:YES];
        [_subtitlesTimer fire];
    }
}

- (void)viewWillLayoutSubviews {
    CGRect subsFrame = self.view.bounds;
    subsFrame.size.height = 44;
    subsFrame.origin.y = CGRectGetHeight(self.view.bounds) - subsFrame.size.height;

    _subtitlesLabel.frame = subsFrame;

    if ([UIDevice isPad]) {
        _ccButton.frame = CGRectMake(self.view.bounds.size.width - 66, self.view.bounds.size.height - 66, 44, 44);
    } else {
//
//        _ccButton.transform = CGAffineTransformMakeRotation(M_PI / -2);
  //      _ccButton.frame = CGRectMake(self.view.bounds.size.height - 66, self.view.bounds.size.width - 66, 44, 44);
        _ccButton.frame = CGRectMake(40, 40, 44, 44);
        NSLog(@"%@ - %@", NSStringFromSelector(_cmd), NSStringFromCGRect(_ccButton.frame));
    }
}

- (void)tick {
    NSInteger index = [_currentSubtitles indexOfSubRipItemWithStartTimeInterval:self.moviePlayer.currentPlaybackTime];
    _subtitlesLabel.text = [_currentSubtitles.subtitleItems[index] text];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([UIDevice isPhone]) {
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:YES];

        // Rotate the view for landscape playback
        CGRect newFrame = self.moviePlayer.view.bounds;
        CGFloat width = newFrame.size.width;

        newFrame.size.width = newFrame.size.height;
        newFrame.size.height = width;
        [self.moviePlayer.view setFrame:newFrame];
        [self.moviePlayer.view setTransform:CGAffineTransformMakeRotation(M_PI / -2)];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([UIDevice isPhone]) {
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:YES];
    }
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_subtitlesTimer invalidate];
    [_subtitlesLabel removeFromSuperview];
    [_ccButton removeFromSuperview];

    //End recieving events
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([UIDevice isPhone]) {
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft animated:YES];
    }
    
    return YES;
}

- (BOOL)shouldAutorotate {
    return [UIDevice isPad];
}

- (BOOL)shouldAutomaticallyForwardRotationMethods {
    return YES;
}

//Make sure we can recieve remote control events
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    //if it is a remote control event handle it correctly
    if (event.type == UIEventTypeRemoteControl) {
        if (event.subtype == UIEventSubtypeRemoteControlPlay) {
            [self.moviePlayer play];
        } else if (event.subtype == UIEventSubtypeRemoteControlPause) {
            [self.moviePlayer pause];
        } else if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause) {
            if(self.moviePlayer.playbackState  == MPMoviePlaybackStatePlaying)
                [self.moviePlayer play];
            else
                [self.moviePlayer pause];
        }
    }
}

- (void)airplayActiveDidChange {
    if ( [self.moviePlayer isAirPlayVideoActive] ) {
        [Analytics event:@"Using Airplay"];
        [Analytics incrementUserProperty:@"Using Airplay" byInt:1];
    }
}

@end
