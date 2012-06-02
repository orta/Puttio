//
//  File.h
//  Puttio
//
//  Created by orta therox on 25/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "ORDisplayItemProtocol.h"

@interface File : NSManagedObject <ORDisplayItemProtocol>

@property (strong) NSString *contentType;
@property (strong) NSString *id;
@property (strong) NSString *name;
@property (strong) NSNumber *size;
@property (strong) NSString *screenShotURL;
@property (strong) NSString *parentID;
@property (strong) NSString *displayName;

- (NSString *)extension;
- (void)setupDisplayName;
@end
