//
//  TorrentLikeView.m
//  Puttio
//
//  Created by orta therox on 07/07/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "TorrentLikeView.h"
#import "UIColor+PutioColours.h"

@interface TorrentLikeView (){
    NSDictionary *_tiles;
    NSTimer *_colorChangeTimer;
    
    int tileSize;
    int tileCount;
    BOOL animates;
}
@end

@implementation TorrentLikeView

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
    self.alpha = 0;
    self.backgroundColor = [UIColor colorWithWhite:0.877 alpha:1.000];

    switch ([UIDevice deviceType]) {
        case DeviceIpad1:
            tileCount = 25;
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
            tileCount = 25;
            tileSize = 40;
            break;
        case DeviceIphone4Plus:
            tileCount = 35;
            tileSize = 30;
            animates = YES;
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
    CGColorRef whiteColor = [UIColor whiteColor].CGColor;
    CGColorRef yellowColor = [UIColor putioYellow].CGColor;
    CGColorRef blueColor = [UIColor putioBlue].CGColor;
    
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
    
    CGColorRelease(whiteColor);
    CGColorRelease(yellowColor);
    CGColorRelease(blueColor);
    
    _tiles = tempLayers;
    
    [UIView animateWithDuration:0.6 animations:^{
        self.alpha = 1;
    }];

    if(animates){
        _colorChangeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(tick) userInfo:nil repeats:YES];
        [_colorChangeTimer fire];
    }
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
        layer.backgroundColor = [UIColor whiteColor].CGColor;
    }else if (color > 1 && color < 4) {
        layer.backgroundColor = [UIColor putioBlue].CGColor;
    }else {
        layer.backgroundColor = [UIColor putioYellow].CGColor;
    }
    [CATransaction commit];
}

@end
