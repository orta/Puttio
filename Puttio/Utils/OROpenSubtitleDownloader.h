//
//  ORSubtitleDownloader.h
//  Puttio
//
//  Created by orta therox on 08/12/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMLRPC.h"

@class OROpenSubtitleDownloader, OpenSubtitleSearchResult;

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
@property (strong, nonatomic) NSString *languageString;

// Search and get a return block with an array of OpenSubtitleSearchResult
- (void)searchForSubtitlesWithHash:(NSString *)hash andFilesize:(NSNumber *)filesize :(void(^) (NSArray *subtitles))searchResult;

// Download a subtitle result to a file after being unzipped
- (void)downloadSubtitlesForResult:(OpenSubtitleSearchResult *)result toPath:(NSString *)path :(void(^)())onResultsFound;
@end


@interface OpenSubtitleSearchResult : NSObject

+ (OpenSubtitleSearchResult *)resultFromDictionary:(NSDictionary *)dictionary;

@property (copy) NSString *subtitleID;
@property (copy) NSString *subtitleLanguage;
@property (copy) NSString *iso639Language;
@property (copy) NSString *subtitleDownloadAddress;

@end
