//
//  ORImageFileInfoViewController.m
//  Puttio
//
//  Created by orta therox on 02/12/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ORImageFileInfoViewController.h"
#import "AFHTTPRequestOperation.h"
#import "ORTitleLabel.h"
#import "ORRotatingButton.h"
#import "ORSimpleProgress.h"


@interface ORImageFileInfoViewController ()
@property (weak, nonatomic) IBOutlet ORRotatingButton *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet ORTitleLabel *titleLabel;
@property (weak, nonatomic) IBOutlet ORSimpleProgress *progressBar;
@end

@implementation ORImageFileInfoViewController

- (void)setItem:(File *)item {
  //  if (!item) return;

    _titleLabel.text = item.displayName;
    _loadingIndicator.alpha = 0;
    [_loadingIndicator fadeIn];
    _progressBar.isLandscape = YES;

    NSString *requestURL = [NSString stringWithFormat:@"https://put.io/v2/files/%@/download", item.id];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[PutIOClient appendOauthToken:requestURL]]];
    NSLog(@"%@", request.URL.absoluteString);

    AFHTTPRequestOperation *downloadOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

    [downloadOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        CGFloat progress = (float)totalBytesRead/totalBytesExpectedToRead;
            _progressBar.progress = progress;
    }];

    [downloadOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        _progressBar.alpha = 0;
        _imageView.image = [UIImage imageWithData:operation.responseData];
        [_loadingIndicator fadeOut];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        _titleLabel.text = [ NSString stringWithFormat:@"Error downloading %@", item.displayName];
        NSLog(@"%@", error.localizedDescription);
        
        _progressBar.alpha = 0;
        [_loadingIndicator fadeOut];
    }];
    [downloadOperation start];
}

- (void)zoomViewWillDissapear:(ModalZoomView *)zoomView {
    [UIView animateWithDuration:0.1 animations:^{
        _imageView.alpha = 0;
    }];
}

- (void)viewDidUnload {
    [self setImageView:nil];
    [self setTitleLabel:nil];
    [self setLoadingIndicator:nil];
    [self setProgressBar:nil];
    [super viewDidUnload];
}

- (CGSize)sizeForZoomView:(ModalZoomView *)zoomView {
    if ([UIDevice isPad]) {
        return CGSizeMake(640, 480);
    } else {
        return CGSizeMake(320, 480);
    }
}

@end
