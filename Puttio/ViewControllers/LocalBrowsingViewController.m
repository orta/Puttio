//
//  LocalBrowsingViewController.m
//  Puttio
//
//  Created by David Grandinetti on 6/10/12.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "LocalBrowsingViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "FolderViewController.h"
#import "LocalFile.h"
#import "UIDevice+SpaceStats.h"

#import "ORImageViewCell.h"
#import "MoviePlayer.h"
#import "ModalZoomView.h"

static UIEdgeInsets GridViewInsets = {.top = 126 + 8, .left = 8, .right = 8, .bottom = 8};

const CGSize LocalFileGridCellSize = { .width = 140.0, .height = 160.0 };

@interface LocalBrowsingViewController (){
    NSMutableArray *files;
    GMGridView *gridView;
}

@end

@implementation LocalBrowsingViewController

#pragma mark -
#pragma mark View Setup

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupGestures];

    gridView = [[GMGridView alloc] initWithFrame:CGRectNull];
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
    
    [self.view insertSubview:gridView belowSubview:self.noItemsView];

    self.titleLabel.text = @"Saved Media Library";

    // Space Left on Device
    self.deviceSpaceLeftLabel.text = [NSString stringWithFormat:@"You have %@ left on this device", [self getSpaceLeft]];

    // Space Used on Device
    self.deviceStoredLabel.text = [NSString stringWithFormat:@"This app is using %@", [self getDeviceSpaceUsed]];
}

- (NSString *)getDeviceSpaceUsed {
    double bytes = [UIDevice numberOfBytesUsedInDocumentsDirectory];
    if (bytes > 1000000) {
        return [UIDevice humanStringFromBytes:bytes];
    }
    return @"no space";
}

- (NSString *)getSpaceLeft {
    return [UIDevice humanStringFromBytes:[UIDevice numberOfBytesFree]];
}

- (void)viewWillAppear:(BOOL)animated {
    CGRect frame = CGRectNull;
    frame.size.width = self.view.frame.size.width - GridViewInsets.left - GridViewInsets.right;
    frame.size.height = self.view.frame.size.height - GridViewInsets.top - GridViewInsets.bottom;
    frame.origin.x = GridViewInsets.left;
    frame.origin.y = GridViewInsets.top;
    
    [gridView setFrame:frame];
}

- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setNoItemsView:nil];
    [super viewDidUnload];
}

#pragma mark -
#pragma mark Folder handlings

- (void)loadFolder:(Folder *)folder {
    [self reloadFolder];
}

- (void)reloadFolder {
    files = [[LocalFile allObjects] mutableCopy];
    [gridView reloadData];
    
    self.noItemsView.hidden = files.count > 0;
}

#pragma mark -
#pragma mark Gestures

- (void)setupGestures {
    UISwipeGestureRecognizer *backSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(backSwipeRecognised:)];
    backSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:backSwipe];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureRecognised:)];
    [self.view addGestureRecognizer:pinchGesture];
}

- (void)pinchGestureRecognised:(UISwipeGestureRecognizer *)gesture {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)backSwipeRecognised:(UISwipeGestureRecognizer *)gesture {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark GridView Action Methods

- (void)GMGridView:(GMGridView *)aGridView didTapOnItemAtIndex:(NSInteger)position {
    LocalFile *file = files[position];
    [MoviePlayer watchLocalMovieAtPath:[file localPathForFile]];

    file.watched = @YES;
    [[file managedObjectContext] save:nil];
    [self reloadFolder];
}

- (void)GMGridView:(GMGridView *)aGridView didLongTapOnItemAtIndex:(NSInteger)position {
    if (position == -1) return;
    LocalFile *file = files[position];

    UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    CGRect initialFrame = [aGridView convertRect:[[aGridView cellForItemAtIndex:position] frame] toView:rootView];
    
    [ModalZoomView showFromRect:initialFrame withViewControllerIdentifier:@"deleteView" andItem:file];
}

#pragma mark -
#pragma mark GridView DataSource Methods

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView {
    return files.count;
}

- (GMGridViewCell *)GMGridView:(GMGridView *)aGridView cellForItemAtIndex:(NSInteger)index {
    static NSString * CellIdentifier = @"GridViewCellIdentifier";
    ORImageViewCell *cell = (ORImageViewCell *)[aGridView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[ORImageViewCell alloc] initWithFrame:CGRectMake(0, 0, LocalFileGridCellSize.width, LocalFileGridCellSize.height)];
        cell.reuseIdentifier = CellIdentifier;
    }
    
    LocalFile *file = files[index];
    
    cell.item = file;
    cell.title = file.name;
    cell.imageURL = [NSURL fileURLWithPath:[file localPathForScreenshot]];

    if (file.watched.boolValue == YES) {
        cell.watched = YES;
    }
    return cell;
}   

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation) orientation { 
    return LocalFileGridCellSize;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

@end
