//
//  ThreeColumnViewManager.h
//  Puttio
//
//  Created by orta therox on 06/04/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThreeColumnViewManager : NSObject

@property  UIView *leftSidebar;
@property  UIView *rightSidebar;
@property  UIView *centerView;
@property (weak, nonatomic) IBOutlet UIView *view;

- (void)setup;
- (void)setupLayout;
@end
