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
#import "ModalZoomView.h"

#import "Constants.h"

@interface AccountViewController ()

@end

@implementation AccountViewController

- (void)viewDidLoad {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self.creativeCommonsSwitch setOn:![defaults boolForKey:ORUseAllSearchEngines] animated:NO];

    [self setCopyrightText];
}

- (void)setCopyrightText {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults boolForKey:ORUseAllSearchEngines]){
        self.searchInfoLabel.text =  @"Warning: Search is unfiltered.";
    }else{
        self.searchInfoLabel.text = @"Only search for Creative Commons works.";
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
        [Analytics incrementUserProperty:@"User Switched CreativeCommons Setting" byInt:1];
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

    [Analytics incrementUserProperty:@"User Logged Out" byInt:1];
    [Analytics event:@"User Logged Out"];

    self.loggedOutMessageView.hidden = NO;
    sender.enabled = NO;
    sender.alpha = 0.5;
}

- (IBAction)addToTwitter:(id)sender {
    BOOL hasTweetBot = [[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"tweetbot://"]];
    if (hasTweetBot) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tweetbot://orta/user_profile/orta"]];
        return;
    }

    BOOL hasOfficialTwitter = [[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"twitter://user"]];
    if (hasOfficialTwitter) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=orta"]];
    }

    [self openURL:@"https://twitter.com/orta"];
}

- (IBAction)githubTapped:(id)sender {
    [self openURL:@"https://github.com/orta"];
}

- (IBAction)ortaTapped:(id)sender {

}

- (IBAction)feedbackTapped:(id)sender {
    [ModalZoomView showWithViewControllerIdentifier:@"feedbackView"];
}

- (void)openURL:(NSString *)target {
    BOOL hasChrome = [[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"googlechrome://"]];
    NSURL *inputURL = [NSURL URLWithString:target];

    if (hasChrome) {
        NSString *scheme = inputURL.scheme;

        // Replace the URL Scheme with the Chrome equivalent.
        NSString *chromeScheme = nil;
        if ([scheme isEqualToString:@"http"]) {
            chromeScheme = @"googlechrome";
        } else if ([scheme isEqualToString:@"https"]) {
            chromeScheme = @"googlechromes";
        }

        // Proceed only if a valid Google Chrome URI Scheme is available.
        if (chromeScheme) {
            NSString *absoluteString = [inputURL absoluteString];
            NSRange rangeForScheme = [absoluteString rangeOfString:@":"];
            NSString *urlNoScheme =
            [absoluteString substringFromIndex:rangeForScheme.location];
            NSString *chromeURLString =
            [chromeScheme stringByAppendingString:urlNoScheme];
            NSURL *chromeURL = [NSURL URLWithString:chromeURLString];

            // Open the URL with Chrome.
            [[UIApplication sharedApplication] openURL:chromeURL];
        }
    }else{
        [[UIApplication sharedApplication] openURL:inputURL];
    }
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
