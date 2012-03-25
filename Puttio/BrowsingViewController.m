//
//  BrowsingViewController.m
//  Puttio
//
//  Created by orta therox on 25/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "BrowsingViewController.h"

@interface BrowsingViewController ()

@end

@implementation BrowsingViewController

- (void)setup {
    CGRect space = [self.view.superview frame];
    space.origin.x = SidebarWidth;
    space.origin.y = 0;
    space.size.width = space.size.width - (SidebarWidth * 2);
    self.view.frame = space;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self setup];
}

@end
