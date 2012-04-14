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
#import "FileSizeUtils.h"
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
    [self fakeSearchResults];
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
#pragma mark searchbar gubbins

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {
    [SearchController searchForString:aSearchBar.text];    
}

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
        theCell.fileSizeLabel.text = unitStringFromBytes(item.size);
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

- (void)fakeSearchResults {
    SearchResult *results1 = [[SearchResult alloc] init];
    results1.name = @"result1";
    results1.size = 1233334;
    results1.seedersCount = 11;
    results1.peersCount = 10;
    [results1 generateRanking];
    
    SearchResult *results12 = [[SearchResult alloc] init];
    results12.name = @"this is a pretty long one I think right? XVID MP4";
    results12.size = 23321115352;
    results12.seedersCount = 231;
    results12.peersCount = 200;
    [results12 generateRanking];
    
    SearchResult *results13 = [[SearchResult alloc] init];
    results13.name = @"another files a bit more ";
    results13.size = 23124;
    results13.seedersCount = 23;
    results13.peersCount = 10;
    [results13 generateRanking];
    
    searchResults = [NSArray arrayWithObjects:results1, results12, results13, nil];
}

- (void)searchController:(SearchController *)controller foundResults:(NSArray *)moreSearchResults {
    searchResults = [searchResults arrayByAddingObjectsFromArray:moreSearchResults];
    [self.tableView reloadData];
}

@end
