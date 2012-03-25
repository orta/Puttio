//
//  PutIOClient.h
//  Puttio
//
//  Created by orta therox on 22/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "AFHTTPClient.h"

@interface V1PutIOClient : AFHTTPClient
+ (V1PutIOClient *)sharedClient;
+ (NSDictionary *)paramsForRequestAtMethod:(NSString *)method withParams:(NSDictionary *)params;

// Public API 
- (BOOL)ready;
- (void)getUserInfo:(void(^)(id userInfoObject))onComplete;

@end
