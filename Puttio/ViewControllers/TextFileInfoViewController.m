//
//  TextFileInfoViewController.m
//  Puttio
//
//  Created by orta therox on 05/08/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "TextFileInfoViewController.h"
#import "AFHTTPRequestOperation.h"
#import "ARTitleLabel.h"
@interface TextFileInfoViewController ()

@end

@implementation TextFileInfoViewController
@synthesize textfield;
@synthesize titleLabel;


- (void)setItem:(File *)item {
    titleLabel.text = item.displayName;

    NSString *requestURL = [NSString stringWithFormat:@"https://put.io/v2/files/%@/download", item.id];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[PutIOClient appendOauthToken:requestURL]]];

    AFHTTPRequestOperation *downloadOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [downloadOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        textfield.text = operation.responseString;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        textfield.text = [ NSString stringWithFormat:@"Could not download %@", item.displayName];
    }];
    [downloadOperation start];
}

- (void)zoomViewWillDissapear:(ModalZoomView *)zoomView {
    [UIView animateWithDuration:0.1 animations:^{
        textfield.alpha = 0;
    }];
}


- (void)viewDidUnload {
    [self setTextfield:nil];
    [self setTitleLabel:nil];
    [super viewDidUnload];
}

- (IBAction)closeButtonTapped:(id)sender {
    [ModalZoomView fadeOutViewAnimated:YES];
}
@end
