//
//  LocalBrowsingViewController.h
//  Puttio
//
//  Created by David Grandinetti on 6/10/12.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMGridView.h"

@interface LocalBrowsingViewController : UIViewController <GMGridViewActionDelegate, GMGridViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) NSMutableArray *files;
@property (strong) GMGridView *gridView;

- (IBAction)backPressed:(id)sender;

@end
