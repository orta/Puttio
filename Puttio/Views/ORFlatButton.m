//
//  ORFlatButton.m
//  Puttio
//
//  Created by orta therox on 22/05/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ORFlatButton.h"
#import "UIColor+PutioColours.h"

@implementation ORFlatButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [self setup];
}

- (void)setup {
    self.backgroundColor = [UIColor putioBlue];
    [self setBackgroundColor:[UIColor putioDarkBlue] forState:UIControlStateHighlighted];
    
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state {
    [self setBackgroundImage:[self imageFromColor:backgroundColor]
                    forState:state];
}

// creates a 1x1 UIImage with a color
// comes from http://stackoverflow.com/questions/2808888/is-it-even-possible-to-change-a-uibuttons-background-color
- (UIImage *) imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


@end
