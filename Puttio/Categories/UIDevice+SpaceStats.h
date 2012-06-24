//
//  UIDevice+SpaceStats.h
//  Puttio
//
//  Created by orta therox on 24/06/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (SpaceStats)

+ (NSString *)humanStringFromBytes:(double)bytes;
+ (double)numberOfBytesFree;
+ (double)numberOfBytesOnDevice;
+ (double)numberOfBytesUsedInDocumentsDirectory;

@end
