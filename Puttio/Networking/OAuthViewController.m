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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
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
            
            [[NSNotificationCenter defaultCenter] postNotificationName:LoggedInNotification object:nil userInfo:nil];
            [self.navigationController popToRootViewControllerAnimated:YES];
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

- (void)auth {
    NSString *address = [NSString stringWithFormat:@"https://api.put.io/v2/oauth2/authenticate?client_id=%@&response_type=code&redirect_uri=%@", AppOAuthID, AppOAuthCallback];
    NSURL * url = [NSURL URLWithString:address];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
}

@end
