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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.columnManager setupLayout];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

@end
