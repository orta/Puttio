//
//  StatusViewController.m
//  Puttio
//
//  Created by orta therox on 25/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "StatusViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ORSimpleProgress.h"
#import "ProcessPopoverViewController.h"
#import "ARTransferCell.h"
#import "ORMessageCell.h"
#import "NSDate+StringParsing.h"
#import "UIColor+PutioColours.h"
#import "DCKnob.h"
#import "WEPopoverController.h"
#import "BaseProcess.h"

static StatusViewController *_sharedController;

@interface StatusViewController () {
    NSArray *transfers;
    NSArray *messages;
    NSArray *processes;
    
    CGFloat currentIndex;
    NSTimer *dataLoopTimer;
    
    WEPopoverController *popoverController;
}
@end

@implementation StatusViewController

typedef enum {
    DisplayTransfers,
    DisplayProcesses,
    DisplayMessages
} Display;

@synthesize tableView;
@synthesize spaceProgressView, spaceProgressBG, spaceLabel;

+ (StatusViewController *)sharedController {
    return _sharedController;
}

- (void)awakeFromNib {
    _sharedController = self;
    [self setup];
}

- (void)setup {
    [self setupShadow];
    [self startTimer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.spaceProgressBG.max = 1;
    self.spaceProgressBG.value = 1;
    self.spaceProgressBG.allowsGestures = NO;
    self.spaceProgressBG.valueArcWidth = 6.0;
    self.spaceProgressBG.color = [UIColor putioYellow];
    self.spaceProgressBG.backgroundColor = [UIColor clearColor];
    
    self.spaceProgressView.min = 0.0;
	self.spaceProgressView.max = 1.0;
    self.spaceProgressView.value = 0;
    self.spaceProgressView.allowsGestures = NO;
    self.spaceProgressView.valueArcWidth = 6.0;
    self.spaceProgressView.color = [UIColor putioBlue];
    self.spaceProgressView.backgroundColor = [UIColor clearColor];
}

- (void)startTimer {
    if (!dataLoopTimer) {
        dataLoopTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(beat) userInfo:nil repeats:YES];
        [dataLoopTimer fire];        
    }
}

- (void)beat { 
    [self getUserInfo];
    [self getTransfers];
//    [self getMessages];
}

- (void)getTransfers {
    Transfer *transfer = [[Transfer alloc] init];
    transfer.name = @"2123";
    transfer.downloadSpeed =  @44;
    transfer.percentDone =  @33;
    transfer.displayName = @"23123 display";
    transfers = @[transfer, transfer, transfer];
    
    [[PutIOClient sharedClient] getTransfers:^(id userInfoObject) {
        if (![userInfoObject isKindOfClass:[NSError class]]) {
            transfers = userInfoObject;
            transfers = [self onlyRecentTransfers:transfers];
            [tableView reloadData];
        }
    }];
}

- (NSArray *)onlyRecentTransfers: (NSArray*)inTransfers {
    NSMutableArray *newTransfers = [NSMutableArray array];
    
    NSDate *today = [[NSDate alloc] init];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *minusDaysComponents = [[NSDateComponents alloc] init];
    [minusDaysComponents setDay: -3];
    NSDate *threeDaysAgo = [calendar dateByAddingComponents:minusDaysComponents toDate:today options:0];
    
    for (Transfer *transfer in inTransfers) {
        if (transfer.percentDone.intValue != 100) {
            [newTransfers addObject:transfer];
        }else{    
            NSDate *date = [NSDate dateWithISO8601String:transfer.createdAt];
            if ([threeDaysAgo compare:date] == NSOrderedAscending) {
                [newTransfers addObject:transfer];
            }
        }
    }
    return newTransfers;
}

- (void)getMessages {
    [[PutIOClient sharedClient] getMessages:^(id userInfoObject) {
        if (![userInfoObject isKindOfClass:[NSError class]]) {
            messages = userInfoObject;
            [tableView reloadData];
        }
    }];
}

- (void)getUserInfo {
    [[PutIOClient sharedClient] getUserInfo:^(id userInfoObject) {
        if (![userInfoObject isKindOfClass:[NSError class]]) {

            [[NSUserDefaults standardUserDefaults] setObject:[userInfoObject valueForKeyPath:@"id"] forKey:ORUserIdDefault];
            NSString *diskQuotaString = [[userInfoObject valueForKeyPath:@"response.results.disk_quota"] objectAtIndex:0];
            NSString *diskQuotaAvailableString = [[userInfoObject valueForKeyPath:@"response.results.disk_quota_available"] objectAtIndex:0];

            float quotaPercentage = (float)[diskQuotaAvailableString longLongValue] / [diskQuotaString longLongValue];
            self.spaceProgressView.value = quotaPercentage;

            self.spaceLabel.text = [NSString stringWithFormat:@"%0.0f%%", (quotaPercentage*100)];
        }
    }];
}

- (void)addProcess:(BaseProcess *)process {
    if (!processes) {
        processes = [NSArray arrayWithObject:process];
    }else{
        processes = [processes arrayByAddingObject:process];
    }
}

#pragma mark tableview gubbins

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    if (indexPath.section == DisplayTransfers) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TransferCell"];
        if (cell) {
            Transfer *item = [transfers objectAtIndex:indexPath.row];
            ARTransferCell *theCell = (ARTransferCell*)cell;
            theCell.nameLabel.text = item.name;
            theCell.progressView.progress = [item.percentDone floatValue]/100;
            theCell.progressView.isLandscape = YES;
        }
    }
    
    if (indexPath.section == DisplayProcesses) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TransferCell"];
        if (cell) {
            BaseProcess *item = [processes objectAtIndex:indexPath.row];
            ARTransferCell *theCell = (ARTransferCell*)cell;
            theCell.progressView.progress = item.progress;
            theCell.progressView.isLandscape = YES;
        }
    }
    
    if (indexPath.section == DisplayMessages) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell"];
        if (cell) {
            Message *item = [messages objectAtIndex:indexPath.row];
            ORMessageCell *theCell = (ORMessageCell*)cell;
            theCell.messageLabel.text = item.message;
        }
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case DisplayTransfers:
            return transfers.count;
        case DisplayMessages:
            return messages.count;
        case DisplayProcesses:
            return processes.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 24;
}

- (void)viewDidUnload {
    [self setSpaceProgressView:nil];
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self setup];
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
#pragma mark Sliding TableView

- (void)slidingTableDidBeginTouch:(ORSlidingTableView *)table {
    if (!transfers.count) {
        return;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
    ProcessPopoverViewController *transferVC = [storyboard instantiateViewControllerWithIdentifier:@"transferPopoverView"];
    popoverController = [[WEPopoverController alloc] initWithContentViewController:transferVC];
    currentIndex = -1;
}

- (void)slidingTable:(ORSlidingTableView *)table didMoveToCellAtRow:(NSInteger)row inSection:(NSInteger)section {
    if (row != currentIndex) {
        id item = nil;
        if (section == DisplayTransfers) {
            if (row < transfers.count) {
                item = [transfers objectAtIndex:row];
            }
        }
        
        if (section == DisplayProcesses) {
            if (row < processes.count) {
                 item = [processes objectAtIndex:row];   
            }
        }
        
        if (item) {
            NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
            CGRect originalRect = [tableView rectForRowAtIndexPath:path];
            UINavigationController *rootController = (UINavigationController*)[UIApplication sharedApplication].keyWindow.rootViewController;
            
            ProcessPopoverViewController * transferVC = (ProcessPopoverViewController*) popoverController.contentViewController;
            
            [popoverController presentPopoverFromRect:[rootController.view convertRect:originalRect fromView:tableView] inView:rootController.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
            
            transferVC.item = item;
            currentIndex = row;
        }
    }
}

- (void)slidingTableDidEndTouch:(ORSlidingTableView *)table {
    [popoverController dismissPopoverAnimated:YES];
    currentIndex = -1;
}

@end
