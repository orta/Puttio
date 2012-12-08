//
//  ORTransferViewController.m
//  Puttio
//
//  Created by orta therox on 14/11/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ORTransferViewController.h"
#import "ORExtendedTransferCell.h"
#import "ORDestructiveButton.h"
#import "ModalZoomView.h"
#import "ORTorrentBrowserViewController.h"
#import "WEPopoverController.h"
#import "ORRemoveTransferPopoverViewController.h"

@interface ORTransferViewController (){
    NSArray *_transfers;
    NSTimer *_dataLoopTimer;
    BOOL _showingDelete;

    WEPopoverController *_deletePopover;
    ORRemoveTransferPopoverViewController *_removeVC;

    int _deletedCount;
    int _selectedIndex;
}

@property (weak, nonatomic) IBOutlet UIView *deleteView;
@property (weak, nonatomic) IBOutlet ORDestructiveButton *removeButton;
@property (weak, nonatomic) IBOutlet UILabel *deleteViewLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ORTransferViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startTimer];
    [self setupGestures];
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

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_dataLoopTimer invalidate];
}

- (void)startTimer {
    if (!_dataLoopTimer) {
        _dataLoopTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(beat) userInfo:nil repeats:YES];
        [_dataLoopTimer fire];
    }
}

- (void)beat {
    [self getTransfers];
}

- (void)getTransfers {
    [[PutIOClient sharedClient] getTransfers:^(NSArray *transfers) {
        _transfers = [[transfers reverseObjectEnumerator] allObjects];
        [self.tableView reloadData];

    } failure:^(NSError *error) {
        NSLog(@"error %@", [error localizedDescription]);
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _transfers.count -_deletedCount;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    cell = [aTableView dequeueReusableCellWithIdentifier:@"ExtendedTransferCell"];
    if (cell) {
        Transfer *item = _transfers[indexPath.row];
        ORExtendedTransferCell *theCell = (ORExtendedTransferCell *)cell;
        theCell.transfer = item;
        theCell.tag = indexPath.row;
        theCell.selectionStyle = UITableViewCellSelectionStyleNone;
        theCell.alpha = 1;        
    }
    return cell;
}

- (void)viewWillDisappear:(BOOL)animated {
    [_deletePopover dismissPopoverAnimated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!_showingDelete && [UIDevice isPhone]) {
        // Initially show the cancel panel at the bottom 

        _deleteView.hidden = NO;
        _showingDelete = YES;

        [UIView animateWithDuration:0.15 animations:^{
            CGRect newTableViewSize = _tableView.frame;
            newTableViewSize.size.height -= CGRectGetHeight(_deleteView.bounds);
            _tableView.frame = newTableViewSize;

            _deleteView.frame = CGRectOffset(_deleteView.frame, 0, -1 * CGRectGetHeight(_deleteView.bounds));
        }];
    }
    
    if (!_showingDelete && [UIDevice isPad]) {
        // show a popover with the cancel button
        
        _showingDelete = YES;

         _removeVC =  [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"RemovePopoverTransferView"];
        [_removeVC setTransferViewController:self];

        _deletePopover = [[WEPopoverController alloc] initWithContentViewController:_removeVC];
        _deletePopover.passthroughViews = @[self.view];
    }

    
    // Deal with the iPad popovers
    CGRect targetCellFrame = [_tableView cellForRowAtIndexPath:indexPath].frame;
    targetCellFrame = [self.view convertRect:targetCellFrame fromView:_tableView];
    [_deletePopover presentPopoverFromRect:targetCellFrame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];

    [_removeVC setTransfer:_transfers[indexPath.row]];

    // Deal with the iPhone bottom nav
    _removeButton.enabled = YES;
    _removeButton.alpha = 1;

    _selectedIndex = indexPath.row;
    _deleteViewLabel.text = [[_transfers objectAtIndex:indexPath.row] displayName];
}

- (IBAction)deleteTapped:(UIButton *)sender {
    if (_selectedIndex == NSNotFound) return;

    _removeButton.enabled = NO;
    _removeButton.alpha = 0.5;
    _deletedCount++;

    NSIndexPath *cellPath = [NSIndexPath indexPathForRow:_selectedIndex inSection:0];
    [_tableView deleteRowsAtIndexPaths:@[cellPath] withRowAnimation:UITableViewRowAnimationAutomatic];

    [[PutIOClient sharedClient] cancelTransfer:_transfers[_selectedIndex] :^{
        _deletedCount--;
        [self getTransfers];

        [_deletePopover dismissPopoverAnimated:YES];
        _selectedIndex = NSNotFound;
        _deleteViewLabel.text = @"";

    } failure:^(NSError *error) {
        _deletedCount--;
        _removeButton.enabled = YES;
        _removeButton.alpha = 1;
        _selectedIndex = NSNotFound;

        _deleteViewLabel.text = @"Failed to remove! Put.IO might be down :(";
    }];

}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setDeleteView:nil];
    [self setDeleteViewLabel:nil];
    [self setRemoveButton:nil];
    [super viewDidUnload];
}

- (IBAction)addLinkTapped:(id)sender {
    [ModalZoomView showWithViewControllerIdentifier:@"AddTorrentFromLinkView"];
}

- (IBAction)browseTapped:(id)sender {
    NSString *identifier = [UIDevice isPhone] ? @"TorrentBrowserPhoneView": @"TorrentBrowserView";
    UIViewController *controller = [[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:identifier];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
