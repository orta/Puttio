//
//  MoviePlayer.h
//  Puttio
//
//  Created by orta therox on 27/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@class MoviePlayer;

@protocol MoviePlayerDelegate <NSObject>
- (void)moviePlayer:(MoviePlayer *)player didEndWithError:(NSString *)error;
@end

@interface MoviePlayer : NSObject 
@property  MPMoviePlayerController *mediaPlayer;
@property (weak) id <MoviePlayerDelegate> delegate;

+ (void)streamMovieAtPath:(NSString *)path withFile:(File *)file;
+ (void)watchLocalMovieAtPath:(NSString *)path;
+ (MoviePlayer *)sharedPlayer;
@end
