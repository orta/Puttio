//
//  SearchViewController.m
//  Puttio
//
//  Created by orta therox on 25/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

// http://www.mininova.org/vuze.php?search=michael%2Bjackson
// http://isohunt.com/js/json.php?ihq=jacko

#import "SearchViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SearchResult.h"
#import "ORSearchCell.h"
#import "SearchController.h"

@interface SearchViewController () {
    NSArray *searchResults;
}

- (void)stylizeSearchTextField;
@end

@implementation SearchViewController
@synthesize searchBar;
@synthesize tableView;

- (void)setup {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self stylizeSearchTextField];
    [self setupShadow];
    [SearchController sharedInstance].delegate = self;
}

- (void)viewDidUnload {
    [self setSearchBar:nil];
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
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

- (void)setupShadow {
    self.view.clipsToBounds = NO;
    
    CALayer *layer = self.view.layer;
    layer.masksToBounds = NO;
    layer.shadowOffset = CGSizeZero;
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowRadius = 4;
    layer.shadowOpacity = 0.2;
}

#pragma mark -
#pragma mark searchbar gubbins

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {
    [self searchBarTextDidEndEditing:aSearchBar];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)aSearchBar {
    searchResults = [NSArray array];
    [SearchController searchForString:aSearchBar.text];
    [self.tableView reloadData];
    [aSearchBar resignFirstResponder];
}

#pragma mark -
#pragma mark search controller

- (void)searchController:(SearchController *)controller foundResults:(NSArray *)moreSearchResults {
    searchResults = [[searchResults arrayByAddingObjectsFromArray:moreSearchResults] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 ranking] == [obj2 ranking]) {
            return 0;
        }
        if ([obj1 ranking] > [obj2 ranking]) {
            return 1;
        }
        if ([obj1 ranking] < [obj2 ranking]) {
            return -1;
        }
        return 0;
    }];
    
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark tableview gubbins

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    cell = [aTableView dequeueReusableCellWithIdentifier:@"SearchCell"];
    if (cell) {
        SearchResult *item = [searchResults objectAtIndex:indexPath.row];
        ORSearchCell *theCell = (ORSearchCell*)cell;
        theCell.fileNameLabel.text = item.name;
        theCell.fileSizeLabel.text = item.representedSize;
        theCell.seedersLabel.text = [NSString stringWithFormat:@"%i seeders", item.seedersCount];
    }    
    return cell;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return searchResults.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchResult *result = [searchResults objectAtIndex:indexPath.row];
    PutIOClient *client = [PutIOClient sharedClient];
    [client downloadTorrentOrMagnetURLAtPath:[result representedPath] :^(id userInfoObject) {
        ORSearchCell *cell = (ORSearchCell*)[self.tableView cellForRowAtIndexPath:indexPath];

        if ([userInfoObject isMemberOfClass:[NSError class]]) {
            [cell userHasFailedToAddFile];
        }else {
            [cell userHasAddedFile];
        }
    }];
    
}

@end
