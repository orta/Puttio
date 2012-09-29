//
//  ORNavigationController.m
//  Puttio
//
//  Created by orta therox on 29/09/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ORNavigationController.h"

@implementation ORNavigationController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    NSLog(@"%@ - %@", NSStringFromSelector(_cmd), self);

    if ([UIDevice isPhone]) {
        return UIInterfaceOrientationIsPortrait(interfaceOrientation);
    }
    return YES;
}

@end
