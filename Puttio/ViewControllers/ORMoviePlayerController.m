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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(airplayActiveDidChange) name:MPMoviePlayerIsAirPlayVideoActiveDidChangeNotification object:nil];

    self.moviePlayer.allowsAirPlay = YES;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    [self.moviePlayer prepareToPlay];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([UIDevice isPhone]) {
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];

        // Rotate the view for landscape playback
        CGRect newFrame = self.moviePlayer.view.bounds;
        CGFloat width = newFrame.size.width;

        newFrame.size.width = newFrame.size.height;
        newFrame.size.height = width;
        [self.moviePlayer.view setFrame:newFrame];
        [self.moviePlayer.view setTransform:CGAffineTransformMakeRotation(M_PI / 2)];
    }
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
    NSLog(@"%@ - %@", NSStringFromSelector(_cmd), self);
    
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
