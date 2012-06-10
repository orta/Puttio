//
//  ItemDeletionViewController.m
//  Puttio
//
//  Created by orta therox on 04/06/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ItemDeletionViewController.h"

@interface ItemDeletionViewController (){
    NSObject <ORDisplayItemProtocol> *_item;
}

@end

@implementation ItemDeletionViewController
@synthesize titleLabel;
@dynamic item;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)setItem:(NSObject<ORDisplayItemProtocol> *)item {
    _item = item;
    self.titleLabel.text = [NSString stringWithFormat:@"Delete %@?", item.displayName];
}

- (NSObject <ORDisplayItemProtocol> *)item {
    return _item;
}

- (IBAction)deleteTapped:(id)sender {
    [[PutIOClient sharedClient] requestDeletionForDisplayItemID:_item.id :^(id userInfoObject) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ORReloadFolderNotification object:nil];
        [ModalZoomView fadeOutViewAnimated:YES];
    }];
}

- (IBAction)cancelTapped:(id)sender {
    [ModalZoomView fadeOutViewAnimated:YES];    
}

@end
