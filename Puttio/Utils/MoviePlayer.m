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
#import "BrowsingViewController.h"
#import "LocalBrowsingViewController.h"

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
    self.mediaPlayer = nil;

    NSNumber* reason = [notification userInfo][MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    switch ([reason intValue]) {
        case MPMovieFinishReasonPlaybackError: {
            NSLog(@"playbackFinished. Reason: Playback Error");
            NSLog(@"error log %@", self.mediaPlayer.errorLog);
            NSLog(@"network log %@", self.mediaPlayer.accessLog);
            NSLog(@"note %@", notification);
            
            NSDictionary *notificationDict = [notification userInfo];
            NSError *error = [notificationDict objectForKey:@"error"];

            [_delegate moviePlayer:self didEndWithError:error.localizedDescription];
            [Analytics event:@"Movie Playback Error"];
            
            break;
        }
        case MPMovieFinishReasonPlaybackEnded:
        case MPMovieFinishReasonUserExited:
            TFLog(@"playbackFinished. Reason: Playback Ended");
            [Analytics incrementUserProperty:@"User Finished Watching a Movie" byInt:1];
            [Analytics event:@"User Finished Watching a Movie"];
            break;
        default:
            break;
    }

    // post a notification saying how long the movie lasted
    NSTimeInterval minutes = [[NSDate date] timeIntervalSinceDate:movieStartedDate];
    minutes = floorf(minutes / 60);

    [Analytics event:@"Finished Watching Something" withTimeIntervalSinceDate:movieStartedDate];
    ORAppDelegate *appDelegate = (ORAppDelegate*)[UIApplication sharedApplication].delegate;
    UIViewController *rootController = appDelegate.window.rootViewController;
    
    [rootController dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:ORVideoFinishedNotification object:nil userInfo:@{ ORVideoDurationKey : @(minutes) }];
    }];
}

+ (void)streamMovieAtPath:(NSString *)path withFile:(File *)file {
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];

    ORAppDelegate *appDelegate = (ORAppDelegate*)[UIApplication sharedApplication].delegate;
    UINavigationController *rootNav = (UINavigationController *)appDelegate.window.rootViewController;
    BrowsingViewController *canvas = (BrowsingViewController *)rootNav.topViewController;

    MoviePlayer *sharedPlayer = [self sharedPlayer];
    path = [PutIOClient appendOauthToken:path];

    [[NSNotificationCenter defaultCenter] postNotificationName:ORVideoStartedNotification object:nil userInfo:nil];

    ORMoviePlayerController *movieController = [[ORMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:path]];
    movieController.file = file;
    
    [canvas presentMoviePlayerViewControllerAnimated:movieController];

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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ORVideoStartedNotification object:nil userInfo:nil];


    ORMoviePlayerController *movieController = [[ORMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:path]];

    // SRT Support
    NSString *srtFilePath = [path stringByReplacingOccurrencesOfString:@".mp4" withString:@".srt"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:srtFilePath]) {
        NSError *error = nil;
        NSString *stringSRT = [NSString stringWithContentsOfFile:srtFilePath encoding:NSASCIIStringEncoding error:&error];
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        }
        movieController.currentSubtitles = [[SubRip alloc] initWithString:stringSRT];
    }

    [rootController presentMoviePlayerViewControllerAnimated:movieController];
    
    sharedPlayer.mediaPlayer = movieController.moviePlayer;
    [Analytics incrementUserProperty:@"User Started Watching a Movie" byInt:1];
    [Analytics event:@"User Started Watching a Movie"];
    movieStartedDate = [NSDate date];
}


@end
