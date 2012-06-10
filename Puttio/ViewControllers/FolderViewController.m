//
//  FolderViewController.m
//  Puttio
//
//  Created by orta therox on 04/06/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "FolderViewController.h"
#import "ORImageViewCell.h"
#import "BrowsingViewController.h"
#import "WatchedList.h"
#import "WatchedItem.h"
#import "NSManagedObject+ActiveRecord.h"

@interface FolderViewController (){
    Folder *_folder;
    NSArray *_folderItems;
}
@end

const CGSize GridCellSize = { .width = 140.0, .height = 160.0 };

@implementation FolderViewController

@dynamic folder, folderItems;
@synthesize gridView, browsingViewController;

#pragma mark -
#pragma mark Properties

- (void)setFolder:(Folder *)folder {
    _folder = folder;
    [gridView reloadData];
}

- (void)setFolderItems:(NSArray *)folderItems {
    _folderItems = folderItems;
    [self checkForWatched];
    [gridView reloadData];
}

- (NSArray *)folderItems {
    return  _folderItems;
}

- (Folder *)folder {
    return _folder;
}

#pragma mark -
#pragma mark View Handling

- (void)loadView {
    CGRect frame = CGRectMake(0, 0, 400, 400);
    
    gridView = [[GMGridView alloc] initWithFrame:frame];
    gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    gridView.autoresizesSubviews = YES;
    gridView.actionDelegate = browsingViewController;
    gridView.dataSource = self;
    gridView.clipsToBounds = YES;
    gridView.userInteractionEnabled = YES;
    gridView.backgroundColor = [UIColor whiteColor];
    gridView.showsHorizontalScrollIndicator = NO;
    gridView.contentInset = UIEdgeInsetsZero;
    gridView.accessibilityLabel = @"GridView";
    
    self.view = gridView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadGrid) name:ORReloadGridNotification object:nil];
}

#pragma mark -
#pragma mark GridView DataSource Methods

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView {
    return [_folderItems count];
}

- (GMGridViewCell *)GMGridView:(GMGridView *)aGridView cellForItemAtIndex:(NSInteger)index {
    
    static NSString * CellIdentifier = @"GridViewCellIdentifier";
    ORImageViewCell *cell = (ORImageViewCell *)[aGridView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[ORImageViewCell alloc] initWithFrame:CGRectMake(0, 0, GridCellSize.width, GridCellSize.height)];
        cell.reuseIdentifier = CellIdentifier;
    }
    
    NSObject <ORDisplayItemProtocol> *item = [_folderItems objectAtIndex:index];
    cell.item = item;
    cell.title = item.displayName;
    cell.imageURL = [NSURL URLWithString:item.screenShotURL];
    
    if (![self itemIsFolder:item]) {
        File * file = (File *)item;
        if (file.watched.boolValue == YES) {
            cell.watched = YES;
        }
    }
    return cell;
}   

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation) orientation { 
    return GridCellSize;
}

#pragma mark -
#pragma mark Misc

- (void)reloadGrid {
    self.folderItems = self.folderItems;
}

- (BOOL)itemIsFolder:(NSObject <ORDisplayItemProtocol>*)item {
    return ([item.size intValue] == 0);
}

- (void)checkForWatched {
    WatchedList *list = [WatchedList findFirstByAttribute:@"folderID" withValue:_folder.id];
    if (list) {
        for (id item in _folderItems) {
            if ([item isKindOfClass:[File class]]) {
                File *file = item;
                for (WatchedItem *item in list.items) {
                    if ([item.fileID isEqualToString:file.id]) {
                        file.watched = [NSNumber numberWithBool:YES];;
                    }
                }
            }
        }
    }
}

@end
