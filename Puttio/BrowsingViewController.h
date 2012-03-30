//
//  BrowsingViewController.h
//  Puttio
//
//  Created by orta therox on 25/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KKGridView/KKGridView.h>
#import "ORDisplayItemProtocol.h"

@interface BrowsingViewController : UIViewController <KKGridViewDelegate, KKGridViewDataSource>
@property (strong) KKGridView *gridView;
@property (strong) NSObject <ORDisplayItemProtocol> *item;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
- (IBAction)backPressed:(id)sender;

- (void)setup;
@end
