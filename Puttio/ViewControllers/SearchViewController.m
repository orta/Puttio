//
//  SearchViewController.m
//  Puttio
//
//  Created by orta therox on 25/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "SearchViewController.h"

@interface SearchViewController ()
- (void)stylizeSearchTextField;
@end

@implementation SearchViewController
@synthesize searchBar;

- (void)setup {
    CGRect space = [self.view.superview bounds];
    space.origin.y = 0;
    space.origin.x = space.size.width - SidebarWidth;
    space.size.width = SidebarWidth;
    self.view.frame = space;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self stylizeSearchTextField];

}

- (void)viewDidUnload {
    [self setSearchBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self setup];
}

- (void)stylizeSearchTextField {    
    for (int i = [searchBar.subviews count] - 1; i >= 0; i--) {
        UIView *subview = [searchBar.subviews objectAtIndex:i];                        

        // This is the gradient behind the textfield
        if ([subview.description hasPrefix:@"<UISearchBarBackground"]) {
            [subview removeFromSuperview];
        }
    }
    searchBar.backgroundColor = [UIColor putioYellow];
}

@end
