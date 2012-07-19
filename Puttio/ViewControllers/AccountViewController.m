//
//  AccountViewController.m
//  Puttio
//
//  Created by orta therox on 24/06/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <Twitter/Twitter.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

#import "AccountViewController.h"
#import "UIDevice+SpaceStats.h"
#import "ORSimpleProgress.h"
#import "DCRoundSwitch.h"
#import "BBCyclingLabel.h"

#import "Constants.h"

@interface AccountViewController ()

@end

@implementation AccountViewController
@synthesize searchInfoLabel;

- (void)viewDidLoad {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self.creativeCommonsSwitch setOn:![defaults boolForKey:ORUseAllSearchEngines] animated:NO];

    [self setCopyrightText];

    self.searchInfoLabel.transitionEffect = BBCyclingLabelTransitionEffectZoomIn;
    self.searchInfoLabel.transitionDuration = 0.3;
    self.searchInfoLabel.backgroundColor = [UIColor whiteColor];
    self.searchInfoLabel.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:16];
    self.searchInfoLabel.numberOfLines = 2;
}

- (void)setCopyrightText {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults boolForKey:ORUseAllSearchEngines]){
        [self.searchInfoLabel setText: @"Warning: Search is unfiltered." animated:YES];
    }else{
        [self.searchInfoLabel setText: @"Only search for Creative Commons works." animated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Welcome message
    self.welcomeAccountLabel.text = [NSString stringWithFormat:@"Hey there, %@", [defaults objectForKey:ORUserAccountNameDefault]];    
    
    // Space Left on Put.io
    NSString *deviceUsedString = [defaults objectForKey:ORDiskQuotaAvailableDefault];
    self.accountSpaceLabel.text = [NSString stringWithFormat:@"%@ left on Put.IO", [UIDevice humanStringFromBytes:[deviceUsedString doubleValue]]];
    self.accountSpaceLeftProgress.progress = [defaults doubleForKey:ORCurrentSpaceUsedPercentageDefault];
    self.accountSpaceLeftProgress.isLandscape = YES;

    [self.creativeCommonsSwitch addTarget:self action:@selector(ccSwitched:) forControlEvents:UIControlEventValueChanged];

    [super viewWillAppear:animated];
}

- (void)ccSwitched:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    bool oldCCValue = [defaults boolForKey:ORUseAllSearchEngines];

    DCRoundSwitch *commonsSwitch = sender;
    // its opposite what's expected, means the switch flows better visually
    [defaults setBool:!commonsSwitch.on forKey:ORUseAllSearchEngines];
    [defaults synchronize];
    
    if ( oldCCValue != !commonsSwitch.on ) {
        [Analytics incrementCounter:@"User Switched CreativeCommons Setting" byInt:1];
        [Analytics event:@"Switched CC Setting"];
    }

    [self setCopyrightText];
}

- (IBAction)logOutTapped:(UIButton *)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:AppAuthTokenDefault];
    [defaults removeObjectForKey:APIKeyDefault];
    [defaults removeObjectForKey:APISecretDefault];
    [defaults setBool:YES forKey:ORLoggedOutDefault];
    [defaults synchronize];

    [Analytics incrementCounter:@"User Logged Out" byInt:1];
    [Analytics event:@"User Logged Out"];

    self.loggedOutMessageView.hidden = NO;
    sender.enabled = NO;
    sender.alpha = 0.5;
}

- (IBAction)addToTwitter:(id)sender {
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
        if(granted) {
            // Get the list of Twitter accounts.
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
            
            // For the sake of brevity, we'll assume there is only one Twitter account present.
            // You would ideally ask the user which account they want to tweet from, if there is more than one Twitter account present.
            if ([accountsArray count] > 0) {
                // Grab the initial Twitter account to tweet from.
                ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                
                NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
                [tempDict setValue:@"orta" forKey:@"screen_name"];
                [tempDict setValue:@"true" forKey:@"follow"];
                
                TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:@"https://api.twitter.com/1/friendships/create.json"]
                                                             parameters:tempDict
                                                          requestMethod:TWRequestMethodPOST];
                
                
                [postRequest setAccount:twitterAccount];
                
                [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    NSString *output = [NSString stringWithFormat:@"HTTP response status: %i", [urlResponse statusCode]];
                    NSLog(@"%@", output);
                    
                }];
            }
        }
    }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)viewDidUnload {
    [self setAccountSpaceLeftProgress:nil];
    [self setAccountSpaceLabel:nil];
    [self setWelcomeAccountLabel:nil];
    [self setLoggedOutMessageView:nil];
    [self setCreativeCommonsSwitch:nil];
    [self setSearchInfoLabel:nil];
    [super viewDidUnload];
}

@end
