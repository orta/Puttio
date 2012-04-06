//
//  RootViewController.m
//  Puttio
//
//  Created by orta therox on 25/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "RootViewController.h"
#import "ThreeColumnViewManager.h"

@interface RootViewController ()

@end

@implementation RootViewController
@synthesize columnManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.columnManager setupLayout];
}

- (void)viewDidUnload {
    [self setColumnManager:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

@end
