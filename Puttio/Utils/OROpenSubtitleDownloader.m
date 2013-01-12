//
//  ORSubtitleDownloader.m
//  Puttio
//
//  Created by orta therox on 08/12/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "AFNetworking.h"
#import <zlib.h>

#import "OROpenSubtitleDownloader.h"

static NSString *OROpenSubtitleURL  = @"http://api.opensubtitles.org/";
static NSString *OROpenSubtitlePath = @"xml-rpc";

@interface OROpenSubtitleDownloader(){
    NSString *_authToken;
    NSString *_userAgent;

    NSMutableDictionary *_blockResponses;
}
@end

@implementation OROpenSubtitleDownloader


#pragma mark -
#pragma mark Init

- (OROpenSubtitleDownloader *)init {
    return [self initWithUserAgent:[self generateUserAgent]];
}

- (OROpenSubtitleDownloader *)initWithUserAgent:(NSString *)userAgent {
    self = [super init];
    if (!self) return nil;


    _userAgent = userAgent;
    _blockResponses = [NSMutableDictionary dictionary];
    _state = OROpenSubtitleStateLoggingIn;

    if(!_languageString) {
        // one day, for now no.
        _languageString = @"eng";
    }

    [self login];
    return self;
}

#pragma mark -
#pragma mark API

- (void)setLanguageString:(NSString *)languageString {
    if (!languageString) {
        languageString = @"eng";
    }
    _languageString = languageString;
}

- (void)login {
    // Log in in the background.
    XMLRPCRequest *request = [self generateRequest];
    [request setMethod: @"LogIn" withParameters:@[@"", @"" , @"" , _userAgent]];

    // Start up the xmlrpc engine
    XMLRPCConnectionManager *manager = [XMLRPCConnectionManager sharedManager];
    [manager spawnConnectionWithXMLRPCRequest:request delegate:self];
}

- (void)searchForSubtitlesWithHash:(NSString *)hash andFilesize:(NSNumber *)filesize :(void(^) (NSArray *subtitles))searchResult  {
    XMLRPCRequest *request = [self generateRequest];
    NSDecimalNumber *decimalFilesize = [NSDecimalNumber decimalNumberWithString:filesize.stringValue];
    NSDictionary *params = @{
        @"moviebytesize" : decimalFilesize,
        @"moviehash" : hash,
        @"sublanguageid" : _languageString
    };
    
    [request setMethod:@"SearchSubtitles" withParameters:@[_authToken, @[params] ]];

    NSString *searchHashCompleteID  = [NSString stringWithFormat:@"Search%@Complete", hash];
    [_blockResponses setObject:[searchResult copy] forKey:searchHashCompleteID];

    XMLRPCConnectionManager *manager = [XMLRPCConnectionManager sharedManager];
    [manager spawnConnectionWithXMLRPCRequest:request delegate:self];
}


- (void)downloadSubtitlesForResult:(OpenSubtitleSearchResult *)result toPath:(NSString *)path :(void(^)())onResultsFound {
    // Download the subtitles using the HTTP request method
    // as doing it through XMLRPC was proving unpredictable

    NSURL *url = [NSURL URLWithString:result.subtitleDownloadAddress];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *subtitleDownloadRequest = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];

    [subtitleDownloadRequest setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"subtitle.gzip"];
        [operation.responseData writeToFile:tempPath atomically:YES];
        [self unzipFileAtPath:tempPath toPath:path];

        onResultsFound(path);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"not ok");
    }];
    
    [subtitleDownloadRequest start];
}

#pragma mark -
#pragma mark Utilities

#define ZIP_CHUNK 16384

- (void)unzipFileAtPath:(NSString *)fromPath toPath:(NSString *)toPath {
    gzFile gZipFileRef = gzopen([fromPath UTF8String], "rb");
    FILE *fileRef = fopen([toPath UTF8String], "w");

    unsigned char buffer[ZIP_CHUNK];
    int uncompressedLength;
    while ((uncompressedLength = gzread(gZipFileRef, buffer, ZIP_CHUNK))) {
        if(fwrite(buffer, 1, uncompressedLength, fileRef) != uncompressedLength || ferror(fileRef)) {
            NSLog(@"error writing data");
        }
    }

    fclose(fileRef);
    gzclose(gZipFileRef);
}

- (XMLRPCRequest *)generateRequest {
    NSURL *URL = [NSURL URLWithString: [OROpenSubtitleURL stringByAppendingString:OROpenSubtitlePath]];
    return [[XMLRPCRequest alloc] initWithURL:URL];
}

- (NSString *)generateUserAgent {
    NSString *appVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    NSString *appName    = [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
    NSString *osVersion  = [[UIDevice currentDevice] systemVersion];
    NSString *device     = [[UIDevice currentDevice] model];

    return [NSString stringWithFormat:@"%@ v%@ ( %@ - %@ ) ", appName, appVersion, device, osVersion];
}

#pragma mark -
#pragma mark XMLRPC delegate methods

- (void)request: (XMLRPCRequest *)request didReceiveResponse:(XMLRPCResponse *)response {
    // Nothing will work without a valid user agent.
    NSString *status = response.object[@"status"];
    if ([status isEqualToString:@"414 Unknown User Agent"]) {
        NSLog(@"The user agent used was %@", _userAgent);
        #ifdef DEBUG
        [NSException raise:@"Your app needs a valid user agent" format:@"Your app needs a valid user agent"];
        #else
        NSLog(@"Did not log in with a valid user agent string, cannot get subtitles");
        #endif
        return;
    }

    // Logged in successfully, let the delegate know
    if ([request.method isEqualToString:@"LogIn"]) {
        _authToken = response.object[@"token"];
        _state = OROpenSubtitleStateLoggedIn;

        if (_delegate && [_delegate respondsToSelector:@selector(openSubtitlerDidLogIn:)]) {
            [_delegate openSubtitlerDidLogIn:self];
        }
    }

    // Searched, convert to objects and pass back
    if ([request.method isEqualToString:@"SearchSubtitles"]) {
        _state = OROpenSubtitleStateDownloading;
        NSMutableArray *searchResults = [NSMutableArray array];

        // When we get 0 results data is an NSNumber with 0
        if ([response.object[@"data"] isKindOfClass:[NSArray class]]) {
            for (NSDictionary *dictionary in response.object[@"data"]) {
                [searchResults addObject:[OpenSubtitleSearchResult resultFromDictionary:dictionary]];
            }
        }

        NSString *hash = request.parameters[1][0][@"moviehash"];
        NSString *searchHashCompleteID  = [NSString stringWithFormat:@"Search%@Complete", hash];

        void (^resultsBlock)(NSArray *subtitles) = [_blockResponses objectForKey:searchHashCompleteID];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            resultsBlock(searchResults);
        });
    }
}

- (void)request: (XMLRPCRequest *)request didFailWithError: (NSError *)error {
    NSLog(@"%@ - %@", NSStringFromSelector(_cmd), error.localizedDescription);
}

- (BOOL)request: (XMLRPCRequest *)request canAuthenticateAgainstProtectionSpace: (NSURLProtectionSpace *)protectionSpace {
    return YES;
}

- (void)request: (XMLRPCRequest *)request didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge {
    NSLog(@"%@ - %@", NSStringFromSelector(_cmd), challenge);
}

- (void)request: (XMLRPCRequest *)request didCancelAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge {
    NSLog(@"%@ - %@", NSStringFromSelector(_cmd), challenge);
}


@end


@implementation OpenSubtitleSearchResult

+ (OpenSubtitleSearchResult *)resultFromDictionary:(NSDictionary *)dictionary {
    OpenSubtitleSearchResult *object = [[OpenSubtitleSearchResult alloc] init];

    object.subtitleID = dictionary[@"IDSubtitleFile"];
    object.subtitleLanguage = dictionary[@"SubLanguageID"];
    object.iso639Language = dictionary[@"ISO639"];
    object.subtitleDownloadAddress = dictionary[@"SubDownloadLink"];

    return object;
}

@end

