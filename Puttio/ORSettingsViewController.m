//
//  ORSettingsViewController.m
//  Puttio
//
//  Created by orta therox on 15/12/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ORSettingsViewController.h"

@interface ORSettingsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *subtitlesLanguages;
@property (weak, nonatomic) IBOutlet UIView *logoutInfoView;

@end

@implementation ORSettingsViewController

- (void)viewDidLoad {
    [self setupGestures];
}

- (void)setupGestures {
    UISwipeGestureRecognizer *backSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(backSwipeRecognised:)];
    backSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:backSwipe];
}

- (void)backSwipeRecognised:(UISwipeGestureRecognizer *)gesture {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)changeSubtitlesTapped:(id)sender {
    
}

- (IBAction)logoutTapped:(id)sender {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:AppAuthTokenDefault];
        [defaults removeObjectForKey:APIKeyDefault];
        [defaults removeObjectForKey:APISecretDefault];
        [defaults setBool:YES forKey:ORLoggedOutDefault];
        [defaults synchronize];

        [ARAnalytics incrementUserProperty:@"User Logged Out" byInt:1];
        [ARAnalytics event:@"User Logged Out"];

        _logoutInfoView.hidden = NO;
}

- (void)viewDidUnload {
    [self setSubtitlesLanguages:nil];
    [self setLogoutInfoView:nil];
    [super viewDidUnload];
}

- (IBAction)toggleSubtitles:(id)sender {
}

@end
