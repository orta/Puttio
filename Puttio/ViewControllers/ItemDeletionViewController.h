//
//  ItemDeletionViewController.h
//  Puttio
//
//  Created by orta therox on 04/06/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalZoomView.h"

@class ORFlatButton;
@interface ItemDeletionViewController : UIViewController <ModalZoomViewControllerDelegate>

@property (strong) NSObject <ORDisplayItemProtocol> *item;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *networkActivityView;
@property (weak, nonatomic) IBOutlet ORFlatButton *deleteButton;
@property (weak, nonatomic) IBOutlet ORFlatButton *cancelButton;

- (IBAction)deleteTapped:(id)sender;
- (IBAction)cancelTapped:(id)sender;

@end
