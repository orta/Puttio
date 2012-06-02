//
//  ORMoviePlayerController.m
//  Puttio
//
//  Created by orta therox on 15/05/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ORMoviePlayerController.h"
#import <AVFoundation/AVFoundation.h>

@implementation ORMoviePlayerController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.moviePlayer.allowsAirPlay = YES;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    [self.moviePlayer prepareToPlay];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //End recieving events
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
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

@end
