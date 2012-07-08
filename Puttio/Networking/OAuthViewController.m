//
//  OAuthViewController.m
//  Puttio
//
//  Created by orta therox on 23/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "OAuthViewController.h"
#import "PutIOOAuthHelper.h"

@implementation OAuthViewController
@synthesize errorHeaderView;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupShadow];
    self.warningLabel.text = @"";

    if ([UIDevice isPhone]) {
        CGRect frame = self.loginViewWrapper.frame;
        frame.origin.y = 0;
        self.loginViewWrapper.frame = frame;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.usernameTextfield becomeFirstResponder];
}

- (void)setupShadow {
    self.loginViewWrapper.clipsToBounds = NO;
    
    CALayer *layer = self.loginViewWrapper.layer;
    layer.masksToBounds = NO;
    layer.shadowOffset = CGSizeZero;
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowRadius = 20;
    layer.shadowOpacity = 0.15;
}

- (void)viewDidUnload {
    [self setUsernameTextfield:nil];
    [self setPasswordTextfield:nil];
    [self setWarningLabel:nil];
    [self setLoginViewWrapper:nil];
    [self setLoginButton:nil];
    [self setActivityView:nil];
    [self setWebView:nil];
    [self setErrorHeaderView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (IBAction)loginPressed:(id)sender {
    [self.loginButton setEnabled:NO];
    [self.usernameTextfield setEnabled:NO];
    [self.passwordTextfield setEnabled:NO];
    [self.activityView startAnimating];
    self.warningLabel.text = @"";
    
    [_authHelper loginWithUsername:_usernameTextfield.text andPassword:_passwordTextfield.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)aTextField {
    if ([aTextField isEqual:_usernameTextfield]) {
        [_passwordTextfield becomeFirstResponder];
    }
    else {
        [self loginPressed:self];
    }
    return YES;
}


- (void)authHelperDidLogin:(PutIOOAuthHelper *)helper {
    if([_delegate respondsToSelector:@selector(authorizationDidFinishWithController:)]){
        [_delegate authorizationDidFinishWithController:self];
    }
}

- (void)authHelperLoginFailedWithDesription:(NSString *)errorDescription {   
    self.warningLabel.text = errorDescription;
    self.loginButton.enabled = YES;
    self.usernameTextfield.enabled = YES;
    self.passwordTextfield.enabled = YES;
    [self.activityView stopAnimating];    
}

- (void)authHelperHasDeclaredItScrewed {
    self.webView.hidden = NO;
    self.errorHeaderView.hidden = NO;
}

@end
