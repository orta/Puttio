//
//  SearchViewController.m
//  Puttio
//
//  Created by orta therox on 25/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "SearchViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SearchResult.h"
#import "ORSearchCell.h"
#import "SearchController.h"
#import "StatusViewController.h"
#import "ORRotatingButton.h"

@interface SearchViewController () {
    NSArray *searchResults;
    NSString *lastSearchQuery;
}
@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self stylizeSearchTextField];
    [self setupShadow];
    [self setupGestures];
    [SearchController sharedInstance].delegate = self;
    self.activitySpinner.alpha = 0;
}

- (void)viewDidUnload {
    [self setSearchBar:nil];
    [self setTableView:nil];
    [self setActivitySpinner:nil];
    [self setNoResultsFoundView:nil];
    [self setTryChangingSettingsView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self makeSmallAnimated:NO];
    [self.statusViewController viewWillAppear:animated];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self reposition];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)stylizeSearchTextField {    
    for (int i = [_searchBar.subviews count] - 1; i >= 0; i--) {
        UIView *subview = (_searchBar.subviews)[i];                        

        // This is the gradient behind the textfield
        if ([subview.description hasPrefix:@"<UISearchBarBackground"]) {
            [subview removeFromSuperview];
        }
    }
    _searchBar.backgroundColor = [UIColor putioYellow];
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

- (void)setupGestures {
    UISwipeGestureRecognizer *backSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(backSwipeRecognised:)];
    backSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:backSwipe];
}

- (void)backSwipeRecognised:(UISwipeGestureRecognizer *)gesture {
    [self makeSmallAnimated:YES];
}

#pragma mark -
#pragma mark searchbar gubbins

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {
    [aSearchBar resignFirstResponder];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)aSearchBar {
    NSString *query = aSearchBar.text;
    if (query.length == 0 || [query isEqualToString:lastSearchQuery]) return;
    
    searchResults = @[];
    [SearchController searchForString:query];
    [self.activitySpinner fadeIn];

    self.noResultsFoundView.hidden = YES;
    self.tryChangingSettingsView.hidden = YES;

    [self.tableView reloadData];
    [aSearchBar resignFirstResponder];
    lastSearchQuery = query;
}

#pragma mark -
#pragma mark search controller

- (void)searchControllerFoundNoResults:(SearchController *)controller {
    BOOL useAllSearchEngines = [[NSUserDefaults standardUserDefaults] boolForKey:ORUseAllSearchEngines];
    [self.activitySpinner fadeOut];

    [UIView animateWithDuration:0.3 animations:^{
        self.noResultsFoundView.hidden = NO;
        self.noResultsFoundView.alpha = 1;
        if (!useAllSearchEngines) {
            self.tryChangingSettingsView.hidden = NO;
            self.tryChangingSettingsView.alpha = 1;
        }
    }];
}

- (void)searchController:(SearchController *)controller foundResults:(NSArray *)moreSearchResults {
    searchResults = [[searchResults arrayByAddingObjectsFromArray:moreSearchResults] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 ranking] == [obj2 ranking]) {
            return 0;
        }
        if ([obj1 ranking] < [obj2 ranking]) {
            return 1;
        }
        if ([obj1 ranking] > [obj2 ranking]) {
            return -1;
        }
        return 0;
    }];

    [self.activitySpinner fadeOut];
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
        SearchResult *item = searchResults[indexPath.row];
        ORSearchCell *theCell = (ORSearchCell*)cell;
        theCell.fileNameLabel.text = item.name;
        theCell.fileSizeLabel.text = item.representedSize;
        theCell.seedersLabel.text = [NSString stringWithFormat:@"%i seeders", item.seedersCount];
        
        switch (item.selectedState) {
            case SearchResultNormal:
                break;
            case SearchResultFailed:
                [theCell userHasFailedToAddFile];
                break;
            case SearchResultSending:
                [theCell userHasSelectedFile];
                break;
            case SearchResultSent:
                [theCell userHasAddedFile];
                break;
        }
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
    SearchResult *result = searchResults[indexPath.row];
    PutIOClient *client = [PutIOClient sharedClient];
    
    result.selectedState = SearchResultSending;
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];

    [client downloadTorrentOrMagnetURLAtPath:[result representedPath] :^(id userInfoObject) {              
        if ([userInfoObject isKindOfClass:[NSError class]]) {
            result.selectedState = SearchResultFailed;
        }else {
            result.selectedState = SearchResultSent;
        }
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }];    
}

-(void)scrollViewDidScroll:(UIScrollView *)sender {
    if ([self.searchBar isFirstResponder] && searchResults.count && !sender.isDecelerating) {
        [self.searchBar resignFirstResponder];
    }
}

- (void)reposition {
    [self resizeToWidth:self.view.frame.size.width animated:NO];
}

- (void)makeBigAnimated:(BOOL)animate {
    CGFloat width;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        width = 320;
    }else {
        width = 428;
    }
    [self resizeToWidth:width animated:animate];
}

- (void)makeSmallAnimated:(BOOL)animate {
    _searchBar.text = @"";
    [_searchBar performSelector: @selector(resignFirstResponder) 
                    withObject: nil 
                    afterDelay: 0.1];

    [self.activitySpinner fadeOut];
    self.noResultsFoundView.hidden = YES;
    self.tryChangingSettingsView.hidden = YES;

    [self resizeToWidth:88 animated:animate];
}


- (void)resizeToWidth:(CGFloat)width animated:(BOOL)animate {
    CGFloat duration = animate? 0.2 : 0;
    [UIView animateWithDuration:duration animations:^{
        CGRect frame = [self.view superview].bounds;
        CGFloat newWidth = width;
        frame.origin.x = frame.size.width - newWidth;
        frame.size.width = newWidth;
        self.view.frame = frame;
    }];

}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self makeBigAnimated:YES];    
}

@end
