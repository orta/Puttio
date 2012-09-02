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
#import "ORRotatingButton.h"

@implementation TextFileInfoViewController

- (void)setItem:(File *)item {
    _titleLabel.text = item.displayName;
    _loadingIndicator.alpha = 0;
    [_loadingIndicator fadeIn];

    NSString *requestURL = [NSString stringWithFormat:@"https://put.io/v2/files/%@/download", item.id];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[PutIOClient appendOauthToken:requestURL]]];

    AFHTTPRequestOperation *downloadOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [downloadOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        _textfield.text = operation.responseString;
        [_loadingIndicator fadeOut];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _textfield.text = [ NSString stringWithFormat:@"Could not download text for %@", item.displayName];
        [_loadingIndicator fadeOut];
    }];
    [downloadOperation start];
}

- (void)zoomViewWillDissapear:(ModalZoomView *)zoomView {
    [UIView animateWithDuration:0.1 animations:^{
        _textfield.alpha = 0;
    }];
}


- (void)viewDidUnload {
    [self setTextfield:nil];
    [self setTitleLabel:nil];
    [self setLoadingIndicator:nil];
    [super viewDidUnload];
}

- (IBAction)closeButtonTapped:(id)sender {
    [ModalZoomView fadeOutViewAnimated:YES];
}
@end
