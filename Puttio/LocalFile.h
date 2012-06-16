//
//  LocalFile.h
//  Puttio
//
//  Created by David Grandinetti on 6/11/12.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalFile : NSObject <ORDisplayItemProtocol>

@property (strong) NSString *name;
@property (strong) NSString *screenShot;
@property (strong) NSString *filepath;

@end
