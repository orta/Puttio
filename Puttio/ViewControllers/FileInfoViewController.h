//
//  FileInfoViewController.h
//  Puttio
//
//  Created by orta therox on 01/04/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ModalZoomView.h"
#import "ORSimpleProgress.h"

@interface FileInfoViewController : UIViewController <ModalZoomViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *additionalInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileSizeLabel;

@property (weak, nonatomic) IBOutlet UIButton *primaryButton;
@property (weak, nonatomic) IBOutlet UIButton *secondaryButton;

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet ORSimpleProgress *progressView;

- (IBAction)primaryButtonTapped:(id)sender;
- (IBAction)secondaryButtonTapped:(id)sender;

@property  File *item;

- (void)setProgressInfoHidden:(BOOL)hidden;

- (void)enableButtons;
- (void)disableButtons;

- (void)showProgress;
- (void)hideProgress;

@end
