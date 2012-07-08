//
//  Analytics.m
//  Puttio
//
//  Created by orta therox on 01/04/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "MixpanelAPI.h"
#import "TestFlight.h"
#import "APP_SECRET.h"

@implementation Analytics

+ (void)setup {
    [TestFlight takeOff: TESTFLIGHT_SECRET];
    [MixpanelAPI sharedAPIWithToken:MIXPANEL_TOKEN];
    
    #ifndef RELEASE 
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    #endif
}

+ (void)setUserAccount:(NSString *)username {
    [TestFlight addCustomEnvironmentInformation:username forKey:@"username"];
    [[MixpanelAPI sharedAPI] identifyUser:username];
}

+ (void)event:(NSString*)string, ...{
    if (string == nil) {
        NSLog(@"nil string in ARAnalytics::error");
        return;
    }
    va_list listOfArguments;
    va_start(listOfArguments, string);
    NSString* event = [[NSString alloc] initWithFormat:string arguments:listOfArguments];

    [[MixpanelAPI sharedAPI] track:event];
    [TestFlight passCheckpoint:event];
}

+ (void)event:(NSString *)event withOptionString:(NSString *)message {
    [TestFlight passCheckpoint:[NSString stringWithFormat:@"%@ - %@", event, message]];
    [[MixpanelAPI sharedAPI] track:event properties:@{ @"options" : message }];
}

+ (void)error:(NSString*)string, ...{
    if (string == nil) {
        NSLog(@"nil string in ARAnalytics::error");
        return;
    }
    va_list listOfArguments;
    va_start(listOfArguments, string);
    NSString* error = [[NSString alloc] initWithFormat:string arguments:listOfArguments];
    
    [[MixpanelAPI sharedAPI] track:@"error" properties:@{ @"message" : string }];
    [TestFlight passCheckpoint:error];
}

+ (void)addCustomValue:(NSString*)value forKey:(NSString*)key {
    [TestFlight addCustomEnvironmentInformation:value forKey:key];
    [[MixpanelAPI sharedAPI] registerSuperProperties:@{ key : value }];
}

@end
