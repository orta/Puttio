//
//  PutIOClient.h
//  Puttio
//
//  Created by orta therox on 22/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "AFHTTPClient.h"

@interface PutIOClient : AFHTTPClient
+ (PutIOClient *)sharedClient;
+ (NSDictionary *)paramsForRequestAtMethod:(NSString *)method withParams:(NSDictionary *)params;

@property(strong) NSString* apiKey;
@property(strong) NSString* apiSecret;
@end
