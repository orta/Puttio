//
//  BrowsingViewController.m
//  Puttio
//
//  Created by orta therox on 25/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "BrowsingViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ORImageViewCell.h"

@interface BrowsingViewController () {
    NSArray *gridViewItems;
}
@end

static UIEdgeInsets GridViewInsets = {.top = 10, .left = 6, .right = 6, .bottom = 5};
const CGSize GridCellSize = { .width = 242.0, .height = 294.0 };

@implementation BrowsingViewController
@synthesize gridView;

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
    [[PutIOClient sharedClient] getFolderAtPath:@"/" :^(id userInfoObject) {
        gridViewItems = userInfoObject;
        [gridView reloadData];
    }];
}


- (NSUInteger)gridView:(KKGridView *)gridView numberOfItemsInSection:(NSUInteger)section {
    return [gridViewItems count];
}


- (KKGridViewCell *)gridView:(KKGridView *)aGridView cellForItemAtIndexPath:(KKIndexPath *)indexPath {
    NSInteger index = indexPath.index;
    static NSString * CellIdentifier = @"GridViewCellIdentifier";
    ORImageViewCell *cell = (ORImageViewCell *)[aGridView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[ORImageViewCell alloc] initWithFrame:CGRectNull
                                          reuseIdentifier:CellIdentifier];
    }

    NSDictionary *item = [gridViewItems objectAtIndex:index];
    cell.item = item;
    cell.title = [item objectForKey:@"name"];
    cell.subtitle = [item objectForKey:@"created_at"];
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
    gridView.backgroundColor = [UIColor blackColor];
    gridView.showsHorizontalScrollIndicator = NO;
    gridView.contentInset = UIEdgeInsetsZero;
    gridView.accessibilityLabel = @"GridView";
    
    [self.view addSubview:gridView];    
}

- (void)viewDidUnload {
    [self setGridView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self setup];
}


@end
