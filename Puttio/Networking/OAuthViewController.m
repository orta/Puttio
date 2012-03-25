//
//  OAuthViewController.m
//  Puttio
//
//  Created by orta therox on 23/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "OAuthViewController.h"

// http://put.io/v2/docs/#authentication

@interface OAuthViewController ()
- (void)auth;
- (void)loadAccountSettingsPage;
@end

@implementation OAuthViewController
@synthesize webView;

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
    if ([[request.URL absoluteString] isEqualToString:@"https://put.io/"]) {
        [self auth];
        return NO;
    }
    return YES;
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (error.code == 101) {
        NSString *code = [[error userInfo] objectForKey:@"NSErrorFailingURLStringKey"];
        NSArray *URLComponents = [code componentsSeparatedByString:@"%3D"];
        
        if (URLComponents.count > 1 && [code hasPrefix:@"puttio://callback/%3Fcode"]) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[URLComponents objectAtIndex:1] forKey:AppAuthTokenDefault];
            [defaults synchronize];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:OAuthTokenWasSavedNotification object:nil userInfo:nil];
            [self loadAccountSettingsPage];
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

#warning there's a lot of magic strings in this file. fix.

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    if([aWebView.request.URL.absoluteString isEqualToString:@"https://put.io/account/settings"]){
        [self parseForV1Tokens];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)auth {
    NSString *address = [NSString stringWithFormat:@"https://api.put.io/v2/oauth2/authenticate?client_id=%@&response_type=code&redirect_uri=%@", AppOAuthID, AppOAuthCallback];
    NSURL * url = [NSURL URLWithString:address];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)loadAccountSettingsPage {
    NSString *address = [NSString stringWithFormat:@"https://put.io/account/settings"];
    NSURL * url = [NSURL URLWithString:address];
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
