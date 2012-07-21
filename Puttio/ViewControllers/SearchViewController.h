//
//  SearchViewController.h
//  Puttio
//
//  Created by orta therox on 25/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchController.h"

@class StatusViewController, ORRotatingButton;

@interface SearchViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, SearchResultsDelegate>

@property (weak, nonatomic) IBOutlet ORRotatingButton *activitySpinner;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet StatusViewController *statusViewController;

@property (weak, nonatomic) IBOutlet UIView *noResultsFoundView;
@property (weak, nonatomic) IBOutlet UIView *tryChangingSettingsView;

- (void)reposition;
@end
