//
//  ORPasteboardParser.m
//  Puttio
//
//  Created by orta therox on 08/11/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ORPasteboardParser.h"

@implementation ORPasteboardParser

+ (NSSet *)submitableURLsInPasteboard {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSMutableSet *objects = [NSMutableSet setWithArray:pasteboard.strings];
    NSMutableSet *urlsToSubmit = [NSMutableSet set];
    
    [objects addObjectsFromArray:pasteboard.URLs];

    for (id object in objects.allObjects) {
        NSString *url = object;
        if ([object isMemberOfClass:[NSURL class]]) {
            url = [object absoluteString];
        }

        if ([url rangeOfString:@"magnet"].location != NSNotFound) {
            [urlsToSubmit addObject:url];
        }
        else if ([url rangeOfString:@".torrent"].location != NSNotFound){
            [urlsToSubmit addObject:url];
        }
    }

    if(urlsToSubmit.count){
        return urlsToSubmit;
    } else {
        return nil;
    }
}

@end
