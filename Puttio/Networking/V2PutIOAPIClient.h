//
//  V2PutIOClient.h
//  Puttio
//
//  Created by orta therox on 24/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "AFNetworking.h"

@class Folder;
@interface V2PutIOAPIClient : AFHTTPClient

+ (id)setup;
- (BOOL)ready;

- (void)getFolder:(Folder*)folder :(void(^)(id userInfoObject))onComplete;
- (void)getInfoForFile:(File*)file :(void(^)(id userInfoObject))onComplete;
- (void)getMP4InfoForFile:(File*)file :(void(^)(id userInfoObject))onComplete;
- (void)requestMP4ForFile:(File*)file;
- (void)getTransfers:(void(^)(id userInfoObject))onComplete;
- (void)downloadTorrentOrMagnetURLAtPath:(NSString *)path :(void(^)(id userInfoObject))onComplete;
@end
