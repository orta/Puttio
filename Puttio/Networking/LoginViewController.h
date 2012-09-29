//
//  OAuthViewController.h
//  Puttio
//
//  Created by orta therox on 23/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PutIOOAuthHelper.h"

@class LoginViewController;

@protocol OAuthVCDelegate <NSObject>
- (void)authorizationDidFinishWithController:(LoginViewController *)controller;
@end

@interface LoginViewController : UIViewController <UIWebViewDelegate, PutIOOAuthHelperDelegate>
@property (weak, nonatomic) id <OAuthVCDelegate>delegate;

@property (strong, nonatomic) IBOutlet PutIOOAuthHelper *authHelper;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextfield;
@property (weak, nonatomic) IBOutlet UIView *errorHeaderView;
@property (weak, nonatomic) IBOutlet UILabel *warningLabel;
@property (weak, nonatomic) IBOutlet UIView *loginViewWrapper;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *passwordPaddingView;
@property (weak, nonatomic) IBOutlet UIView *usernamePaddingView;


- (IBAction)loginPressed:(id)sender;
- (IBAction)backTapped:(id)sender;

@end
