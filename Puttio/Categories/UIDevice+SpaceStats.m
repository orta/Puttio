//
//  UIDevice+SpaceStats.m
//  Puttio
//
//  Created by orta therox on 24/06/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "UIDevice+SpaceStats.h"
#include <sys/param.h>  
#include <sys/mount.h>  

@implementation UIDevice (SpaceStats)

+ (NSString *)humanStringFromBytes:(double)bytes {
    if (bytes < 0) {
        bytes *= -1;
    }
    
    static const char units[] = { '\0', 'k', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y' };
    static int maxUnits = sizeof units - 1;
    
    int multiplier = 1000;
    int exponent = 0;
    
    while (bytes >= multiplier && exponent < maxUnits) {
        bytes /= multiplier;
        exponent++;
    }
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:2];
    // Beware of reusing this format string. -[NSString stringWithFormat] ignores \0, *printf does not.
    return [NSString stringWithFormat:@"%@ %cB", [formatter stringFromNumber: @(bytes)], units[exponent]];
}

+ (double)numberOfBytesFree {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    struct statfs tStats;  
    statfs([[paths lastObject] cString], &tStats);  
    return tStats.f_bavail * tStats.f_bsize;
}

+ (double)numberOfBytesOnDevice {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    struct statfs tStats;  
    statfs([[paths lastObject] cString], &tStats);  
    return tStats.f_blocks * tStats.f_bsize;
}

+ (double)numberOfBytesUsedInDocumentsDirectory {
    NSString *docsDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSArray *paths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:docsDir error:nil];
    
    // the directory itself and the SQLite DB
    if (paths.count == 2) return 0;
    
    double totalSize = 0;
    for (NSString *path in paths) {
        NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:[docsDir stringByAppendingPathComponent:path] error:nil];
        totalSize += [fileInfo[NSFileSize] doubleValue];
    }
    return totalSize;
}

@end

