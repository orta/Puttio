//
//  PutIOClient.h
//  Puttio
//
//  Created by orta therox on 23/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "AFHTTPClient.h"

@class V1PutIOAPIClient, V2PutIOAPIClient, Folder, File;
@interface PutIOClient : AFHTTPClient
+ (PutIOClient *)sharedClient;

- (BOOL)ready;
- (void)startup;


+ (NSString *)appendOauthToken:(NSString *)inputURL;
+ (NSString *)appendStreamToken:(NSString *)inputURL;

- (void)getUserInfo:(void(^)(id userInfoObject))onComplete;
- (void)getFolder:(Folder *)folder :(void(^)(id userInfoObject))onComplete;
- (void)getInfoForFile:(File *)file :(void(^)(id userInfoObject))onComplete;
- (void)getMP4InfoForFile:(File *)file :(void(^)(id userInfoObject))onComplete;
- (void)requestMP4ForFile:(File*)file;
- (void)getTransfers:(void(^)(id userInfoObject))onComplete;
- (void)getMessages:(void(^)(id userInfoObject))onComplete;
- (void)downloadTorrentOrMagnetURLAtPath:(NSString *)path :(void(^)(id userInfoObject))onComplete;
@end
