//
//  File.h
//  Puttio
//
//  Created by orta therox on 25/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface File : NSManagedObject

@property (strong) NSString *contentType;
@property (strong) NSString *id;
@property (strong) NSString *name;
@property (strong) NSString *size;

@end
