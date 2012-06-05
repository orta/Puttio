//
//  WatchedList.h
//  Puttio
//
//  Created by orta therox on 05/06/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WatchedItem;

@interface WatchedList : NSManagedObject

@property (nonatomic, retain) NSString * folderID;
@property (nonatomic, retain) NSSet *items;
@end

@interface WatchedList (CoreDataGeneratedAccessors)

- (void)addItemsObject:(WatchedItem *)value;
- (void)removeItemsObject:(WatchedItem *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
