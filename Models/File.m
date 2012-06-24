//
//  File.m
//  Puttio
//
//  Created by orta therox on 25/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "File.h"

@implementation File

@dynamic contentType;
@dynamic displayName;
@dynamic id;
@dynamic name;
@dynamic parentID;
@dynamic screenShotURL;
@dynamic size;
@dynamic hasMP4;
@dynamic watched;
@dynamic folder;

+ (NSString *)createDisplayNameFromName:(NSString *)fullName {
    NSString *display = @"";
    display = fullName;

    if (fullName.length > 1) {
        
        // remove prefix brackets - usually group names
        NSArray *prefixOpeners = @[@"[", @"{", @"("];
        NSArray *prefixClosers = @[@"]", @"}", @")"];
        for (int i = 0; i < prefixClosers.count; i++) {
            if ([[display substringToIndex:1] isEqualToString:prefixOpeners[i]]) {
                display = [display substringFromIndex:[display rangeOfString:prefixClosers[i]].location];
            }                
        }
        
        display = [display capitalizedString];
        display = [display stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"[]{}()"]];

        NSArray *removeStrings = @[@".", @"_", @" 5 1aac ", @" 5.1aac ", @" Dvdrip ", @" Brrip ", @" x264 ", @" Hdtv ", @" 720 ", @" 1080 ", @" 480 ", @" Wmv", @" Mp4", @" M4v", @" Mkv", @" Hd "];
        for (NSString *remove in removeStrings) {
            display = [display stringByReplacingOccurrencesOfString:remove withString:@" "];
        }
    }
    
    return display;
}

- (NSString *)extension {
    return [[self.name pathExtension] lowercaseString];
}

@end
