//
//  Analytics.h
//  Puttio
//
//  Created by orta therox on 01/04/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Analytics : NSObject
+ (void)setup;
+ (void)event:(NSString*)string, ...;
+ (void)event:(NSString *)event withOptionString:(NSString *)message;
+ (void)error:(NSString*)string, ...;
+ (void)addCustomValue:(NSString*)value forKey:(NSString*)key;
@end
