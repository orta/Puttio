//
//  NSDictionary+JSON.m
//  Puttio
//
//  Created by orta therox on 22/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "NSDictionary+JSON.h"

@implementation NSDictionary (JSON)

- (NSString *)toJSONString {
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:0 error:&error];
    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
        return nil;
    }
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
    
@end
