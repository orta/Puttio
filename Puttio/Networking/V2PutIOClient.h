//
//  V2PutIOClient.h
//  Puttio
//
//  Created by orta therox on 24/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "AFNetworking.h"

@interface V2PutIOClient : AFHTTPClient

+ (id)setup;
- (BOOL)ready;

- (void)getFolderWithID:(NSString*)folderID :(void(^)(id userInfoObject))onComplete;
@end
