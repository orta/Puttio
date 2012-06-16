//
//  ItemDeletionViewController.m
//  Puttio
//
//  Created by orta therox on 04/06/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ItemDeletionViewController.h"
#import "LocalFile.h"

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
    if ([self.item isMemberOfClass:[File class]]) {
        [[PutIOClient sharedClient] requestDeletionForDisplayItemID:_item.id :^(id userInfoObject) {
            [ModalZoomView fadeOutViewAnimated:YES];
        }];
    }
    
    if ([self.item isMemberOfClass:[LocalFile class]]) {
        LocalFile *file = (LocalFile *)self.item;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:file.filepath];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        [ModalZoomView fadeOutViewAnimated:YES];
    }
}

- (void)zoomViewWillDissapear:(ModalZoomView *)zoomView {
    [[NSNotificationCenter defaultCenter] postNotificationName:ORReloadFolderNotification object:nil];
}

- (IBAction)cancelTapped:(id)sender {
    [ModalZoomView fadeOutViewAnimated:YES];    
}

@end
