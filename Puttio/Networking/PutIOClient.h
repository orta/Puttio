//
//  PutIOClient.h
//  Puttio
//
//  Created by orta therox on 23/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "AFHTTPClient.h"

@interface PutIOClient : AFHTTPClient
+ (PutIOClient *)sharedClient;

@property(strong) NSString* apiToken;
@end
