//
//  TorrentLikeView.m
//  Puttio
//
//  Created by orta therox on 07/07/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ORTorrentLikeView.h"
#import "UIColor+PutioColours.h"

@interface ORTorrentLikeView (){
    NSDictionary *_tiles;
    NSTimer *_colorChangeTimer;
    
    int tileSize;
    int tileCount;
    BOOL animates;

    CGColorRef whiteColor;
    CGColorRef yellowColor;
    CGColorRef blueColor;
}
@end

@implementation ORTorrentLikeView

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
    // store and retain our colorrefs as iVars. Jeez.
    whiteColor =  (CGColorRef)CFRetain( [UIColor whiteColor].CGColor );
    yellowColor = (CGColorRef)CFRetain( [UIColor putioYellow].CGColor );
    blueColor =   (CGColorRef)CFRetain( [UIColor putioBlue].CGColor );

    self.alpha = 0;
    self.backgroundColor = [UIColor colorWithWhite:0.877 alpha:1.000];

    switch ([UIDevice deviceType]) {
        case DeviceIpad1:
            tileCount = 28;
            tileSize = 40;
            break;
        case DeviceIpad2:
            tileCount = 35;
            tileSize = 30;
            animates = YES;
            break;
        case DeviceIpad3Plus:
            tileCount = 52;
            tileSize = 20;
            animates = YES;
            break;

        case DeviceIphone3GS:
            tileCount = 14;
            tileSize = 40;
            break;
        case DeviceIphone4Plus:
            tileCount = 18;
            tileSize = 30;
            break;

        default:
            tileCount = 52;
            tileSize = 20;
            animates = YES;
            break;
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [self performSelector:@selector(createTiles) withObject:nil afterDelay:0.1];
}

- (void)createTiles {
    NSMutableDictionary *tempLayers = [NSMutableDictionary dictionary];

    for (int i = 0; i < tileCount; i++) {
        for (int j = 0; j < tileCount; j++) {
            CALayer* myLayer = [CALayer layer];
            int color = arc4random() % 10;
            switch (color) {
                case 1:
                    myLayer.backgroundColor = yellowColor;
                    break;
                case 2:
                    myLayer.backgroundColor = blueColor;
                    break;
                default:
                    myLayer.backgroundColor = whiteColor;
                    break;
            }
            myLayer.bounds = CGRectMake(0,0, tileSize - 2, tileSize - 2);
            myLayer.position = CGPointMake(i * tileSize - 1, j * tileSize - 1);
            NSString *key = [NSString stringWithFormat:@"%i-%i", i,j];
            [tempLayers setObject:myLayer forKey:key];
            [self.layer addSublayer:myLayer];
        }
    }
    
    _tiles = tempLayers;
    
    [UIView animateWithDuration:0.6 animations:^{
        self.alpha = 1;
    }];

    if(animates){
        _colorChangeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(tick) userInfo:nil repeats:YES];
        [_colorChangeTimer fire];
    }
}

- (void)dealloc {
    CFRelease(whiteColor);
    CFRelease(yellowColor);
    CFRelease(blueColor);
}

- (void)tick {
    int x = arc4random() % tileCount;
    int y = arc4random() % tileCount;
    NSString *key = [NSString stringWithFormat:@"%i-%i", x, y];
    CALayer *layer = _tiles[key];
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:0.5]
                     forKey:kCATransactionAnimationDuration];

    int color = arc4random() % 8;
    if (color <= 1) {
        layer.backgroundColor = whiteColor;
    }else if (color > 1 && color < 4) {
        layer.backgroundColor = blueColor;
    }else {
        layer.backgroundColor = yellowColor;
    }
    [CATransaction commit];
}

@end
