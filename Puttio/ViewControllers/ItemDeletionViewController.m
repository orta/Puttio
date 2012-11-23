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
#import "WatchedList.h"
#import "Folder.h"

@interface ItemDeletionViewController (){
    NSObject <ORDisplayItemProtocol> *_item;
}

@end

@implementation ItemDeletionViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)setItem:(NSObject<ORDisplayItemProtocol> *)item {
    _item = item;

    if ([UIDevice isPhone]) {
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.textAlignment = UITextAlignmentCenter;

        CGRect newFrame = self.titleLabel.superview.frame;
        newFrame.size.height *= 2;
        self.titleLabel.superview.frame = newFrame;
        newFrame.origin.y = 0;
        self.titleLabel.frame = newFrame;

        self.deleteButton.frame = CGRectOffset(self.deleteButton.frame, 0, 14);
        self.cancelButton.frame = CGRectOffset(self.cancelButton.frame, 0, 14);
    }

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
        [Analytics incrementUserProperty:@"User Deleted LocalFile" byInt:1];
        [ModalZoomView fadeOutViewAnimated:YES];
    }else{
        [self disableButtons];

        [[PutIOClient sharedClient] requestDeletionForDisplayItem:_item :^(id userInfoObject) {
            [Analytics incrementUserProperty:@"User Deleted RemoteFile" byInt:1];
            [ModalZoomView fadeOutViewAnimated:YES];

            if ([_item isKindOfClass:[Folder class]]) {
                WatchedList *list = [WatchedList findFirstByAttribute:@"folderID" withValue:_item.id];
                [list deleteEntity];
            }

        } failure:^(NSError *error) {}];
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
