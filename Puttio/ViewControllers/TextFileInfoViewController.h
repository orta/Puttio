//
//  TextFileInfoViewController.h
//  Puttio
//
//  Created by orta therox on 05/08/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ModalZoomView.h"

@class ORTitleLabel, ORRotatingButton;

@interface TextFileInfoViewController : UIViewController <ModalZoomViewControllerDelegate>

@property (weak, nonatomic) IBOutlet ORRotatingButton *loadingIndicator;
@property (weak, nonatomic) IBOutlet UITextView *textfield;
@property (weak, nonatomic) IBOutlet ORTitleLabel *titleLabel;

@end
