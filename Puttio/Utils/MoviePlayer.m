//
//  MoviePlayer.m
//  Puttio
//
//  Created by orta therox on 27/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "MoviePlayer.h"
#import "ORAppDelegate.h"
#import "TestFlight.h"
#import "ORMoviePlayerController.h"
#import "ModalZoomView.h"

@interface MoviePlayer (){
    BOOL completed;
}
@end

static NSDate *movieStartedDate;

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
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

    NSNumber* reason = [notification userInfo][MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    switch ([reason intValue]) {
        case MPMovieFinishReasonPlaybackError:
            TFLog(@"playbackFinished. Reason: Playback Error");
            TFLog(@"error log %@", self.mediaPlayer.errorLog);
            TFLog(@"network log %@", self.mediaPlayer.accessLog);
            TFLog(@"note %@", notification);
            
            [Analytics event:@"Movie Playback Error %@ - ( %@ )", self.mediaPlayer.contentURL, self.mediaPlayer.errorLog];
            break;

        case MPMovieFinishReasonPlaybackEnded:
            TFLog(@"playbackFinished. Reason: Playback Ended");
        case MPMovieFinishReasonUserExited:
            TFLog(@"playbackFinished. Reason: User Exited");
            [Analytics incrementUserProperty:@"User Finished Watching a Movie" byInt:1];
            [Analytics event:@"User Finished Watching a Movie"];
            break;
        default:
            break;
    }

    [Analytics event:@"Finished Watching Something" withTimeIntervalSinceDate:movieStartedDate];
    ORAppDelegate *appDelegate = (ORAppDelegate*)[UIApplication sharedApplication].delegate;
    UIViewController *rootController = appDelegate.window.rootViewController;
    [rootController dismissMoviePlayerViewControllerAnimated];
}

+ (void)streamMovieAtPath:(NSString *)path {
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];

    ORAppDelegate *appDelegate = (ORAppDelegate*)[UIApplication sharedApplication].delegate;
    UIViewController *rootController = appDelegate.window.rootViewController;
    MoviePlayer *sharedPlayer = [self sharedPlayer];
    path = [path componentsSeparatedByString:@"/atk"][0];
    NSString *address = [PutIOClient appendStreamToken:path];
    
    ORMoviePlayerController *movieController = [[ORMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:address]];
    [rootController presentMoviePlayerViewControllerAnimated:movieController];

    sharedPlayer.mediaPlayer = movieController.moviePlayer;
    [Analytics incrementUserProperty:@"User Started Watching a Movie" byInt:1];
    [Analytics event:@"User Started Watching a Movie"];
    movieStartedDate = [NSDate date];
}

+ (void)watchLocalMovieAtPath:(NSString *)path {
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    ORAppDelegate *appDelegate = (ORAppDelegate*)[UIApplication sharedApplication].delegate;
    UIViewController *rootController = appDelegate.window.rootViewController;
    MoviePlayer *sharedPlayer = [self sharedPlayer];
    
    ORMoviePlayerController *movieController = [[ORMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:path]];
    [rootController presentMoviePlayerViewControllerAnimated:movieController];
    
    sharedPlayer.mediaPlayer = movieController.moviePlayer;
    [Analytics incrementUserProperty:@"User Started Watching a Movie" byInt:1];
    [Analytics event:@"User Started Watching a Movie"];
    movieStartedDate = [NSDate date];
}


@end
