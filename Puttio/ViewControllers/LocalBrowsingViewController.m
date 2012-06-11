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

#import "ORImageViewCell.h"
#import "MoviePlayer.h"
#import "ModalZoomView.h"
#import "TestFlight.h"

static UIEdgeInsets GridViewInsets = {.top = 44 + 8, .left = 8, .right = 8, .bottom = 8};

const CGSize LocalFileGridCellSize = { .width = 140.0, .height = 160.0 };

@implementation LocalBrowsingViewController
@synthesize files, gridView, titleLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupGestures];

    CGRect frame = CGRectMake(0, 44, 400, 400);

    files = [NSMutableArray array];
    [self reloadFolder];

    gridView = [[GMGridView alloc] initWithFrame:frame];
    gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    gridView.autoresizesSubviews = YES;
    gridView.actionDelegate = self;
    gridView.dataSource = self;
    gridView.clipsToBounds = YES;
    gridView.userInteractionEnabled = YES;
    gridView.backgroundColor = [UIColor yellowColor];
    gridView.showsHorizontalScrollIndicator = NO;
    gridView.contentInset = UIEdgeInsetsZero;
    gridView.accessibilityLabel = @"GridView";
    
    [self.view addSubview:gridView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadFolder) name:ORReloadFolderNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadFolder];

    CGRect frame = CGRectNull;
    frame.size.width = self.view.frame.size.width - GridViewInsets.left - GridViewInsets.right;
    frame.size.height = self.view.frame.size.height - GridViewInsets.top - GridViewInsets.bottom;
    frame.origin.x = GridViewInsets.left;
    frame.origin.y = GridViewInsets.top;
    
    [gridView setFrame:frame];
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

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

- (void)reloadFolder {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSArray *fileNames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:NULL];
    for (NSString *fileName in fileNames) {
        //iterate through all the files and look for mp4 files
        if( [fileName hasSuffix:@"mp4"] ) {
            NSLog(@"loading mp4 file for local view: %@", fileName);
            LocalFile *localFile = [[LocalFile alloc] init];
            localFile.name = fileName;
            // this would be the place to check for a screenshot
            [files addObject:localFile];
        }
    }
}

//
// open the file view to play the movie
//
- (void)GMGridView:(GMGridView *)aGridView didTapOnItemAtIndex:(NSInteger)position {
    LocalFile *file = [files objectAtIndex:position]; 
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[file name]];
    NSString *fullPath = [NSString stringWithFormat:@"%@", filePath];
    [MoviePlayer watchLocalMovieAtPath:fullPath];
//    
//    UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
//    CGRect initialFrame = [gridView convertRect:[[gridView cellForItemAtIndex:position] frame] toView:rootView];
//    [ModalZoomView showFromRect:initialFrame withViewControllerIdentifier:@"FileInfoView" andItem:file];
}

//
// delete the file
//
- (void)GMGridView:(GMGridView *)aGridView didLongTapOnItemAtIndex:(NSInteger)position {
    LocalFile *file = [files objectAtIndex:position]; 

    UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    CGRect initialFrame = [gridView convertRect:[[gridView cellForItemAtIndex:position] frame] toView:rootView];
    
    [ModalZoomView showFromRect:initialFrame withViewControllerIdentifier:@"deleteView" andItem:file];
}

#pragma mark -
#pragma mark GridView DataSource Methods

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView {
    NSLog(@"numberOfItems");
    return [files count];
}

- (GMGridViewCell *)GMGridView:(GMGridView *)aGridView cellForItemAtIndex:(NSInteger)index {
    static NSString * CellIdentifier = @"GridViewCellIdentifier";
    ORImageViewCell *cell = (ORImageViewCell *)[aGridView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[ORImageViewCell alloc] initWithFrame:CGRectMake(0, 0, LocalFileGridCellSize.width, LocalFileGridCellSize.height)];
        cell.reuseIdentifier = CellIdentifier;
    }
    
    LocalFile *file = [files objectAtIndex:index]; 
    
    cell.item = file;
    cell.title = file.name;
    cell.imageURL = [NSURL URLWithString:@"https://put.io/thumbnails/aItkkZFhXV5lXl1miGlmYmOOWpSLV5FYZ2SRlmNfYl6JYlqYY5FoYg.jpg"];

    //
    // we currently don't keep track of wacthing local media
    //
    cell.watched = NO;

    return cell;
}   

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation) orientation { 
    return LocalFileGridCellSize;
}

- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}



@end

