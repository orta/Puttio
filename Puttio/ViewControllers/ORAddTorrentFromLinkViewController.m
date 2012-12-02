//
//  ORAddTorrentFromLinkViewController.m
//  Puttio
//
//  Created by orta therox on 02/12/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ORAddTorrentFromLinkViewController.h"

@interface ORAddTorrentFromLinkViewController (){
    __weak IBOutlet UITextField *_torrentTextField;
    __weak IBOutlet UILabel *_addedLabel;
    __weak IBOutlet UIActivityIndicatorView *_networkActivitySpinner;
}

@end

@implementation ORAddTorrentFromLinkViewController

- (IBAction)addButtonPressed:(id)sender {
    [_networkActivitySpinner startAnimating];
    _addedLabel.hidden = YES;



    [[PutIOClient sharedClient] requestTorrentOrMagnetURLAtPath:_torrentTextField.text :^(id userInfoObject) {
        [Analytics incrementUserProperty:@"Added a torrent" byInt:1];
        [_networkActivitySpinner stopAnimating];
        _addedLabel.hidden = NO;
        _addedLabel.text = @"Added! :)";
        [_torrentTextField resignFirstResponder];

    }
    addFailure:^() {
        [_networkActivitySpinner stopAnimating];
        _addedLabel.hidden = NO;
        _addedLabel.text = @"Failed :(";
    }
    networkFailure:^(NSError *error) {
        [_networkActivitySpinner stopAnimating];
        _addedLabel.hidden = NO;
        _addedLabel.text = @"Failed :(";

     }];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [ModalZoomView fadeOutViewAnimated:YES];
}

- (IBAction)pasteButtonPressed:(id)sender {
    _torrentTextField.text = @"";
    [_torrentTextField paste:self];
}

- (void)zoomViewDidFinishZooming:(ModalZoomView *)zoomView {
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectOffset(self.view.frame, 0, -28);
    }];
    [_torrentTextField becomeFirstResponder];
}

 - (void)viewDidUnload {
     _torrentTextField = nil;
     _addedLabel = nil;
     _networkActivitySpinner = nil;
     [super viewDidUnload];
}

- (CGSize)sizeForZoomView:(ModalZoomView *)zoomView {
    return CGSizeMake(320, 207);
}

@end
