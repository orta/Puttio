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

@class ORRotatingButton;
@interface BrowsingViewController : UIViewController <GMGridViewActionDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *offlineView;
@property (weak, nonatomic) IBOutlet ORRotatingButton *refreshButton;
@property (assign, nonatomic) BOOL networkActivity;

- (void)setupRootFolder;
- (IBAction)backPressed:(id)sender;
- (IBAction)reloadPressed:(id)sender;

@end
