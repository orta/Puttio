//
//  ORDisplayItemProtocol.h
//  Puttio
//
//  Created by orta therox on 29/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ORDisplayItemProtocol <NSObject>

@property (nonatomic, retain) NSString *contentType;
@property (nonatomic, retain) NSString *id;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *displayName;
@property (nonatomic, retain) NSNumber *size;
@property (nonatomic, retain) NSString *screenShotURL;
@property (nonatomic, retain) NSString *parentID;

@end
