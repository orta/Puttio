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

@interface FolderViewController (){
    Folder *_folder;
}
@end

const CGSize GridCellSize = { .width = 140.0, .height = 160.0 };

@implementation FolderViewController

@dynamic folder;
@synthesize gridView, folderItems, browsingViewController;

- (void)setFolder:(Folder *)folder {
    _folder = folder;

    [gridView reloadData];
}

- (Folder *)folder {
    return _folder;
}

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
}

#pragma mark -
#pragma mark GridView DataSource Methods

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView {
    return [folderItems count];
}

- (GMGridViewCell *)GMGridView:(GMGridView *)aGridView cellForItemAtIndex:(NSInteger)index {
    
    static NSString * CellIdentifier = @"GridViewCellIdentifier";
    ORImageViewCell *cell = (ORImageViewCell *)[aGridView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[ORImageViewCell alloc] initWithFrame:CGRectMake(0, 0, GridCellSize.width, GridCellSize.height)];
        cell.reuseIdentifier = CellIdentifier;
    }
    
    NSObject <ORDisplayItemProtocol> *item = [folderItems objectAtIndex:index];
    cell.item = item;
    cell.title = item.displayName;
    if ([self itemIsFolder:item]) {
        cell.imageURL = [NSURL URLWithString:item.screenShotURL];
    }else{
        cell.imageURL = [NSURL URLWithString: [PutIOClient appendOauthToken:item.screenShotURL]];
    }
    return cell;
}   

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation) orientation { 
    return GridCellSize;
}

- (BOOL)itemIsFolder:(NSObject <ORDisplayItemProtocol>*)item {
    if ([item.size intValue] == 0) {
        return YES;
    }
    return NO;
}

@end
