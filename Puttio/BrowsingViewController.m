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
#import "TestFlight.h"

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

- (void)viewDidLoad {
    [super viewDidLoad];
    if(!gridView){
        [self setupGridView];
    }
    
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

- (IBAction)feedbackPressed:(id)sender {
    [TestFlight openFeedbackView];
}

- (void)loadFolder:(Folder *)folder {
    [[PutIOClient sharedClient] getFolder:folder :^(id userInfoObject) {
        if (![userInfoObject isKindOfClass:[NSError class]]) {
            self.item = folder;
            gridViewItems = userInfoObject;
            [gridView reloadData];
        }
    }];
}

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position {
    NSObject <ORDisplayItemProtocol> *item = [gridViewItems objectAtIndex:position];   
    if ([self itemIsFolder:item]) {
        Folder *folder = (Folder *)item;
        [self loadFolder:folder];
    }else {
        UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
        CGRect initialFrame = [gridView convertRect:[[gridView cellForItemAtIndex:position] frame] toView:rootView];
        [ModalZoomView showFromRect:initialFrame withViewControllerIdentifier:@"FileInfoView" andItem:item];
    }
}

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView {
    return [gridViewItems count];
}

- (GMGridViewCell *)GMGridView:(GMGridView *)aGridView cellForItemAtIndex:(NSInteger)index {

    static NSString * CellIdentifier = @"GridViewCellIdentifier";
    ORImageViewCell *cell = (ORImageViewCell *)[aGridView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[ORImageViewCell alloc] initWithFrame:CGRectMake(0, 0, GridCellSize.width, GridCellSize.height)];
        cell.reuseIdentifier = CellIdentifier;
    }

    NSObject <ORDisplayItemProtocol> *item = [gridViewItems objectAtIndex:index];
    cell.item = item;
    cell.title = item.displayName;
    if ([self itemIsFolder:item]) {
        cell.imageURL = [NSURL URLWithString:item.screenShotURL];
    }else{
        cell.imageURL = [NSURL URLWithString: [PutIOClient appendOauthToken:item.screenShotURL]];
    }
    return cell;
}   

- (void)setupGridView {
    CGRect frame = CGRectNull;
    
    frame.size.width = self.view.frame.size.width - GridViewInsets.left - GridViewInsets.right;
    frame.size.height = self.view.frame.size.height - GridViewInsets.top - GridViewInsets.bottom;
    frame.origin.x = GridViewInsets.left;
    frame.origin.y = GridViewInsets.top;

    gridView = [[GMGridView alloc] initWithFrame:frame];
    gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    gridView.autoresizesSubviews = YES;
    gridView.actionDelegate = self;
    gridView.dataSource = self;
    gridView.clipsToBounds = YES;
    gridView.userInteractionEnabled = YES;
    gridView.backgroundColor = [UIColor whiteColor];
    gridView.showsHorizontalScrollIndicator = NO;
    gridView.contentInset = UIEdgeInsetsZero;
    gridView.accessibilityLabel = @"GridView";
    
    [self.view addSubview:gridView];    
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation) orientation { 
    return GridCellSize;
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

- (BOOL)itemIsFolder:(NSObject*)item {
    // jeez, I must be doing something wrong here..
    NSObject <ORDisplayItemProtocol> *displayItem = (NSObject <ORDisplayItemProtocol> *)item;
    if ([displayItem.size intValue] == 0) {
        return YES;
    }
    return NO;
}


@end
