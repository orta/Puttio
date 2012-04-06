//
//  ORSimpleProgress.h
//  Puttio
//
//  Created by orta therox on 25/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ORSimpleProgress : UIView {
    CGFloat _progress;
}
@property (strong) UILabel *label;
@property (strong) UIColor *fillColour;
@property (assign) BOOL isLandscape;
@property CGFloat progress;
@end
