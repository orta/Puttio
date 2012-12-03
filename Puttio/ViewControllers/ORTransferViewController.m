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

@interface ORTransferViewController (){
    NSArray *_transfers;
    NSTimer *_dataLoopTimer;
}
@property (weak, nonatomic) IBOutlet UIView *tableCellBack;
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
    if (_transfers) return;
//    _transfers = [self stubbedTransfers];
//    return;

    [self.tableView reloadData];

    [[PutIOClient sharedClient] getTransfers:^(NSArray *transfers) {
        _transfers = [[transfers reverseObjectEnumerator] allObjects];
        [self.tableView reloadData];

    } failure:^(NSError *error) {
        NSLog(@"error %@", [error localizedDescription]);
    }];
}

- (NSArray *)stubbedTransfers {
    NSMutableArray *stubbies = [NSMutableArray array];
    for (int i = 0; i < 15; i++) {
        Transfer *transfer = [[Transfer alloc] init];
        transfer.name = [NSString stringWithFormat:@"Stub %i", i];
        transfer.percentDone = @( arc4random() % 100 );
        transfer.downSpeed = @( arc4random() % 100 );
        transfer.estimatedTime = @( arc4random() % 100 );
        
        [stubbies addObject:transfer];
    }
    return stubbies;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _transfers.count;
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
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCell:)];
        [theCell addGestureRecognizer:tapGesture];
    }
    return cell;
}

- (void)tappedCell:(UITapGestureRecognizer *)gesture {
    ORExtendedTransferCell *cell = (ORExtendedTransferCell *)[gesture view];
    [cell showCancelButtonWithTarget:self];
}

- (void)cancelTapped:(UIButton *)sender {
    sender.enabled = NO;
    sender.alpha = 0.5;
    [[PutIOClient sharedClient] cancelTransfer:_transfers[sender.tag] :^{
        [self getTransfers];

        ORExtendedTransferCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:sender.tag inSection:0]];
        [cell deletedTransfer];

    } failure:^(NSError *error) {

    }];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setTableCellBack:nil];
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
