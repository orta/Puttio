//
//  BrowsingViewController.h
//  Puttio
//
//  Created by orta therox on 25/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KKGridView/KKGridView.h>

@interface BrowsingViewController : UIViewController <KKGridViewDelegate, KKGridViewDataSource>
@property (strong) KKGridView *gridView;
- (void)setup;
@end
