//
//  NSFileManager+SkipBackup.m
//  Artsy Folio
//
//  Created by orta therox on 02/08/2012.
//  Copyright (c) 2012 http://art.sy. All rights reserved.
//

#import "NSFileManager+SkipBackup.h"
#include <sys/xattr.h>

@implementation NSFileManager (SkipBackup)

- (void)addSkipBackupAttributeToFileAtPath:(NSString *)filePath {
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        const char* filePathChar =  [filePath fileSystemRepresentation];

        const char* attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 1;

        setxattr(filePathChar, attrName, &attrValue, sizeof(attrValue), 0, 0);
    }else {
        NSLog(@"File does not exist at path : %@ for adding skip backup to", filePath);
    }
}


@end
