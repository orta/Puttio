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

// http://put.io/v2/docs/#authentication

// The order of this is

// Login in via website in webkit
// Redirect to the OAuth dialog
// Make a request to the OAuth authenticate URL ( getAccessTokenFromOauthCode )
// Load Accounts page and parse out the tokens
// Then call delegate method.

@interface OAuthViewController ()
- (void)loadAuthPage;
- (void)loadAccountSettingsPage;
- (void)getAccessTokenFromOauthCode:(NSString *)code;
@end

@implementation OAuthViewController
@synthesize usernameTextfield, passwordTextfield;
@synthesize warningLabel;
@synthesize loginViewWrapper;
@synthesize authHelper;
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupShadow];
    self.warningLabel.text = @"";
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (IBAction)loginPressed:(id)sender {
    #warning untested
    [authHelper loginWithUsername:usernameTextfield.text andPassword:passwordTextfield.text];
}

- (void)OAuthHelperDidLogin:(PutIOOAuthHelper *)helper {
    if([delegate respondsToSelector:@selector(authorizationDidFinishWithController:)]){
        [delegate authorizationDidFinishWithController:self];
    }
}

@end
