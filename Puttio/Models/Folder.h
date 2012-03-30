//
//  Folder.h
//  Puttio
//
//  Created by orta therox on 29/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "ORDisplayItemProtocol.h"

@interface Folder : NSManagedObject <ORDisplayItemProtocol>

@property (strong) NSString *contentType;
@property (strong) NSString *id;
@property (strong) NSString *name;
@property (strong) NSNumber *size;
@property (strong) NSString *iconURL;
@property (strong) NSString *parentID;
@property (strong) Folder *parentFolder;

@end
