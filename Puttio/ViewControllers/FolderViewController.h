//
//  FolderViewController.h
//  Puttio
//
//  Created by orta therox on 04/06/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GMGridView.h"
#import "TreemapView.h"

@class BrowsingViewController;
@interface FolderViewController : UIViewController <GMGridViewDataSource, TreemapViewDataSource>

@property (nonatomic, strong) Folder *folder;
@property (nonatomic, strong) NSArray *folderItems;
@property  GMGridView *gridView;
@property (weak) BrowsingViewController *browsingViewController;

- (void)reloadItemsFromServer;
- (void)highlightItemAtIndex:(int)position;

- (void)showTreeMap;
@end
