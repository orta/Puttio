//
//  NSDictionary+ObjectForKey.m
//  Puttio
//
//  Created by orta therox on 07/04/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "NSDictionary+ObjectForKey.h"

@implementation NSDictionary (ObjectForKey)

- (NSString *)onlyStringForKey:(NSString *)key {
    id object = [self objectForKey:key];
    if ([[object class] isSubclassOfClass:[NSString class]]) {
        return object;
    }
    return nil;
}

- (NSDictionary *)onlyDictionaryForKey:(NSString *)key {
    id object = [self objectForKey:key];
    if ([[object class] isSubclassOfClass:[NSDictionary class]]) {
        return object;
    }
    return nil;
}

- (NSArray *)onlyArrayForKey:(NSString *)key {
    id object = [self objectForKey:key];
    if ([[object class] isSubclassOfClass:[NSArray class]]) {
        return object;
    }
    return nil;
}

- (NSDecimalNumber *)onlyDecimalForKey:(NSString *)key {
    id object = [self objectForKey:key];
    if ([[object class] isSubclassOfClass:[NSDecimalNumber class]]) {
        return object;
    }
    // could still be a string
    if ([[object class] isSubclassOfClass:[NSString class]]) {
        return [NSDecimalNumber decimalNumberWithString:object];
    }
    return nil;
}

- (id)objectForKeyNotNull:(id)key {
    id object = [self objectForKey:key];
    if (object == [NSNull null])
        return nil;
    
    return object;
}
@end
