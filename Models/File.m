//
//  File.m
//  Puttio
//
//  Created by orta therox on 25/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "File.h"

@implementation File
@dynamic contentType, name, size, id, screenShotURL, parentID, displayName;

- (void)setupDisplayName {
    NSString *display = @"";
    if (self.name.length > 1) {
        display = self.name;
        
        // remove prefix brackets - usually group names
        NSArray *prefixOpeners = [NSArray arrayWithObjects:@"[", @"{", @"(", nil];
        NSArray *prefixClosers = [NSArray arrayWithObjects:@"]", @"}", @")", nil];
        for (int i = 0; i < prefixClosers.count; i++) {
            if ([[display substringToIndex:1] isEqualToString:[prefixOpeners objectAtIndex:i]]) {
                display = [display substringFromIndex:[display rangeOfString:[prefixClosers objectAtIndex:i]].location];
            }                
        }
        
        display = [display capitalizedString];
        display = [display stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"[]{}()"]];

        NSArray *removeStrings = [NSArray arrayWithObjects:@".", @"_", @" 5 1aac ", @" 5.1aac ", @" Dvdrip ", @" Brrip ", @" x264 ", @" Hdtv ", @" 720 ", @" 1080 ", @" 480 ", @" Wmv", @" Mp4", @" M4v", @" Mkv", @" Hd ", nil];
        for (NSString *remove in removeStrings) {
            display = [display stringByReplacingOccurrencesOfString:remove withString:@" "];
        }
    }
    
    self.displayName = display;
}

- (NSString *)extension {
    return [[self.name pathExtension] lowercaseString];
}

@end
