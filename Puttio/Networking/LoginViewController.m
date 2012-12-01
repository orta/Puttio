//
//  OAuthViewController.m
//  Puttio
//
//  Created by orta therox on 23/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "LoginViewController.h"
#import "PutIOOAuthHelper.h"
#import "APP_SECRET.h"

@implementation LoginViewController

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
    
    // Incase we've logged out and back in.
    NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie *cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }

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
    [self setPasswordPaddingView:nil];
    [self setUsernamePaddingView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (IBAction)loginPressed:(id)sender {
    if (!self.passwordTextfield.text.length) {
        [self.passwordTextfield becomeFirstResponder];
        return;
    }

    [self disableForm:YES];
    [self.activityView startAnimating];
    self.warningLabel.text = @"";

    _authHelper.clientID = APP_ID;
    _authHelper.clientSecret = APP_SECRET;
    [_authHelper loginWithUsername:_usernameTextfield.text andPassword:_passwordTextfield.text];
    [self performSelector:@selector(showWebview) withObject:nil afterDelay:15];
}

- (IBAction)backTapped:(id)sender {
    [_authHelper loadAuthPage];
}

- (void)showWebview {
    _loginViewWrapper.hidden = YES;
    _webView.hidden = NO;
    _errorHeaderView.hidden = NO;
}

- (void)disableForm:(BOOL)disabled {
    CGFloat opacity = disabled? 0.4 : 1;
    for (UIControl *view in @[_loginButton, _usernameTextfield, _passwordTextfield, _passwordPaddingView, _usernamePaddingView]) {
        if ([view respondsToSelector:@selector(setEnabled:)]) {
            [view setEnabled:!disabled];
        }
        [view setAlpha:opacity];
        view.userInteractionEnabled = !disabled;
    }
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
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showWebview) object:nil];

    if([_delegate respondsToSelector:@selector(authorizationDidFinishWithController:)]){
        [_delegate authorizationDidFinishWithController:self];
        [Analytics incrementUserProperty:@"User Logged In" byInt:1];
    }
}

- (void)authHelperLoginFailedWithDescription:(NSString *)errorDescription {   
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showWebview) object:nil];

    self.warningLabel.text = errorDescription;
    [self disableForm:NO];
    [self.activityView stopAnimating];
}

- (void)authHelperHasDeclaredItScrewed {
    self.webView.hidden = NO;
    self.errorHeaderView.hidden = NO;
}

@end
