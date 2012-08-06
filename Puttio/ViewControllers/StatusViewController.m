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
#import "UIDevice+SpaceStats.h"
#import "DCKnob.h"
#import "WEPopoverController.h"
#import "BaseProcess.h"

static StatusViewController *_sharedController;

@interface StatusViewController () {
    NSArray *transfers;
    NSArray *messages;
    NSMutableArray *processes;
    NSMutableDictionary *_processIDs;
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
    _processIDs = [NSMutableDictionary dictionary];
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
    self.spaceProgressView.allowsGestures = NO;
    self.spaceProgressView.valueArcWidth = 6.0;
    self.spaceProgressView.color = [UIColor putioBlue];
    self.spaceProgressView.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *accountSettingsTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapProgressView:)];
    [self.spaceProgressView.superview addGestureRecognizer:accountSettingsTapGesture];
}

- (void)didTapProgressView:(UITapGestureRecognizer*)gesture {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];

    NSString *identifier = [UIDevice isPad] ? @"accountView" : @"accountViewPhone";
    UIViewController *accountVC =  [storyboard instantiateViewControllerWithIdentifier:identifier];
    
    popoverController = [[WEPopoverController alloc] initWithContentViewController:accountVC];
    UINavigationController *rootController = (UINavigationController*)[UIApplication sharedApplication].keyWindow.rootViewController;
    
    [popoverController presentPopoverFromRect:[rootController.view convertRect:gesture.view.frame fromView:gesture.view.superview] inView:rootController.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
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
    [[PutIOClient sharedClient] getTransfers:^(id userInfoObject) {
        if (![userInfoObject isKindOfClass:[NSError class]]) {
            transfers = userInfoObject;
            transfers = [self onlyRecentTransfers:transfers];
            [self.tableView reloadData];
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
        if (transfer.status == TransferStatusERROR) continue;
        
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
            [self.tableView reloadData];
        }
    }];
}

- (void)getUserInfo {
    [[PutIOClient sharedClient] getUserInfo:^(id userInfoObject) {
        if (![userInfoObject isKindOfClass:[NSError class]]) {

            [[NSUserDefaults standardUserDefaults] setObject:[userInfoObject valueForKeyPath:@"id"] forKey:ORUserIdDefault];

            // compare the diskQuota, if it has changed from last time, record it in our Analytics
            NSString *oldDiskQuotaTotalString = [[NSUserDefaults standardUserDefaults] objectForKey:ORDiskQuotaTotalDefault];

            NSString *newDiskQuotaTotalString = [userInfoObject valueForKeyPath:@"info.disk.size"];
            double newDiskQuotaDouble = [newDiskQuotaTotalString doubleValue];
            NSString *diskQuotaTotalString = [UIDevice humanStringFromBytes:newDiskQuotaDouble];
            
            if( ![oldDiskQuotaTotalString isEqualToString:diskQuotaTotalString] ) {
                [Analytics event:@"User has changed thier Put.io account size"];
            }
            
            NSString *diskQuotaAvailableString = [userInfoObject valueForKeyPath:@"info.disk.avail"];
            float quotaPercentage = (float)[diskQuotaAvailableString longLongValue] / [newDiskQuotaTotalString longLongValue];
            
            [[NSUserDefaults standardUserDefaults] setFloat:quotaPercentage forKey:ORCurrentSpaceUsedPercentageDefault];
            [[NSUserDefaults standardUserDefaults] setObject:diskQuotaAvailableString forKey:ORDiskQuotaAvailableDefault];
            [[NSUserDefaults standardUserDefaults] setObject:diskQuotaTotalString forKey:ORDiskQuotaTotalDefault];
            self.spaceProgressView.value = quotaPercentage;
        }
        else {
            NSLog(@"Error %@", userInfoObject);
        }
    }];
}

- (void)addProcess:(BaseProcess *)process {
    if (_processIDs[process.id]) {
        return;
    }else{
        _processIDs[process.id] = process;
    }
    
    if (!processes) {
        processes = [@[process] mutableCopy];
    }else{
        [processes addObject:process];
    }
    [self.tableView reloadData];
}

- (void)processDidFinish:(BaseProcess *)process {
    [_processIDs removeObjectForKey:process.id];
    [processes removeObject:process];
    [self.tableView reloadData];
}

#pragma mark tableview gubbins

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    if (indexPath.section == DisplayTransfers) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"TransferCell"];
        if (cell) {
            Transfer *item = transfers[indexPath.row];
            ARTransferCell *theCell = (ARTransferCell*)cell;
            theCell.nameLabel.text = item.name;
            theCell.progressView.progress = [item.percentDone floatValue]/100;
            theCell.progressView.isLandscape = YES;
        }
    }
    
    if (indexPath.section == DisplayProcesses) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"TransferCell"];
        if (cell) {
            BaseProcess *item = processes[indexPath.row];
            ARTransferCell *theCell = (ARTransferCell*)cell;
            theCell.progressView.progress = item.progress;
            theCell.progressView.isLandscape = YES;
        }
    }
    
    if (indexPath.section == DisplayMessages) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"MessageCell"];
        if (cell) {
            Message *item = messages[indexPath.row];
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
    NSString *transferID = [UIDevice isPad] ? @"transferPopoverView" : @"transferPopoverViewPhone";
    ProcessPopoverViewController *transferVC = [storyboard instantiateViewControllerWithIdentifier:transferID];
    popoverController = [[WEPopoverController alloc] initWithContentViewController:transferVC];
    currentIndex = -1;
}

- (void)slidingTable:(ORSlidingTableView *)table didMoveToCellAtRow:(NSInteger)row inSection:(NSInteger)section {
    if (row != currentIndex) {
        id item = nil;
        if (section == DisplayTransfers) {
            if (row < transfers.count) {
                item = transfers[row];
            }
        }
        
        if (section == DisplayProcesses) {
            if (row < processes.count) {
                 item = processes[row];   
            }
        }
        
        if (item) {
            if ([popoverController.contentViewController isMemberOfClass:[ProcessPopoverViewController class]]) {
                NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
                CGRect originalRect = [self.tableView rectForRowAtIndexPath:path];
                UINavigationController *rootController = (UINavigationController*)[UIApplication sharedApplication].keyWindow.rootViewController;

                ProcessPopoverViewController *transferVC = (ProcessPopoverViewController*) popoverController.contentViewController;
                [popoverController presentPopoverFromRect:[rootController.view convertRect:originalRect fromView:self.tableView] inView:rootController.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];

                transferVC.item = item;
                currentIndex = row;
            }
        }
    }
}

- (void)slidingTableDidEndTouch:(ORSlidingTableView *)table {
    [popoverController dismissPopoverAnimated:YES];
    currentIndex = -1;
}


@end
