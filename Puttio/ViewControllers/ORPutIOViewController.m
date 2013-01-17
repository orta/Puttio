//
//  ORPutIOViewController.m
//  Puttio
//
//  Created by orta therox on 16/01/2013.
//  Copyright (c) 2013 ortatherox.com. All rights reserved.
//

#import "ORPutIOViewController.h"

@interface ORPutIOViewController ()

@end

@implementation ORPutIOViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *url = @"http://put.io";
    if ([UIDevice isPhone]) {
        url = @"http://m.put.io";
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [_webView loadRequest:request];
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [super viewDidUnload];
}


- (IBAction)backTapped:(id)sender {
    [_webView goBack];
}

- (IBAction)exitTapped:(id)sender {
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
