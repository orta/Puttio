//
//  ORPutIOViewController.h
//  Puttio
//
//  Created by orta therox on 16/01/2013.
//  Copyright (c) 2013 ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ORPutIOViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)backTapped:(id)sender;

- (IBAction)exitTapped:(id)sender;
@end
