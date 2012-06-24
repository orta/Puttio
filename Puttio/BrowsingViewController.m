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
#import "FolderViewController.h"

#import "ORImageViewCell.h"
#import "MoviePlayer.h"
#import "ModalZoomView.h"
#import "TestFlight.h"

static UIEdgeInsets GridViewInsets = {.top = 88+8, .left = 8, .right = 88 + 8, .bottom = 8};

@interface BrowsingViewController (){
    UINavigationController *_gridNavController;
    Folder *currentFolder;
}
@end

@implementation BrowsingViewController
@synthesize titleLabel;
@synthesize offlineView;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupGestures];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadFolder) name:ORReloadFolderNotification object:nil];
    
    Folder *rootFolder = [Folder object];
    rootFolder.id = @"0";
    rootFolder.name = @"Home";
    rootFolder.parentID = @"0";
    [self loadFolder:rootFolder];
    self.titleLabel.text = @"";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadFolder];
}

- (IBAction)backPressed:(id)sender {
    [_gridNavController popViewControllerAnimated:YES];
}

- (void)setupNavWithFolderVC:(FolderViewController *)folderVC {
    CGRect frame = CGRectNull;
    frame.size.width = self.view.frame.size.width - GridViewInsets.left - GridViewInsets.right;
    frame.size.height = self.view.frame.size.height - GridViewInsets.top - GridViewInsets.bottom;
    frame.origin.x = GridViewInsets.left;
    frame.origin.y = GridViewInsets.top;
    
    _gridNavController = [[UINavigationController alloc] initWithRootViewController:folderVC];
    [self addChildViewController:_gridNavController];
    _gridNavController.view.frame = frame;
    _gridNavController.delegate = self;
    _gridNavController.navigationBarHidden = YES;
    [self.view addSubview:_gridNavController.view];
    [self.view sendSubviewToBack:_gridNavController.view];
}

- (void)setupGestures {
    UISwipeGestureRecognizer *backSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(backSwipeRecognised:)];
    backSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:backSwipe];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGestureRecognised:)];
    [self.view addGestureRecognizer:pinchGesture];
}

- (void)pinchGestureRecognised:(UISwipeGestureRecognizer *)gesture {
    [_gridNavController popToRootViewControllerAnimated:YES];
}

- (void)backSwipeRecognised:(UISwipeGestureRecognizer *)gesture {
    [_gridNavController popViewControllerAnimated:YES];
}

- (void)reloadFolder {
    [[PutIOClient sharedClient] getFolder:currentFolder :^(id userInfoObject) {
        if (![userInfoObject isKindOfClass:[NSError class]]) {
            FolderViewController *topFolder = (FolderViewController *)[_gridNavController topViewController];
            
            topFolder.folderItems = (NSArray *)userInfoObject;
            topFolder.folder = currentFolder;
            topFolder.browsingViewController = self;
        }
    }];
}

- (void)loadFolder:(Folder *)folder {
    currentFolder = folder;
    
    [[PutIOClient sharedClient] getFolder:folder :^(id userInfoObject) {
        if (![userInfoObject isKindOfClass:[NSError class]]) {
            self.offlineView.hidden = YES;
            
            FolderViewController *folderGrid = [[FolderViewController alloc] init];
            folderGrid.browsingViewController = self;
            folderGrid.folder = folder;
            folderGrid.folderItems = (NSArray *)userInfoObject;
            folderGrid.browsingViewController = self;
            
            if (_gridNavController) {
                [_gridNavController pushViewController:folderGrid animated:YES];   
            }else{
                [self setupNavWithFolderVC:folderGrid];
            }
        }else {
            NSError *error = (NSError *)userInfoObject;
            // offline error code
            if (error.code == -1009) {
                [self isOffline];
            }
        }
    }];
}

- (void)GMGridView:(GMGridView *)aGridView didTapOnItemAtIndex:(NSInteger)position {
    FolderViewController *topFolder = (FolderViewController *)[_gridNavController topViewController];
    NSObject <ORDisplayItemProtocol> *item = (topFolder.folderItems)[position];   
    if ([self itemIsFolder:item]) {
        Folder *folder = (Folder *)item;
        [self loadFolder:folder];
    }else {
        UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
        CGRect initialFrame = [topFolder.gridView convertRect:[[topFolder.gridView cellForItemAtIndex:position] frame] toView:rootView];
        [ModalZoomView showFromRect:initialFrame withViewControllerIdentifier:@"FileInfoView" andItem:item];
    }
}

- (void)GMGridView:(GMGridView *)gridView didLongTapOnItemAtIndex:(NSInteger)position {
    FolderViewController *topFolder = (FolderViewController *)[_gridNavController topViewController];
    NSObject <ORDisplayItemProtocol> *item = (topFolder.folderItems)[position];   
    
    UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    CGRect initialFrame = [topFolder.gridView convertRect:[[topFolder.gridView cellForItemAtIndex:position] frame] toView:rootView];
    
    [ModalZoomView showFromRect:initialFrame withViewControllerIdentifier:@"deleteView" andItem:item];
}

- (BOOL)itemIsFolder:(NSObject <ORDisplayItemProtocol> *)item {
    return ([item.size intValue] == 0) ? YES : NO;
}

- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [self setOfflineView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController isMemberOfClass:[FolderViewController class]]) {
        FolderViewController *folderVC = (FolderViewController *)viewController;
        self.titleLabel.text = folderVC.folder.name;
    }
}

- (void)isOffline {
    self.offlineView.hidden = NO;
    [self.view bringSubviewToFront:self.offlineView];
}

@end
