//
//  FolderViewController.h
//  Puttio
//
//  Created by orta therox on 04/06/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMGridView.h"

@class BrowsingViewController;
@interface FolderViewController : UIViewController <GMGridViewDataSource>

@property (nonatomic, strong) Folder *folder;
@property (nonatomic, strong) NSArray *folderItems;
@property (strong) GMGridView *gridView;
@property (weak) BrowsingViewController *browsingViewController;

- (void)reloadItemsFromServer;
@end
