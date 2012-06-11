//
//  ItemDeletionViewController.h
//  Puttio
//
//  Created by orta therox on 04/06/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalZoomView.h"

@interface ItemDeletionViewController : UIViewController <ModalZoomViewControllerDelegate>

@property (strong) NSObject <ORDisplayItemProtocol> *item;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

- (IBAction)deleteTapped:(id)sender;
- (IBAction)cancelTapped:(id)sender;

@end
