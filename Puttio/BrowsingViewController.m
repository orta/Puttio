//
//  BrowsingViewController.m
//  Puttio
//
//  Created by orta therox on 25/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "BrowsingViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ORDisplayItemProtocol.h"

#import "ORImageViewCell.h"
#import "MoviePlayer.h"
#import "ModalZoomView.h"

@interface BrowsingViewController () {
    NSArray *gridViewItems;
    NSObject <ORDisplayItemProtocol> *_item;    
}

- (BOOL)itemIsFolder:(NSObject*)item;
@end

static UIEdgeInsets GridViewInsets = {.top = 60, .left = 6, .right = 6, .bottom = 5};
const CGSize GridCellSize = { .width = 140.0, .height = 160.0 };

@implementation BrowsingViewController
@synthesize gridView, titleLabel;
@dynamic item;

- (void)setup {
    CGRect space = [self.view.superview bounds];
    space.origin.x = SidebarWidth;
    space.origin.y = 0;
    space.size.width = space.size.width - (SidebarWidth * 2);
    self.view.frame = space;
    
    [self setupGridView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Folder *rootFolder = [Folder object];
    rootFolder.id = @"0";
    rootFolder.name = @"Home";
    rootFolder.parentID = @"0";
    self.item = rootFolder;
    [self loadFolder:rootFolder];
}

- (IBAction)backPressed:(id)sender {
    Folder *currentFolder = (Folder *)self.item;
    if (![currentFolder.id isEqualToString:@"0"]) {
        [self loadFolder:currentFolder.parentFolder];
    }
}

- (void)loadFolder:(Folder *)folder {
    [[PutIOClient sharedClient] getFolder:folder :^(id userInfoObject) {
        if (![userInfoObject isMemberOfClass:[NSError class]]) {
            self.item = folder;
            gridViewItems = userInfoObject;
            [gridView reloadData];
        }
    }];
}

-(void)gridView:(KKGridView *)kkGridView didSelectItemAtIndexPath:(KKIndexPath *)indexPath {
    NSObject <ORDisplayItemProtocol> *item = [gridViewItems objectAtIndex:indexPath.index];   
    if ([self itemIsFolder:item]) {
        Folder *folder = (Folder *)item;
        [self loadFolder:folder];
    }else {
        UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
        CGRect initialFrame = [kkGridView convertRect:[kkGridView rectForCellAtIndexPath:indexPath] toView:rootView];
        [ModalZoomView showFromRect:initialFrame withViewControllerIdentifier:@"FileInfoView" andItem:item];
    }
}

- (NSUInteger)gridView:(KKGridView *)gridView numberOfItemsInSection:(NSUInteger)section {
    return [gridViewItems count];
}

- (KKGridViewCell *)gridView:(KKGridView *)aGridView cellForItemAtIndexPath:(KKIndexPath *)indexPath {
    NSInteger index = indexPath.index;
    static NSString * CellIdentifier = @"GridViewCellIdentifier";
    ORImageViewCell *cell = (ORImageViewCell *)[aGridView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[ORImageViewCell alloc] initWithFrame:CGRectMake(0, 0, GridCellSize.width, GridCellSize.height)
                                          reuseIdentifier:CellIdentifier];
    }

    NSObject <ORDisplayItemProtocol> *item = [gridViewItems objectAtIndex:index];
    cell.item = item;
    cell.title = item.name;
    if ([self itemIsFolder:item]) {
        cell.imageURL = [NSURL URLWithString:item.iconURL];
//        cell.subtitle = item.description;
    }else{
        cell.imageURL = [NSURL URLWithString:[item.iconURL stringByReplacingOccurrencesOfString:@"shot/" withString:@"shot/b/"]];
    }
    return cell;
}   

- (void)setupGridView {
    CGRect frame = CGRectNull;
    
    frame.size.width = self.view.frame.size.width - GridViewInsets.left - GridViewInsets.right;
    frame.size.height = self.view.frame.size.height - GridViewInsets.top - GridViewInsets.bottom;
    frame.origin.x = GridViewInsets.left;
    frame.origin.y = GridViewInsets.top;

    gridView = [[KKGridView alloc] initWithFrame:frame];
    gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    gridView.autoresizesSubviews = YES;
    gridView.gridDelegate = self;
    gridView.dataSource = self;
    gridView.cellSize = GridCellSize;
    gridView.cellPadding = CGSizeMake(7, 0);
    gridView.userInteractionEnabled = YES;
    gridView.backgroundColor = [UIColor whiteColor];
    gridView.showsHorizontalScrollIndicator = NO;
    gridView.contentInset = UIEdgeInsetsZero;
    gridView.accessibilityLabel = @"GridView";
    
    [self.view addSubview:gridView];    
}

- (NSObject *)item {
    return _item;
}

- (void)setItem:(NSObject<ORDisplayItemProtocol> *)item {
    _item = item;
    titleLabel.text = item.name;
}

- (void)viewDidUnload {
    [self setGridView:nil];
    [self setTitleLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self setup];
}

- (BOOL)itemIsFolder:(NSObject*)item {
    // jeez, I must be doing something wrong here..
    NSObject <ORDisplayItemProtocol> *displayItem = (NSObject <ORDisplayItemProtocol> *)item;
    if ([displayItem.size intValue] == 0) {
        return YES;
    }
    return NO;
}

@end
