//
//  PutIOClient.h
//  Puttio
//
//  Created by orta therox on 23/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "AFHTTPClient.h"

@class V1PutIOClient, V2PutIOClient;
@interface PutIOClient : AFHTTPClient
+ (PutIOClient *)sharedClient;

- (BOOL)ready;
- (void)getUserInfo:(void(^)(id userInfoObject))onComplete;
- (void)getFolderAtPath:(NSString*)path :(void(^)(id userInfoObject))onComplete;
@end
