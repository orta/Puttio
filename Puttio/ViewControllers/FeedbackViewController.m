//
//  FeedbackViewController.m
//  Puttio
//
//  Created by orta therox on 21/07/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "FeedbackViewController.h"

@interface FeedbackViewController ()

@end

@implementation FeedbackViewController

- (IBAction)review:(id)sender {
    NSString *reviewURL = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=547030322";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:reviewURL]];
    [ModalZoomView fadeOutViewAnimated:YES];
}

- (IBAction)emailDeveloper:(id)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource: @"mail" ofType: @"html"];
    NSError *error = nil;
    NSString *body = [NSString stringWithContentsOfFile: path encoding: NSUTF8StringEncoding error: &error];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];

    body = [body stringByReplacingOccurrencesOfString:@"{{Device}}" withString:[UIDevice deviceString]];
    body = [body stringByReplacingOccurrencesOfString:@"{{Version}}" withString:appVersion];

    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    [controller setMessageBody:body isHTML:YES];
    [controller setSubject:@"Feedback from Put.IO for iOS"];
    [controller setToRecipients:@[@"orta.therox@gmail.com"]];

    controller.mailComposeDelegate = self;
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootViewController presentModalViewController:controller animated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootViewController dismissViewControllerAnimated:YES completion:^{
        [ModalZoomView fadeOutViewAnimated:YES];
    }];
}
@end
