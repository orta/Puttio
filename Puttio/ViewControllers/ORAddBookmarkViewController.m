//
//  ORAddBookmarkViewController.m
//  Puttio
//
//  Created by orta therox on 06/01/2013.
//  Copyright (c) 2013 ortatherox.com. All rights reserved.
//

#import "ORAddBookmarkViewController.h"
#import "Bookmark.h"

@interface ORAddBookmarkViewController ()

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;

@end

@implementation ORAddBookmarkViewController

- (IBAction)addButtonPressed:(id)sender {
    Bookmark *bookmark = [Bookmark object];
    bookmark.name = _titleTextField.text;
    bookmark.url = _addressTextField.text;
    bookmark.lastAccessed = [NSDate date];
    if ([[bookmark managedObjectContext] persistentStoreCoordinator].persistentStores.count) {
        [[bookmark managedObjectContext] save:nil];
    } else {
        NSLog(@"could not save");
    }
    [_bookmarksController reloadAndHideBookmarks];
    [ModalZoomView fadeOutViewAnimated:YES];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [ModalZoomView fadeOutViewAnimated:YES];
}

- (void)zoomViewDidFinishZooming:(ModalZoomView *)zoomView {
    [UIView animateWithDuration:0.3 animations:^{
        if ([UIDevice deviceType] == DeviceIphone5Plus) {
            self.view.frame = CGRectOffset(self.view.frame, 0, -70);
        }
        else {
            self.view.frame = CGRectOffset(self.view.frame, 0, -105);
        }
    }];
    [_titleTextField becomeFirstResponder];
}

- (void)viewDidUnload {
    [self setTitleTextField:nil];
    [self setAddressTextField:nil];
    [super viewDidUnload];
}

- (CGSize)sizeForZoomView:(ModalZoomView *)zoomView {
    return CGSizeMake(320, 250);
}

- (void)setAddress:(NSString *)address {
    _addressTextField.text = address;
}

- (void)setName:(NSString *)name {
    _titleTextField.text = name;
}

@end
