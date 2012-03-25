//
//  V2PutIOClient.h
//  Puttio
//
//  Created by orta therox on 24/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "RSAPI.h"

@interface V2PutIOClient : RSAPI <RSAPIDelegate>

+ (id)setup;
- (BOOL)ready;
- (void)getFolderAtPath:(NSString*)path :(void(^)(id userInfoObject))onComplete;
@end
