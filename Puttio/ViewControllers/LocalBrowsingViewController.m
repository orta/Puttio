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
#import "ORDownloadCleanup.h"

#import "ORImageViewCell.h"
#import "MoviePlayer.h"
#import "ModalZoomView.h"
#import "NSManagedObject+ActiveRecord.h"

static UIEdgeInsets GridViewInsets = {.top = 126 + 8, .left = 8, .right = 8, .bottom = 8};

const CGSize LocalFileGridCellSize = { .width = 140.0, .height = 160.0 };

@interface LocalBrowsingViewController (){
    NSMutableArray *files_;
    GMGridView *gridView;
}

@end

@implementation LocalBrowsingViewController

#pragma mark -
#pragma mark View Setup

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupGestures];
    
    if ([UIDevice isPad]) {
        self.phoneBottomBarView.hidden = YES;
    }

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
    [self updateTitles];
}

- (void)dealloc {
    
}

- (void)updateTitles {
    [ORDownloadCleanup cleanup];

    // Space Left on Device
    self.deviceSpaceLeftLabel.text = [NSString stringWithFormat:@"You have %@ left on this device", [self getSpaceLeft]];
    self.phoneDeviceLeftLabel.text = [NSString stringWithFormat:@" %@ free space", [self getSpaceLeft]];


    // Space Used on Device
    self.deviceStoredLabel.text = [NSString stringWithFormat:@"This app is using %@", [self getDeviceSpaceUsed]];
    self.phoneDeviceStoredLabel.text = [NSString stringWithFormat:@"Using %@", [self getDeviceSpaceUsed]];
}

- (NSString *)getDeviceSpaceUsed {
    double bytes = [UIDevice numberOfBytesUsedInDocumentsDirectory];
    if (bytes > 100000) {
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
    if ([UIDevice isPad]) {
        frame.size.height = self.view.frame.size.height - GridViewInsets.top - GridViewInsets.bottom;
        frame.origin.y = GridViewInsets.top;
    }else {
        frame.origin.y = 100;
        frame.size.height = self.view.frame.size.height - frame.origin.y - GridViewInsets.bottom - CGRectGetHeight(_phoneBottomBarView.bounds);
    }

    frame.origin.x = GridViewInsets.left;

    [gridView setFrame:frame];
    [self updateTitles];
}

- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setNoItemsView:nil];
    [self setPhoneBottomBarView:nil];
    [self setPhoneDeviceStoredLabel:nil];
    [self setPhoneDeviceLeftLabel:nil];
    [super viewDidUnload];
}

#pragma mark -
#pragma mark Folder handlings

- (void)loadFolder:(Folder *)folder {
    [self reloadFolder];
}

- (void)reloadFolder {
    [self updateTitles];


    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *filesInUserDocs = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:&error];
    if (error) {
        NSLog(@"error %@", error.localizedDescription);
        return;
    }

    files_ = [NSMutableArray array];
    for (NSString *path in filesInUserDocs) {
        if ([path isEqualToString:@"Puttio.sqlite"]) continue;
        if ([path rangeOfString:@".txt"].location != NSNotFound) {
            LocalFile *file = [LocalFile fileWithTXTPath:path];
            [files_ addObject:file];
        }
    }

    [gridView reloadData];
    
    self.noItemsView.hidden = files_.count > 0;
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
    LocalFile *file = files_[position];
    [MoviePlayer watchLocalMovieAtPath:[file localPathForFile]];
    [self reloadFolder];
}

- (void)GMGridView:(GMGridView *)aGridView didLongTapOnItemAtIndex:(NSInteger)position {
    if (position == -1) return;
    LocalFile *file = files_[position];

    UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    CGRect initialFrame = [aGridView convertRect:[[aGridView cellForItemAtIndex:position] frame] toView:rootView];
    
    [ModalZoomView showFromRect:initialFrame withViewControllerIdentifier:@"deleteView" andItem:file];
}

#pragma mark -
#pragma mark GridView DataSource Methods

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView {
    return files_.count;
}

- (GMGridViewCell *)GMGridView:(GMGridView *)aGridView cellForItemAtIndex:(NSInteger)index {
    static NSString * CellIdentifier = @"GridViewCellIdentifier";
    ORImageViewCell *cell = (ORImageViewCell *)[aGridView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[ORImageViewCell alloc] initWithFrame:CGRectMake(0, 0, LocalFileGridCellSize.width, LocalFileGridCellSize.height)];
        cell.reuseIdentifier = CellIdentifier;
    }
    
    LocalFile *file = files_[index];
    
    cell.item = file;
    cell.title = file.name;
    cell.imageURL = [NSURL fileURLWithPath:[file localPathForScreenshot]];

    return cell;
}   

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation) orientation { 
    return LocalFileGridCellSize;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

@end
