//
//  MoviePlayer.h
//  Puttio
//
//  Created by orta therox on 27/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface MoviePlayer : NSObject 
@property (strong) MPMoviePlayerController *mediaPlayer;

+ (void)streamMovieAtPath:(NSString *)path;
+ (MoviePlayer *)sharedPlayer;
@end
