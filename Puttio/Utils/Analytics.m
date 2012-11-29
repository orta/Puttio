//
//  Analytics.m
//  Puttio
//
//  Created by orta therox on 01/04/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "Mixpanel.h"
#import "TestFlight.h"
#import "APP_SECRET.h"

static BOOL ignore = NO;

@implementation Analytics

+ (void)setup {
#if TARGET_IPHONE_SIMULATOR
    ignore = YES;
#endif

    [TestFlight takeOff: TESTFLIGHT_SECRET];
    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];

    #ifndef RELEASE 
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    #endif
}

+ (void)setUserAccount:(NSString *)username {
    [TestFlight addCustomEnvironmentInformation:username forKey:@"username"];
    [[Mixpanel sharedInstance] setNameTag:username];
    [[Mixpanel sharedInstance] set:username to:@"name"];
}

+ (void)event:(NSString*)string, ...{
    if (ignore) return;

    if (string == nil) {
        NSLog(@"nil string in ARAnalytics::error");
        return;
    }
    va_list listOfArguments;
    va_start(listOfArguments, string);
    NSString* event = [[NSString alloc] initWithFormat:string arguments:listOfArguments];

    [[Mixpanel sharedInstance] track:event];
    [TestFlight passCheckpoint:event];
}

+ (void)event:(NSString *)event withOptionString:(NSString *)message {
    if (ignore) return;
    
    [TestFlight passCheckpoint:[NSString stringWithFormat:@"%@ - %@", event, message]];
    [[Mixpanel sharedInstance] track:event properties:@{ @"options" : message }];
}

+ (void)event:(NSString *)string withProperties:(NSDictionary *)properties {
    if (ignore) return;
    
    [TestFlight passCheckpoint:string];
    [[Mixpanel sharedInstance] track:string properties:properties];
}

+ (void)event:(NSString *)event withTimeIntervalSinceDate:(NSDate *)date {
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:date];
    [self event:event withProperties:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:interval], @"seconds", [self stringFromInterval:interval], @"time", nil]];
}

+ (void)error:(NSString*)string, ...{
    if (ignore) return;
    
    if (string == nil) {
        NSLog(@"nil string in ARAnalytics::error");
        return;
    }
    va_list listOfArguments;
    va_start(listOfArguments, string);
    NSString* error = [[NSString alloc] initWithFormat:string arguments:listOfArguments];
    
    [[Mixpanel sharedInstance] track:@"error" properties:@{ @"message" : string }];
    [TestFlight passCheckpoint:error];
}

+ (void)addCustomValue:(NSString*)value forKey:(NSString*)key {
    if (ignore) return;
    
    [TestFlight addCustomEnvironmentInformation:value forKey:key];
    [[Mixpanel sharedInstance] registerSuperProperties:@{ key : value }];
}

+ (void)incrementUserProperty:(NSString*)counterName byInt:(int)amount {
    if (ignore) return;

    [[Mixpanel sharedInstance] increment:counterName by:@(amount)];
}

+ (NSString *) stringFromInterval:(NSTimeInterval)interval {
    unsigned long seconds = interval;
    unsigned long minutes = seconds / 60;
    seconds %= 60;
    unsigned long hours = minutes / 60;
    minutes %= 60;

    NSMutableString * result = [NSMutableString string];
    [result appendFormat: @"%0.2ld:", hours];
    [result appendFormat: @"%0.2ld:", minutes];
    [result appendFormat: @"%0.2ld", seconds];
    return result;
}

@end
