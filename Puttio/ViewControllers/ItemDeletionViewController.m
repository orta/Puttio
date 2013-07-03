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
        self.titleLabel.textAlignment = UITextAlignmentCenter;
        self.titleLabel.font = [self.titleLabel.font fontWithSize:18];
    }

    if ([item respondsToSelector:@selector(displayName)]) {
        self.titleLabel.text = [NSString stringWithFormat:@"Delete %@?", item.displayName];
    } else {
        self.titleLabel.text = [NSString stringWithFormat:@"Delete %@?", item.name];
    }

    if (![self.item isMemberOfClass:[LocalFile class]]) {
        [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    }
}

- (NSObject <ORDisplayItemProtocol> *)item {
    return _item;
}

- (IBAction)deleteTapped:(id)sender {
    if ([self.item isMemberOfClass:[LocalFile class]]) {
        LocalFile *file = (LocalFile *)self.item;
        [file deleteItem];
        [ARAnalytics incrementUserProperty:@"User Deleted LocalFile" byInt:1];
        [ModalZoomView fadeOutViewAnimated:YES];
    }else{
        [self disableButtons];

        [[PutIOClient sharedClient] requestDeletionForDisplayItem:_item :^(id userInfoObject) {
            [ARAnalytics incrementUserProperty:@"User Deleted RemoteFile" byInt:1];
            [ModalZoomView fadeOutViewAnimated:YES];

            if ([_item isKindOfClass:[PKFolder class]]) {
                WatchedList *list = [WatchedList findFirstByAttribute:@"folderID" withValue:_item.id];
                [list deleteEntity];
            }

        } failure:^(NSError *error) {}];
    }
}

- (void)zoomViewWillDissapear:(ModalZoomView *)zoomView {
    [[NSNotificationCenter defaultCenter] postNotificationName:ORReloadFolderNotification object:nil];
}

// This is not cancel anymore it's "open in another app"
- (IBAction)cancelTapped:(id)sender {

    if ([self.item isMemberOfClass:[LocalFile class]]) {
        LocalFile *file = (LocalFile *)self.item;
        UIDocumentInteractionController *docController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:file.localPathForFile]];

        UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
        CGRect rect = [rootView convertRect:[sender frame] fromView:self.view];
        [docController presentOpenInMenuFromRect:rect inView:rootView animated:YES];

    } else {
        [ModalZoomView fadeOutViewAnimated:YES];
    }
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
