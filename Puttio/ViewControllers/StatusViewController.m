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

#import "ARTransferCell.h"
#import "ORMessageCell.h"
#import "NSDate+StringParsing.h"

@interface StatusViewController () {
    NSArray *transfers;
    NSArray *messages;
    
    CGFloat xOffset;
    NSTimer *dataLoopTimer;
}
@end

@implementation StatusViewController

typedef enum {
    DisplayTransfers,
    DisplayMessages
} Display;

@synthesize tableView;
@synthesize spaceProgressView, spaceLabel;



- (void)setup {
    NSLog(@"setup");
    [self setupShadow];
    [self startTimer];
}

- (void)awakeFromNib {
    [self setup];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
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
            [tableView reloadData];
        }
    }];
}

- (NSArray *)onlyRecentTransfers: (NSArray*)inTransfers {
    NSMutableArray *newTransfers = [NSMutableArray array];
    
    NSDate *today = [[NSDate alloc] init];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *minusDaysComponents = [[NSDateComponents alloc] init];
    NSDate *threeDaysAgo = [calendar dateByAddingComponents:minusDaysComponents toDate:today options:0];
    
    for (Transfer *transfer in inTransfers) {
        if (transfer.percentDone.intValue != 100) {
            [newTransfers addObject:transfer];
        }else{    
            #warning this doesnt work
            NSDate *date = [NSDate dateWithISO8601String:transfer.createdAt];
            if ([threeDaysAgo earlierDate:date]) {
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
            self.spaceProgressView.progress = quotaPercentage;
            self.spaceLabel.text = [NSString stringWithFormat:@"%0.0f%%", (quotaPercentage*100)];
        }
    }];
}

#pragma mark tableview gubbins

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TransferCell"];
        if (cell) {
            Transfer *item = [transfers objectAtIndex:indexPath.row];
            ARTransferCell *theCell = (ARTransferCell*)cell;
            theCell.nameLabel.text = item.name;
            theCell.detailsLabel.text = [NSString stringWithFormat:@"%.1f %", [item.percentDone floatValue]];
            theCell.progressView.progress = [item.percentDone floatValue]/100;
        }
    }
    if (indexPath.section == 1) {
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
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case DisplayTransfers:
            return 76.0;
        case DisplayMessages:
            return 28.0;            
    }
    return 0;
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

@end
