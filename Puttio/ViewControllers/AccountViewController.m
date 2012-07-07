//
//  AccountViewController.m
//  Puttio
//
//  Created by orta therox on 24/06/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "AccountViewController.h"
#import "UIDevice+SpaceStats.h"
#import "ORSimpleProgress.h"
#import "Constants.h"

@interface AccountViewController ()

@end

@implementation AccountViewController
@synthesize accountSpaceLeftProgress;
@synthesize deviceStoredProgress;
@synthesize deviceSpaceLeftProgress;
@synthesize welcomeAccountLabel;
@synthesize loggedOutMessageView;
@synthesize accountSpaceLabel;
@synthesize deviceStoredLabel;
@synthesize deviceSpaceLeftLabel;

- (void)viewWillAppear:(BOOL)animated {
    // Welcome message
    self.welcomeAccountLabel.text = [NSString stringWithFormat:@"Welcome %@", [[NSUserDefaults standardUserDefaults] objectForKey:ORUserAccountNameDefault]];
    
    // Space Left on Device
    self.deviceSpaceLeftLabel.text = [NSString stringWithFormat:@"You have %@ left on this device", [self getSpaceLeft]];
    self.deviceSpaceLeftProgress.progress = [UIDevice numberOfBytesFree] / [UIDevice numberOfBytesOnDevice];
    self.deviceSpaceLeftProgress.isLandscape = YES;
    
    // Space Used on Device
    self.deviceStoredLabel.text = [NSString stringWithFormat:@"Put.io is using %@ on this device", [self getDeviceSpaceUsed]];
    
    CGFloat progress = [UIDevice numberOfBytesUsedInDocumentsDirectory] / [UIDevice numberOfBytesOnDevice];
    self.deviceStoredProgress.progress = progress;
    self.deviceStoredProgress.isLandscape = YES;
    
    // Space Left on Put.io
     NSString *deviceUsedString = [[NSUserDefaults standardUserDefaults] objectForKey:ORDiskQuotaAvailableDefault];
    self.accountSpaceLabel.text = [NSString stringWithFormat:@"You have %@ left on the site", [UIDevice humanStringFromBytes:[deviceUsedString doubleValue]]];
    self.accountSpaceLeftProgress.progress = [[NSUserDefaults standardUserDefaults] doubleForKey:ORCurrentSpaceUsedPercentageDefault];
    self.accountSpaceLeftProgress.isLandscape = YES;
     
    [super viewWillAppear:animated];
}

- (NSString *)getDeviceSpaceUsed {
    double bytes = [UIDevice numberOfBytesUsedInDocumentsDirectory];
    if (bytes != 0) {
        [UIDevice humanStringFromBytes:bytes];
    }
    return @"no space";
}

- (NSString *)getSpaceLeft {
    return [UIDevice humanStringFromBytes:[UIDevice numberOfBytesFree]];
}

- (IBAction)logOutTapped:(UIButton *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:AppAuthTokenDefault];
    [defaults removeObjectForKey:APIKeyDefault];
    [defaults removeObjectForKey:APISecretDefault];
    [defaults setBool:YES forKey:ORLoggedOutDefault];
    [defaults synchronize];
    
    self.loggedOutMessageView.hidden = NO;
    sender.enabled = NO;
    sender.alpha = 0.5;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)viewDidUnload {
    [self setAccountSpaceLeftProgress:nil];
    [self setDeviceStoredProgress:nil];
    [self setDeviceSpaceLeftProgress:nil];
    [self setAccountSpaceLabel:nil];
    [self setDeviceStoredLabel:nil];
    [self setDeviceSpaceLeftLabel:nil];
    [self setWelcomeAccountLabel:nil];
    [self setLoggedOutMessageView:nil];
    [super viewDidUnload];
}

@end
