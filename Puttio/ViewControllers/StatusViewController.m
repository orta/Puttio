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

@interface StatusViewController () {
    NSArray *transfers;
    NSArray *messages;
}
@end

@implementation StatusViewController
@synthesize tableView;
@synthesize bandwidthProgressView;
@synthesize spaceProgressView;

- (void)setup {
    CGRect space = [self.view.superview bounds];
    space.origin.y = 0;
    space.size.width = SidebarWidth;
    self.view.frame = space;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupShadow];
    [self getUserInfo];
    [self getTransfers];
    [self getMessages];
}

- (void)getTransfers {
    [[PutIOClient sharedClient] getTransfers:^(id userInfoObject) {
        NSLog(@"transfers - %@", userInfoObject);
        if (![userInfoObject isMemberOfClass:[NSError class]]) {
            transfers = userInfoObject;
            [tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    }];
}

- (void)getMessages {
    // NO-OP
}

- (void)getUserInfo {
    [[PutIOClient sharedClient] getUserInfo:^(id userInfoObject) {
        [[NSUserDefaults standardUserDefaults] setObject:[userInfoObject valueForKeyPath:@"id"] forKey:ORUserIdDefault];
        NSString *diskQuotaString = [[userInfoObject valueForKeyPath:@"response.results.disk_quota"] objectAtIndex:0];
        NSString *diskQuotaAvailableString = [[userInfoObject valueForKeyPath:@"response.results.disk_quota_available"] objectAtIndex:0];
        
        NSString *bandwidthQuotaString = [[userInfoObject valueForKeyPath:@"response.results.bw_quota"] objectAtIndex:0];
        NSString *bandwidthQuotaAvailableString = [[userInfoObject valueForKeyPath:@"response.results.bw_quota_available"] objectAtIndex:0];
        
        self.spaceProgressView.value = [diskQuotaAvailableString longLongValue] / [diskQuotaString longLongValue] ;
        self.bandwidthProgressView.value = [bandwidthQuotaAvailableString longLongValue] / [bandwidthQuotaString longLongValue];
    }];
}

#pragma mark tableview gubbins

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"TransferCell"];
        if (cell) {
            Transfer *item = [transfers objectAtIndex:indexPath.row];
            ARTransferCell *theCell = (ARTransferCell*)cell;
            theCell.nameLabel.text = item.name;
            theCell.detailsLabel.text = [item.downloadSpeed stringValue];
            theCell.progressView.progress = [item.percentDone floatValue]/100;
        }
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return transfers.count;
}

- (void)viewDidUnload {
    [self setBandwidthProgressView:nil];
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
