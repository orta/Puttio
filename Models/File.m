//
//  File.m
//  Puttio
//
//  Created by orta therox on 25/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <objc/runtime.h>
#import "File.h"

static char WatchedKey;

@implementation File @end

@implementation PKFile (ORWatched)

- (void)setWatched:(NSNumber *)watched {
    objc_setAssociatedObject(self, &WatchedKey, watched, OBJC_ASSOCIATION_RETAIN);
}

- (NSNumber *)watched {
    return (NSNumber *)objc_getAssociatedObject(self, &WatchedKey);
}

@end

