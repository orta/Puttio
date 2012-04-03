//
//  PutIOClient.h
//  Puttio
//
//  Created by orta therox on 22/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "AFHTTPClient.h"

@interface V1PutIOAPIClient : AFHTTPClient
+ (V1PutIOAPIClient *)sharedClient;
+ (NSDictionary *)paramsForRequestAtMethod:(NSString *)method withParams:(NSDictionary *)params;

// Public API 
- (BOOL)ready;
- (void)getStreamToken;
- (void)getUserInfo:(void(^)(id userInfoObject))onComplete;
- (void)getFolderWithID:(NSString *)folderID :(void(^)(id userInfoObject))onComplete;
- (void)getInfoForFile:(File *)file :(void(^)(id userInfoObject))onComplete;
- (void)getMessages:(void(^)(id userInfoObject))onComplete;
@end
