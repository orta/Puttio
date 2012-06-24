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
@synthesize accountSpaceLabel;
@synthesize deviceStoredLabel;
@synthesize deviceSpaceLeftLabel;

- (void)viewWillAppear:(BOOL)animated {
    // Space Left on Device
    self.deviceSpaceLeftLabel.text = [NSString stringWithFormat:@"You have %@ left on this device", [self getSpaceLeft]];
    self.deviceSpaceLeftProgress.progress = [UIDevice numberOfBytesFree] / [UIDevice numberOfBytesOnDevice];
    self.deviceSpaceLeftProgress.isLandscape = YES;
    
    // Space Used on Device
    self.deviceStoredLabel.text = [NSString stringWithFormat:@"Put.io is using %@ on this device", [self getDeviceSpaceUsed]];
    self.deviceSpaceLeftProgress.progress = 0;
    self.deviceSpaceLeftProgress.isLandscape = YES;
    
    // Space Left on Put.io
//    [[NSUserDefaults standardUserDefaults] setFloat:quotaPercentage forKey:ORCurrentSpaceUsedPercentageDefault];
//    [[NSUserDefaults standardUserDefaults] setObject:diskQuotaAvailableString forKey:ORDiskQuotaAvailableDefault
     NSString *deviceUsedString = [[NSUserDefaults standardUserDefaults] objectForKey:ORDiskQuotaAvailableDefault];
    self.accountSpaceLabel.text = [NSString stringWithFormat:@"You are using %@ on the site", deviceUsedString];
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

- (IBAction)logOutTapped:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:AppAuthTokenDefault];
    [defaults removeObjectForKey:APIKeyDefault];
    [defaults removeObjectForKey:APISecretDefault];
    
    #warning not good enough
    self.welcomeAccountLabel.text = @"Logged out please restart App";
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
    [super viewDidUnload];
}

@end
