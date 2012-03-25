//
//  OAuthViewController.m
//  Puttio
//
//  Created by orta therox on 23/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "OAuthViewController.h"
#import "APP_SECRET.h"
#import "AFNetworking.h"

// http://put.io/v2/docs/#authentication

// The order of this is

// Login in via website in webkit
// Redirect to the OAuth dialog
// Make a request to the OAuth authenticate URL ( getAccessTokenFromOauthCode )
// Load Accounts page and parse out the tokens
// Then call delegate method.

@interface OAuthViewController ()
- (void)auth;
- (void)loadAccountSettingsPage;
- (void)getAccessTokenFromOauthCode:(NSString *)code;
@end

@implementation OAuthViewController
@synthesize webView, delegate;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self auth];
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (IBAction)okPressed:(id)sender {
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    // after you log in, it redrects to root, we actually want it 
    if ([[request.URL absoluteString] isEqualToString: PTRootURL]) {
        [self auth];
        return NO;
    }
    return YES;
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (error.code == 101) {
        NSString *code = [[error userInfo] objectForKey:@"NSErrorFailingURLStringKey"];
        NSArray *URLComponents = [code componentsSeparatedByString:@"%3D"];
        
        if (URLComponents.count > 1 && [code hasPrefix: PTCallbackModified]) {            
            [self getAccessTokenFromOauthCode:[URLComponents objectAtIndex:1]];
        }
    }else{
        if (error.code == 102) {
            // no-op as the puttio:// url causes errors 101/102
        }else{
            // actually unexpected
            NSLog(@"uh oh webview fail! %@", error);            
        }
    }
}

- (void)getAccessTokenFromOauthCode:(NSString *)code {
    // https://api.put.io/v2/oauth2/access_token?client_id=YOUR_CLIENT_ID&client_secret=YOUR_CLIENT_SECRET&grant_type=authorization_code&redirect_uri=YOUR_REGISTERED_REDIRECT_URI&code=CODE

    NSString *address = [NSString stringWithFormat:PTFormatOauthTokenURL, @"10", APP_SECRET, @"authorization_code", PTCallbackOriginal, code];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:address]];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self loadAccountSettingsPage];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[JSON valueForKeyPath:@"access_token"] forKey:AppAuthTokenDefault];
        [defaults synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:OAuthTokenWasSavedNotification object:nil userInfo:nil];
        
    }failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"error %@", error);
    }];
    [operation start];
}

#warning there's a lot of magic strings in this file. fix.

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    if([aWebView.request.URL.absoluteString isEqualToString:PTSettingsURL]){
        [self parseForV1Tokens];
        if([delegate respondsToSelector:@selector(authorizationDidFinishWithController:)]){
            [delegate authorizationDidFinishWithController:self];
        }
    }
}

- (void)auth {
    NSString *address = [NSString stringWithFormat:@"https://api.put.io/v2/oauth2/authenticate?client_id=%@&response_type=code&redirect_uri=%@", AppOAuthID, AppOAuthCallback];
    NSURL * url = [NSURL URLWithString:address];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)loadAccountSettingsPage {
    NSURL * url = [NSURL URLWithString:PTSettingsURL];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)parseForV1Tokens {
    NSString *apiKey = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByClassName('api-key')[0].getElementsByTagName('input')[0].value"];
    NSString *apiSecret = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByClassName('api-key')[0].getElementsByTagName('input')[1].value"];
    if (apiKey && apiSecret) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:apiKey forKey:APIKeyDefault];
        [defaults setObject:apiSecret forKey:APISecretDefault];
        [defaults synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:V1TokensWereSavedNotification object:nil userInfo:nil];
    }else{
        #warning alert
        NSLog(@"HTML Syntax changed!");
    }
}

@end
