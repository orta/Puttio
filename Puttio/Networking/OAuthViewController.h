//
//  OAuthViewController.h
//  Puttio
//
//  Created by orta therox on 23/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OAuthViewController;
@protocol OAuthVCDelegate <NSObject>
- (void)authorizationDidFinishWithController:(OAuthViewController *)controller;
@end

@interface OAuthViewController : UIViewController <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) id <OAuthVCDelegate>delegate;

- (IBAction)okPressed:(id)sender;

@end
