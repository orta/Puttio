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

static UIEdgeInsets GridViewInsets = {.top = 60, .left = 6, .right = 66, .bottom = 5};

@interface BrowsingViewController (){
    UINavigationController *_gridNavController;
}
@end

@implementation BrowsingViewController
@synthesize titleLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNav];
    
    Folder *rootFolder = [Folder object];
    rootFolder.id = @"0";
    rootFolder.name = @"Home";
    rootFolder.parentID = @"0";
    [self loadFolder:rootFolder];
}

- (IBAction)backPressed:(id)sender {
    [_gridNavController popViewControllerAnimated:YES];
}


- (void)setupNav {
    CGRect frame = CGRectNull;
    frame.size.width = self.view.frame.size.width - GridViewInsets.left - GridViewInsets.right;
    frame.size.height = self.view.frame.size.height - GridViewInsets.top - GridViewInsets.bottom;
    frame.origin.x = GridViewInsets.left;
    frame.origin.y = GridViewInsets.top;
    
    _gridNavController = [[UINavigationController alloc] init];
    [self addChildViewController:_gridNavController];
    _gridNavController.view.frame = frame;
    _gridNavController.navigationBarHidden = YES;
    [self.view addSubview:_gridNavController.view];
}

- (void)loadFolder:(Folder *)folder {
    [[PutIOClient sharedClient] getFolder:folder :^(id userInfoObject) {
        if (![userInfoObject isKindOfClass:[NSError class]]) {
            
            FolderViewController *folderGrid = [[FolderViewController alloc] init];
            folderGrid.browsingViewController = self;
            folderGrid.folder = folder;
            folderGrid.folderItems = (NSArray *)userInfoObject;
            
            [_gridNavController pushViewController:folderGrid animated:YES];
        }
    }];
}

- (void)GMGridView:(GMGridView *)aGridView didTapOnItemAtIndex:(NSInteger)position {
    FolderViewController *topFolder = (FolderViewController *)[_gridNavController topViewController];
    NSObject <ORDisplayItemProtocol> *item = [topFolder.folderItems objectAtIndex:position];   
    if ([self itemIsFolder:item]) {
        Folder *folder = (Folder *)item;
        [self loadFolder:folder];
    }else {
        UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
        CGRect initialFrame = [topFolder.gridView convertRect:[[topFolder.gridView cellForItemAtIndex:position] frame] toView:rootView];
        [ModalZoomView showFromRect:initialFrame withViewControllerIdentifier:@"FileInfoView" andItem:item];
    }
}

- (BOOL)itemIsFolder:(NSObject <ORDisplayItemProtocol> *)item {
    return ([item.size intValue] == 0) ? YES : NO;
}

- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

@end
