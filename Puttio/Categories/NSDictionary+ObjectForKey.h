//
//  NSDictionary+ObjectForKey.h
//  Puttio
//
//  Created by orta therox on 07/04/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (ObjectForKey)

- (NSString *)onlyStringForKey:(NSString *)key;
- (NSDictionary *)onlyDictionaryForKey:(NSString *)key;
- (NSArray *)onlyArrayForKey:(NSString *)key;
- (NSDecimalNumber *)onlyDecimalForKey:(NSString *)key;
- (id)objectForKeyNotNull:(id)key;

@end
