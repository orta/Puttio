//
//  AccountViewController.h
//  Puttio
//
//  Created by orta therox on 24/06/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ORSimpleProgress;
@interface AccountViewController : UIViewController

@property (weak, nonatomic) IBOutlet ORSimpleProgress *accountSpaceLeftProgress;
@property (weak, nonatomic) IBOutlet ORSimpleProgress *deviceStoredProgress;
@property (weak, nonatomic) IBOutlet ORSimpleProgress *deviceSpaceLeftProgress;

@property (weak, nonatomic) IBOutlet UILabel *welcomeAccountLabel;

@property (weak, nonatomic) IBOutlet UILabel *accountSpaceLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceStoredLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceSpaceLeftLabel;

- (IBAction)logOutTapped:(id)sender;

@end
