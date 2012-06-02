//
//  OAuthViewController.h
//  Puttio
//
//  Created by orta therox on 23/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PutIOOAuthHelper.h"

@class OAuthViewController;

@protocol OAuthVCDelegate <NSObject>
- (void)authorizationDidFinishWithController:(OAuthViewController *)controller;
@end

@interface OAuthViewController : UIViewController <UIWebViewDelegate, PutIOOAuthHelperDelegate>
@property (weak, nonatomic) id <OAuthVCDelegate>delegate;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield; 
@property (weak, nonatomic) IBOutlet UILabel *warningLabel;
@property (weak, nonatomic) IBOutlet UIView *loginViewWrapper;
@property (strong, nonatomic) IBOutlet PutIOOAuthHelper *authHelper;

- (IBAction)loginPressed:(id)sender;

@end
