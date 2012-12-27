//
//  Bookmark.h
//  Puttio
//
//  Created by orta therox on 27/12/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Bookmark : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSDate *lastAccessed;

@end
