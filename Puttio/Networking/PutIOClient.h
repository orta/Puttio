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
- (void)startup;
- (void)getUserInfo:(void(^)(id userInfoObject))onComplete;
- (void)getRootFolder:(void(^)(id userInfoObject))onComplete;
- (void)getFolderWithID:(NSString*)folderID :(void(^)(id userInfoObject))onComplete;
@end
