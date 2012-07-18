//
//  ItemDeletionViewController.m
//  Puttio
//
//  Created by orta therox on 04/06/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ItemDeletionViewController.h"
#import "LocalFile.h"
#import "ORFlatButton.h"
@interface ItemDeletionViewController (){
    NSObject <ORDisplayItemProtocol> *_item;
}

@end

@implementation ItemDeletionViewController
@synthesize titleLabel;
@synthesize networkActivityView;
@synthesize deleteButton;
@synthesize cancelButton;
@dynamic item;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)setItem:(NSObject<ORDisplayItemProtocol> *)item {
    _item = item;
    
    if ([item respondsToSelector:@selector(displayName)]) {
        self.titleLabel.text = [NSString stringWithFormat:@"Delete %@?", item.displayName];
    }else {
        self.titleLabel.text = [NSString stringWithFormat:@"Delete %@?", item.name];
    }
}

- (NSObject <ORDisplayItemProtocol> *)item {
    return _item;
}

- (IBAction)deleteTapped:(id)sender {
    if ([self.item isMemberOfClass:[LocalFile class]]) {
        LocalFile *file = (LocalFile *)self.item;
        [file deleteItem];
        [Analytics incrementCounter:@"User Deleted LocalFile" byInt:1];
        [ModalZoomView fadeOutViewAnimated:YES];
    }else{
        [self disableButtons];
        [[PutIOClient sharedClient] requestDeletionForDisplayItemID:_item.id :^(id userInfoObject) {
            [Analytics incrementCounter:@"User Deleted RemoteFile" byInt:1];
            [self enableButtons];
            [ModalZoomView fadeOutViewAnimated:YES];
        }];
    }
}

- (void)zoomViewWillDissapear:(ModalZoomView *)zoomView {
    [[NSNotificationCenter defaultCenter] postNotificationName:ORReloadFolderNotification object:nil];
}

- (IBAction)cancelTapped:(id)sender {
    [ModalZoomView fadeOutViewAnimated:YES];    
}


- (void)enableButtons {
    self.deleteButton.enabled = YES;
    self.cancelButton.enabled = YES;
    [self.networkActivityView stopAnimating];
}

- (void)disableButtons {
    self.deleteButton.enabled = NO;
    self.cancelButton.enabled = NO;
    [self.networkActivityView startAnimating];
}

- (void)viewDidUnload {
    [self setNetworkActivityView:nil];
    [self setDeleteButton:nil];
    [self setCancelButton:nil];
    [super viewDidUnload];
}
@end
