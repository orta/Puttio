//
//  TextFileInfoViewController.h
//  Puttio
//
//  Created by orta therox on 05/08/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ModalZoomView.h"

@class ARTitleLabel;
@interface TextFileInfoViewController : UIViewController <ModalZoomViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textfield;
@property (weak, nonatomic) IBOutlet ARTitleLabel *titleLabel;
- (IBAction)closeButtonTapped:(id)sender;

@end
