//
//  ORRemoveTransferPopoverViewController.m
//  Puttio
//
//  Created by orta therox on 08/12/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ORRemoveTransferPopoverViewController.h"
#import "ORDestructiveButton.h"

@interface ORRemoveTransferPopoverViewController (){
    Transfer *_transfer;
    ORTransferViewController *_transferVC;
}
@property (weak, nonatomic) IBOutlet ORDestructiveButton *removeButton;
@end

@implementation ORRemoveTransferPopoverViewController

- (void)setTransfer:(Transfer *)transfer {
    _transfer = transfer;

    _removeButton.enabled = YES;
    _removeButton.alpha = 1;
   [_removeButton setTitle:@"Remove" forState:UIControlStateNormal];
}

- (void)setTransferViewController:(ORTransferViewController *)transferVC {
    _transferVC = transferVC;
}

- (IBAction)removeTapped:(UIButton *)sender {
    [_transferVC deleteTapped:sender];
    [_removeButton setTitle:@"Cancelling.." forState:UIControlStateNormal];
}

- (void)viewDidUnload {
    [self setRemoveButton:nil];
    [super viewDidUnload];
}

@end
