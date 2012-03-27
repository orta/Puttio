//
//  MoviePlayer.m
//  Puttio
//
//  Created by orta therox on 27/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "MoviePlayer.h"
#import "ORAppDelegate.h"

@implementation MoviePlayer
@synthesize mediaPlayer;

+ (MoviePlayer *)sharedPlayer {
    static MoviePlayer *_sharedPlayer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedPlayer = [[MoviePlayer alloc] init];
    });
    
    return _sharedPlayer;
}

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterFullscreen:) name:MPMoviePlayerWillEnterFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willExitFullscreen:) name:MPMoviePlayerWillExitFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enteredFullscreen:) name:MPMoviePlayerDidEnterFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitedFullscreen:) name:MPMoviePlayerDidExitFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    return self;
}
- (void)willEnterFullscreen:(NSNotification*)notification {
//    NSLog(@"willEnterFullscreen");
}

- (void)enteredFullscreen:(NSNotification*)notification {
//    NSLog(@"enteredFullscreen");
}

- (void)willExitFullscreen:(NSNotification*)notification {
//    NSLog(@"willExitFullscreen");
}

- (void)exitedFullscreen:(NSNotification*)notification {
//    NSLog(@"exitedFullscreen");
    [self.mediaPlayer.view removeFromSuperview];
    self.mediaPlayer = nil;
}

- (void)playbackFinished:(NSNotification*)notification {
    NSNumber* reason = [[notification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    switch ([reason intValue]) {
        case MPMovieFinishReasonPlaybackEnded:
            NSLog(@"playbackFinished. Reason: Playback Ended");         
            break;
        case MPMovieFinishReasonPlaybackError:
            NSLog(@"playbackFinished. Reason: Playback Error");
            NSLog(@"error log %@", self.mediaPlayer.errorLog);
            break;
        case MPMovieFinishReasonUserExited:
            NSLog(@"playbackFinished. Reason: User Exited");
            break;
        default:
            break;
    }
    [self.mediaPlayer setFullscreen:NO animated:YES];
}

+ (void)streamMovieAtPath:(NSString *)path {
    
    ORAppDelegate *appDelegate = (ORAppDelegate*)[UIApplication sharedApplication].delegate;
    UIViewController *rootController = appDelegate.window.rootViewController;
    MoviePlayer *sharedPlayer = [self sharedPlayer];
    
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:ORStreamTokenDefault];
    
    NSString* address= [NSString stringWithFormat:@"%@/atk/%@", path, token];
    NSLog(@" %@  <- this will open in quicktime mac!", address);
    
    MPMoviePlayerController *movieController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:address]];
    movieController.controlStyle = MPMovieControlStyleDefault;
    movieController.shouldAutoplay = YES;
    movieController.view.frame = rootController.view.bounds;
    [rootController.view addSubview:movieController.view];
//    [movieController play];
    [movieController setFullscreen:YES animated:YES];

    sharedPlayer.mediaPlayer = movieController;
}


@end
