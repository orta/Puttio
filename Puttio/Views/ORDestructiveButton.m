//
//  ORDestructiveButton.m
//  Puttio
//
//  Created by orta therox on 14/07/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ORDestructiveButton.h"
#import "ORFlatButton.h"

@interface ORFlatButton (private)
- (void)setup;
- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state;
@end

@implementation ORDestructiveButton

- (void)setup {
    [super setup];
    self.backgroundColor = [UIColor putioRed];
    [self setBackgroundColor:[UIColor putioDarkRed] forState:UIControlStateHighlighted];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

}

@end
