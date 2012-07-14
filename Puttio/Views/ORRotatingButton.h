//
//  ORRotatingButton.h
//  Puttio
//
//  Created by orta therox on 14/07/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ORRotatingButton : UIButton

- (void)fadeIn;
- (void)fadeOut;

- (void)startAnimating;
- (void)stopAnimating;

@end
