//
//  NSDate+StringParsing.m
//  Puttio
//
//  Created by orta therox on 03/06/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "NSDate+StringParsing.h"

static NSDateFormatter *_staticFormatter;

@implementation NSDate (StringParsing)

// this has been hacked and chopped into simple pieces, and isnt really ISO8601 anymore.

+ (NSDate *)dateWithISO8601String:(NSString *)dateString {
    if (!dateString) return nil;
    if ([dateString hasSuffix:@"Z"]) {
        dateString = [[dateString substringToIndex:(dateString.length-1)] stringByAppendingString:@"-0000"];
    }
    dateString = [dateString componentsSeparatedByString:@"T"][0];
    return [self dateFromString:dateString
                     withFormat:@"yyyy-MM-dd"];
}

+ (NSDate *)dateFromString:(NSString *)dateString 
                withFormat:(NSString *)dateFormat  {
    if (!_staticFormatter) {
        _staticFormatter = [[NSDateFormatter alloc] init];
        [_staticFormatter setDateFormat:dateFormat];

        NSLocale *locale = [[NSLocale alloc]
                            initWithLocaleIdentifier:@"en_US_POSIX"];
        [_staticFormatter setLocale:locale];
    }

    NSDate *date = [_staticFormatter dateFromString:dateString];
    return date;
}

@end
