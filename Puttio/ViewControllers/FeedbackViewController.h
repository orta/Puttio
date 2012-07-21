//
//  FeedbackViewController.h
//  Puttio
//
//  Created by orta therox on 21/07/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ModalZoomView.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface FeedbackViewController : UIViewController <ModalZoomViewControllerDelegate,MFMailComposeViewControllerDelegate>
- (IBAction)review:(id)sender;
- (IBAction)emailDeveloper:(id)sender;

@end
