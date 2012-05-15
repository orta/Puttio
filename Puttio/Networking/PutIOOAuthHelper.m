//
//  OAuthController.m
//  Puttio
//
//  Created by orta therox on 13/05/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "PutIOOAuthHelper.h"
#import "APP_SECRET.h"
#import "AFNetworking.h"
#import "PutIONetworkConstants.h"

// http://put.io/v2/docs/#authentication

// The order of this is

// Login in via website in webkit
// Redirect to the OAuth dialog
// Make a request to the OAuth authenticate URL ( getAccessTokenFromOauthCode )
// Load Accounts page and parse out the tokens
// Then call delegate method.

@interface PutIOOAuthHelper (){
    NSString *_username;
    NSString *_password;
}

@end

@implementation PutIOOAuthHelper

@synthesize webView, delegate;

- (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password {
    webView.delegate = self;

    [self loadRootPage];
    _username = username;
    _password = password;
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

- (void)loadRootPage {
    NSURL * url = [NSURL URLWithString:PTLoginURL];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)loadAuthPage {    
    NSString *address = [NSString stringWithFormat:PTFormatOauthLoginURL, AppOAuthID, AppOAuthCallback];
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
        
    }else{
        NSLog(@"HTML Syntax changed!");
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:V1TokensWereSavedNotification object:nil userInfo:nil];
}

#pragma mark -
#pragma mark Webview delegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {    
    // after you log in, it redrects to root, we actually want it 
    if ([[request.URL absoluteString] isEqualToString: PTRootURL]) {
        [self loadAuthPage];
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
            // no-op as the puttio:// url causes both errors 101/102
        }else if (error.code == -1009) {
            [self.delegate authHelperLoginFailedWithDesription:@"Your iPad is currently offline."];
        }else {
            // actually unexpected
            NSString *error = [NSString stringWithFormat:@"WebView not acting as expected %@", error];
            [self.delegate authHelperLoginFailedWithDesription:error];
        }
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    if([aWebView.request.URL.absoluteString isEqualToString:PTSettingsURL]){
        [self parseForV1Tokens];
        [self.delegate authHelperDidLogin:self];
    }
    if([aWebView.request.URL.absoluteString isEqualToString:PTLoginURL]){
        NSString *setUsername = [NSString stringWithFormat:@"document.getElementsByTagName('input')[0].value = '%@'", _username];
        [webView stringByEvaluatingJavaScriptFromString:setUsername];
        
        NSString *setPassword = [NSString stringWithFormat:@"document.getElementsByTagName('input')[1].value = '%@'", _password];
        [webView stringByEvaluatingJavaScriptFromString:setPassword];
        
        [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('form')[0].submit()"];
    }
}

@end
