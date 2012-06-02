//
//  ORDefaults.m
//  Puttio
//
//  Created by orta therox on 06/04/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ORDefaults.h"

@implementation ORDefaults
+ (void)registerDefaults {
	@autoreleasepool {	
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSLog(@"%@", NSStringFromSelector(_cmd));
        
        NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        [defaults setObject:appVersion forKey:ORAppVersion];
        [defaults setBool:YES forKey:ORShowLeftSidebarDefault];
        [defaults setBool:YES forKey:ORShowRightSidebarDefault];
        
        // Mark defaults as loaded
        [defaults setBool:YES forKey:ORDefaultsAreLoaded];
        [defaults synchronize];
    }
}
@end
