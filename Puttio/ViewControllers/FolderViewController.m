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
#import "ORHorizontalImageViewCell.h"
#import "UIDevice+SpaceStats.h"
#import "ModalZoomView.h"
#import "ORFlatButton.h"

@interface FolderViewController (){
    TreemapView *_treeView;
    UIView *_treeViewWrapper;
}

@end

@implementation FolderViewController

- (void)setFolder:(Folder *)folder {
    _folder = folder;
    [_gridView reloadData];
}

- (void)setFolderItems:(NSArray *)folderItems {
    _folderItems = folderItems;
    [self checkForWatched];
    [self orderItems];
    [_gridView reloadData];
}

#pragma mark -
#pragma mark View Handling

- (void)loadView {
    CGRect frame = CGRectMake(0, 0, 400, 400);
    
    _gridView = [[GMGridView alloc] initWithFrame:frame];
    _gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _gridView.autoresizesSubviews = YES;
    _gridView.actionDelegate = _browsingViewController;
    _gridView.dataSource = self;
    _gridView.clipsToBounds = YES;
    _gridView.userInteractionEnabled = YES;
    _gridView.backgroundColor = [UIColor whiteColor];
    _gridView.showsHorizontalScrollIndicator = NO;
    _gridView.contentInset = UIEdgeInsetsZero;
    _gridView.accessibilityLabel = @"GridView";

    self.view = _gridView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadGrid) name:ORReloadGridNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.view.userInteractionEnabled = YES;
    for (GMGridViewCell *cell in [_gridView subviews] ){
        cell.alpha = 1;
    }
}

#pragma mark -
#pragma mark GridView DataSource Methods

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView {
    return _folderItems.count;
}

- (GMGridViewCell *)GMGridView:(GMGridView *)aGridView cellForItemAtIndex:(NSInteger)index {
    
    static NSString * CellIdentifier = @"GridViewCellIdentifier";
    ORImageViewCell *cell = (ORImageViewCell *)[aGridView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        if ([UIDevice isPad]) {
            cell = [[ORImageViewCell alloc] initWithFrame:CGRectMake(0, 0, [ORImageViewCell cellWidth], [ORImageViewCell cellHeight])];
        }else{
            cell = [[ORHorizontalImageViewCell alloc] initWithFrame:CGRectMake(0, 0, [ORHorizontalImageViewCell cellWidth], [ORHorizontalImageViewCell cellHeight])];
        }
        
        cell.reuseIdentifier = CellIdentifier;
    }
    
    NSObject <ORDisplayItemProtocol> *item = _folderItems[index];
    cell.item = item;
    cell.title = item.displayName;
    
    if (![self itemIsFolder:item]) {
        File * file = (File *)item;
        if (file.watched.boolValue == YES) {
            cell.watched = YES;
        }
        
        if([file hasPreviewThumbnail]){
            cell.imageURL = [NSURL URLWithString:item.screenShotURL];
        }else{
            [cell useUnknownImageForFileType:[file extension]];
        }

    }else{
        cell.image = [UIImage imageNamed:@"Folder"];
    }
    
    return cell;
}   

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation) orientation {
    if ([UIDevice isPhone]) {
        return CGSizeMake([ORHorizontalImageViewCell cellWidth], [ORHorizontalImageViewCell cellHeight]);
    }
    return CGSizeMake([ORImageViewCell cellWidth], [ORImageViewCell cellHeight]);
}

#pragma mark -
#pragma mark Misc

- (void)reloadGrid {
    self.folderItems = self.folderItems;
    if (_treeView) {
        [UIView animateWithDuration:0.3 animations:^{
            [_treeView reloadData];
        }];
    }
}

- (BOOL)itemIsFolder:(NSObject <ORDisplayItemProtocol>*)item {
    return [item isKindOfClass: [Folder class]];
}

- (void)highlightItemAtIndex:(int)position {
    self.view.userInteractionEnabled = NO;

    [UIView animateWithDuration:0.3 animations:^{
        GMGridViewCell *view = [_gridView cellForItemAtIndex:position];
        for (GMGridViewCell *cell in [_gridView subviews] ){
            if (cell != view) {
                cell.alpha = 0.3;
            }else{
                cell.alpha = 1;
            }
        }
    }];
}

- (void)checkForWatched {
    WatchedList *list = [WatchedList findFirstByAttribute:@"folderID" withValue:_folder.id];
    if (list) {
        for (id item in _folderItems) {
            if ([item isKindOfClass:[File class]]) {
                File *file = item;
                for (WatchedItem *item in list.items) {
                    if ([item.fileID isEqualToString:file.id]) {
                        file.watched = @(YES);
                    }
                }
            }
        }
    }
}

- (void)orderItems {
    _folderItems = [_folderItems sortedArrayUsingComparator:^(NSObject <ORDisplayItemProtocol>* a, NSObject <ORDisplayItemProtocol>* b) { 
        return [a.name localizedStandardCompare:b.name];
    }];
}

- (void)reloadItemsFromServer {
    self.browsingViewController.networkActivity = YES;

    [[PutIOClient sharedClient] getFolder:self.folder :^(id userInfoObject) {
        self.browsingViewController.networkActivity = NO;
        if (![userInfoObject isKindOfClass:[NSError class]]) {
            self.folderItems = (NSArray *)userInfoObject;
        }
    }];
}

static CGFloat TreeViewFooterHeight = 60;

- (void)showTreeMap {

    CGRect treeViewFrame = self.view.bounds;
    treeViewFrame.size.height -= TreeViewFooterHeight;

    CGRect footerFrame = self.view.bounds;
    footerFrame.origin.y += CGRectGetHeight(footerFrame) - TreeViewFooterHeight;
    footerFrame.size.height = TreeViewFooterHeight;

    CGRect buttonFrame = footerFrame;
    buttonFrame.origin.y += 8;
    buttonFrame.origin.x += 8;
    buttonFrame.size.height = 44;
    buttonFrame.size.width = 80;

    _treeViewWrapper = [[UIView alloc] initWithFrame:self.view.bounds];
    _treeViewWrapper.alpha = 0;
    [self.view.superview addSubview:_treeViewWrapper];

    _treeView = [[TreemapView alloc] initWithFrame:treeViewFrame];
    _treeView.dataSource = self;
    _treeView.backgroundColor = [UIColor whiteColor];
    [_treeViewWrapper addSubview:_treeView];

    UIView *footerView = [[UIView alloc] initWithFrame:footerFrame];
    footerView.backgroundColor = [UIColor putioYellow];
    [_treeViewWrapper addSubview:footerView];

    ORFlatButton *button = [[ORFlatButton alloc] initWithFrame:buttonFrame];
    [button setTitle:@"Grid" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(removeTreeMap) forControlEvents:UIControlEventTouchUpInside];

    [_treeViewWrapper addSubview:button];

    [UIView animateWithDuration:0.3 animations:^{
        _treeViewWrapper.alpha = 1;
    }];
}

- (void)removeTreeMap {
    [UIView animateWithDuration:0.3 animations:^{
        _treeViewWrapper.alpha = 0;
    } completion:^(BOOL finished) {
        [_treeViewWrapper removeFromSuperview];
    }];
}

- (NSArray *)valuesForTreemapView:(TreemapView *)treemapView {
    NSMutableArray *sizes = [NSMutableArray array];
    for (id fileOrFolder in _folderItems) {
        NSNumber *size = [(File *)fileOrFolder size];
        [sizes addObject:size];
    }
    return sizes;
}

- (TreemapViewCell *)treemapView:(TreemapView *)treemapView cellForIndex:(NSInteger)index forRect:(CGRect)rect {
    TreemapViewCell *cell = [[TreemapViewCell alloc] initWithFrame:rect];
    File *file = _folderItems[index];
    cell.textLabel.text = file.displayName;
    cell.valueLabel.text = [UIDevice humanStringFromBytes:file.size.doubleValue];
    cell.backgroundColor = [UIColor colorWithRed:0.366 green:0.676 blue:0.969 alpha:1.000];
    cell.tag = index;

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTreemap:)];
    [cell addGestureRecognizer:tapGesture];
    
    UILongPressGestureRecognizer *deleteGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressTreemap:)];
    [cell addGestureRecognizer:deleteGesture];

	return cell;
}

- (void)tapTreemap:(UITapGestureRecognizer *)gesture {
    [UIView animateWithDuration:0.3 animations:^{
        _treeViewWrapper.alpha = 0;
    } completion:^(BOOL finished) {
        [_treeViewWrapper removeFromSuperview];
        [[self.gridView actionDelegate] GMGridView:self.gridView didTapOnItemAtIndex:gesture.view.tag];
    }];
}

- (void)longPressTreemap:(UILongPressGestureRecognizer *)gesture {
    if ([ModalZoomView isShowing]) return;
    
    UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    id item = _folderItems[gesture.view.tag];
    CGRect initialFrame = [self.view convertRect:[gesture.view frame] toView:rootView];
    
    [ModalZoomView showFromRect:initialFrame withViewControllerIdentifier:@"deleteView" andItem:item];
}

- (CGFloat)treemapView:(TreemapView *)treemapView separatorWidthForDepth:(NSInteger)depth {
    return 2.0f;
}

@end
