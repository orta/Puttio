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

@interface StatusViewController ()

@end

@implementation StatusViewController
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
    
    [[PutIOClient sharedClient] getUserInfo:^(id userInfoObject) {
        NSString *diskQuotaString = [[userInfoObject valueForKeyPath:@"response.results.disk_quota"] objectAtIndex:0];
        NSString *diskQuotaAvailableString = [[userInfoObject valueForKeyPath:@"response.results.disk_quota_available"] objectAtIndex:0];

        NSString *bandwidthQuotaString = [[userInfoObject valueForKeyPath:@"response.results.bw_quota"] objectAtIndex:0];
        NSString *bandwidthQuotaAvailableString = [[userInfoObject valueForKeyPath:@"response.results.bw_quota_available"] objectAtIndex:0];

        self.spaceProgressView.value = [diskQuotaAvailableString longLongValue] / [diskQuotaString longLongValue] ;
        self.bandwidthProgressView.value = [bandwidthQuotaAvailableString longLongValue] / [bandwidthQuotaString longLongValue];
    }];
}

- (void)viewDidUnload {
    [self setBandwidthProgressView:nil];
    [self setSpaceProgressView:nil];
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
