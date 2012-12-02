//
//  ORAddTorrentFromBrowseViewController.m
//  Puttio
//
//  Created by orta therox on 02/12/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ORAddTorrentFromBrowseViewController.h"
#import "ORTitleLabel.h"

@interface ORAddTorrentFromBrowseViewController ()
@property (weak, nonatomic) IBOutlet ORTitleLabel *addressLabel;
@property (weak, nonatomic) IBOutlet ORTitleLabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *networkProgress;

@end

@implementation ORAddTorrentFromBrowseViewController

- (IBAction)cancelButtonTapped:(id)sender {
    [ModalZoomView fadeOutViewAnimated:YES];
}

- (IBAction)addButtonTapped:(id)sender {
    [_networkProgress startAnimating];
    [[PutIOClient sharedClient] requestTorrentOrMagnetURLAtPath:_address :^(id userInfoObject) {
        [_networkProgress stopAnimating];
        _addressLabel.text = @"Added to Put.IO";
        [(UIButton *)sender setEnabled:NO];
        [self performSelector:@selector(cancelButtonTapped:) withObject:self afterDelay:3];

    } addFailure:^{
        [_networkProgress stopAnimating];
        _addressLabel.text = @"Failed to add file";
    } networkFailure:^(NSError *error) {
        [_networkProgress stopAnimating];
        _addressLabel.text = @"Put.IO seems to be down";
    }];
}

- (void)setAddress:(NSString *)address {
    _address = address;
    _addressLabel.text = address;

    if ([address hasPrefix:@"http"]) {
        _titleLabel.text = @"Add Torrent to Put.IO";
    } else {
        _titleLabel.text = @"Add Magnet to Put.IO";
    }
}

- (void)viewDidUnload {
    [self setAddressLabel:nil];
    [self setTitleLabel:nil];
    [self setNetworkProgress:nil];
    [super viewDidUnload];
}

- (CGSize)sizeForZoomView:(ModalZoomView *)zoomView {
    return CGSizeMake(320, 200);
}

@end
