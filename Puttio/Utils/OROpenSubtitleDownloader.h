//
//  ORSubtitleDownloader.h
//  Puttio
//
//  Created by orta therox on 08/12/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenSubtitleSearchResult.h"
#import "XMLRPC.h"

@class OROpenSubtitleDownloader;
typedef enum {
    OROpenSubtitleStateLoggingIn,
    OROpenSubtitleStateLoggedIn,
    OROpenSubtitleStateSearching,
    OROpenSubtitleStateDownloading,
    OROpenSubtitleStateDownloaded
} OROpenSubtitleState;


@protocol OROpenSubtitleDownloaderDelegate <NSObject>
@optional
- (void)openSubtitlerDidLogIn:(OROpenSubtitleDownloader *)downloader;

@end


@interface OROpenSubtitleDownloader : NSObject <XMLRPCConnectionDelegate>

// By using init the object will create it's own user agent based on bundle info
- (OROpenSubtitleDownloader *)init;
- (OROpenSubtitleDownloader *)initWithUserAgent:(NSString *)userAgent;

@property (weak) NSObject <OROpenSubtitleDownloaderDelegate> *delegate;
@property (readonly) OROpenSubtitleState state;

- (void)searchForSubtitlesWithHash:(NSString *)hash andFilesize:(NSNumber *)filesize :(void(^) (NSArray *subtitles))searchResult;
- (void)downloadSubtitlesForResult:(OpenSubtitleSearchResult *)result toPath:(NSString *)path :(void(^)())onResultsFound;

@end
