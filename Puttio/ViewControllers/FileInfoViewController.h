//
//  FileInfoViewController.h
//  Puttio
//
//  Created by orta therox on 01/04/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ModalZoomView.h"

@interface FileInfoViewController : UIViewController <ModalZoomViewControllerProtocol>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *additionalInfoLabel;
@property (weak, nonatomic) IBOutlet UIButton *streamButton;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

- (IBAction)backButton:(id)sender;
- (IBAction)streamButton:(id)sender;

@property (strong) id item;

@end
