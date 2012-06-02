//
//  BrowsingViewController.h
//  Puttio
//
//  Created by orta therox on 25/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMGridView.h"
#import "ORDisplayItemProtocol.h"

@interface BrowsingViewController : UIViewController <GMGridViewDataSource, GMGridViewActionDelegate>
@property (strong) GMGridView *gridView;
@property (strong) NSObject <ORDisplayItemProtocol> *item;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
- (IBAction)backPressed:(id)sender;
- (IBAction)feedbackPressed:(id)sender;
@end
