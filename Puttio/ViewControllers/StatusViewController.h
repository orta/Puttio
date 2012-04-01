//
//  StatusViewController.h
//  Puttio
//
//  Created by orta therox on 25/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ORSimpleProgress;
@interface StatusViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet ORSimpleProgress *bandwidthProgressView;
@property (weak, nonatomic) IBOutlet ORSimpleProgress *spaceProgressView;
- (void)setup;
@end
