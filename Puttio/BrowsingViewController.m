//
//  BrowsingViewController.m
//  Puttio
//
//  Created by orta therox on 25/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "BrowsingViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface BrowsingViewController ()

@end

@implementation BrowsingViewController

- (void)setup {
    CGRect space = [self.view.superview bounds];
    space.origin.x = SidebarWidth;
    space.origin.y = 0;
    space.size.width = space.size.width - (SidebarWidth * 2);
    self.view.frame = space;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [[PutIOClient sharedClient] getFolderAtPath:@"/" :^(id userInfoObject) {
//       NSLog(@"info %@", userInfoObject);
//    }];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self setup];
}


@end
