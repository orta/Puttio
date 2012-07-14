
//
//  AccountViewController.h
//  Puttio
//
//  Created by orta therox on 24/06/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ORSimpleProgress, DCRoundSwitch, BBCyclingLabel;
@interface AccountViewController : UIViewController

@property (weak, nonatomic) IBOutlet ORSimpleProgress *accountSpaceLeftProgress;
@property (weak, nonatomic) IBOutlet BBCyclingLabel *searchInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *welcomeAccountLabel;
@property (strong, nonatomic) IBOutlet UIView *loggedOutMessageView;
@property (weak, nonatomic) IBOutlet DCRoundSwitch *creativeCommonsSwitch;

@property (weak, nonatomic) IBOutlet UILabel *accountSpaceLabel;

- (IBAction)logOutTapped:(id)sender;
- (IBAction)addToTwitter:(id)sender;

@end
