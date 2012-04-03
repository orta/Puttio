//
//  Transfer.h
//  Puttio
//
//  Created by orta therox on 01/04/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Transfer : NSObject

@property (strong) NSNumber* estimatedTime;
@property (strong) NSString* name;
@property (strong) NSNumber* percentDone;
@property (strong) NSNumber* downloadSpeed;

@end
