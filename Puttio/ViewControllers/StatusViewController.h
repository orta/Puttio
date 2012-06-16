//
//  StatusViewController.h
//  Puttio
//
//  Created by orta therox on 25/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ORSlidingTableView.h"

@class ORSimpleProgress, DCKnob, BaseProcess;
@interface StatusViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ORSlidingTableViewDelegate>

+ (StatusViewController *)sharedController;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet DCKnob *spaceProgressView;
@property (weak, nonatomic) IBOutlet DCKnob *spaceProgressBG;

@property (weak, nonatomic) IBOutlet UILabel *spaceLabel;

- (void)setup;
- (void)addProcess:(BaseProcess *)process;

@end
