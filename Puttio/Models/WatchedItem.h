//
//  WatchedItem.h
//  Puttio
//
//  Created by orta therox on 05/06/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WatchedList;

@interface WatchedItem : NSManagedObject

@property (nonatomic, retain) NSString *fileID;
@property (nonatomic, retain) WatchedList *list;

@end
