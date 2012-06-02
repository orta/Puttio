//
//  ORDisplayItemProtocol.h
//  Puttio
//
//  Created by orta therox on 29/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ORDisplayItemProtocol <NSObject>

@property (strong) NSString *contentType;
@property (strong) NSString *id;
@property (strong) NSString *name;
@property (strong) NSString *displayName;
@property (strong) NSNumber *size;
@property (strong) NSString *screenShotURL;
@property (strong) NSString *parentID;

@end
