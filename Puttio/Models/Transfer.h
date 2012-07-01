//
//  Transfer.h
//  Puttio
//
//  Created by orta therox on 01/04/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Transfer : NSObject

typedef enum {
    TransferStatusOK,
    TransferStatusERROR
} TransferStatus;


@property (strong) NSNumber* estimatedTime;
@property (strong) NSString* name;
@property (strong) NSString* createdAt;
@property (strong) NSNumber* percentDone;
@property (strong) NSNumber* downloadSpeed;
@property (strong) NSString* displayName;
@property (assign) TransferStatus status;
@end
