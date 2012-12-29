//
//  ORSettingsViewController.m
//  Puttio
//
//  Created by orta therox on 15/12/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ORSettingsViewController.h"

@interface Country : NSObject
@property (strong) NSString *isoCode;
@property (strong) NSString *fullName;
@property (strong) NSNumber *index;
@property (assign) BOOL active;
@end

@implementation Country
- (NSString *)description { return _fullName; };
@end

@interface ORSettingsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *subtitlesLanguages;
@property (weak, nonatomic) IBOutlet UIView *logoutInfoView;

@end

@implementation ORSettingsViewController {
    NSMutableArray *_allCountries;
    NSArray *_allFlagButtons;
}

- (void)viewDidLoad {
    [self setupGestures];

//    English
//    Brazilian
//    Turkey
//    Czech
//
//    Finnland
//    France
//    Greek
//    Hungry
//
//    Indonesia
//    Poland
//    Portugal
//    Romainia
//    
//    Russia
//    Spanish
//    Ukerainian
//    Bulgaria

    // http://www.opensubtitles.org/addons/export_languages.php
    
    NSArray *countries =
        @[ @"English", @"eng",
           @"Potuguese Brasileiro", @"pob",
           @"Türk", @"tur",
           @"Češka", @"cs",

           @"Suomi", @"fin",
           @"Français", @"fre",
           @"ελληνικά", @"ell",
           @"Magyar", @"hun",

           @"Indonesia", @"ind",
           @"Polski", @"pol",
           @"Portugues", @"por",
           @"Român", @"rum",
           
           @"русский", @"rus",
           @"Español", @"spa",
           @"Український", @"ukr",
           @"български", @"bul"
        ];

    _allCountries = [NSMutableArray array];
    for (int i = 0; i < (countries.count - 1); i += 2) {
        
        Country *country = [[Country alloc] init];
        country.fullName = countries[i];
        country.isoCode = countries[i+1];
        if (i) {
            country.index = @(i/2);
        } else {
            country.index = @0;
        }

        [_allCountries addObject:country];
    }

    _allFlagButtons = [_flagButtons sortedArrayUsingComparator:^NSComparisonResult(id objA, id objB) { return(
               ([objA tag] < [objB tag]) ? NSOrderedAscending  :
               ([objA tag] > [objB tag]) ? NSOrderedDescending :
               NSOrderedSame);
    }];

    NSString *currentDefault = [[NSUserDefaults standardUserDefaults] objectForKey:ORSubtitleLanguageDefault];
    if (!currentDefault) {
        currentDefault = @",eng";
        [[NSUserDefaults standardUserDefaults] setObject:currentDefault forKey:ORSubtitleLanguageDefault];
    }

    [self updateButtons];
    _subtitlesLanguages.text = @"";
}

- (void)updateButtons {
    NSString *currentDefault = [[NSUserDefaults standardUserDefaults] objectForKey:ORSubtitleLanguageDefault];

    NSArray *codes = [currentDefault componentsSeparatedByString:@","];
    if (!codes.count) {
        if (currentDefault.length) {
            codes = @[currentDefault];
        }
    }

    for (NSString *isoCode in codes) {
        for (Country *country in _allCountries) {
            UIButton *button = _allFlagButtons[country.index.intValue];
            if ([country.isoCode isEqualToString:isoCode]) {
                country.active = YES;
            }
            button.alpha = country.active? 1: 0.3;
        }
    }
}

- (IBAction)toggleSubtitles:(UIButton *)sender {
    NSString *currentDefault = [[NSUserDefaults standardUserDefaults] objectForKey:ORSubtitleLanguageDefault];
    Country *country = _allCountries[sender.tag];
    
    if ([currentDefault rangeOfString:country.isoCode].location == NSNotFound) {
        // adding it
        currentDefault = [currentDefault stringByAppendingFormat:@",%@",country.isoCode];
        _subtitlesLabel.text = [NSString stringWithFormat:@"%@ Added", country.fullName];
    } else {
        NSString *format = [NSString stringWithFormat:@",%@", country.isoCode];
        currentDefault = [currentDefault stringByReplacingOccurrencesOfString:format withString:@""];
        _subtitlesLabel.text = [NSString stringWithFormat:@"%@ Removed", country.fullName];
        country.active = NO;
    }

    [[NSUserDefaults standardUserDefaults] setObject:currentDefault forKey:ORSubtitleLanguageDefault];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self updateButtons];
    
}

- (void)setupGestures {
    UISwipeGestureRecognizer *backSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(backSwipeRecognised:)];
    backSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:backSwipe];
}

- (void)backSwipeRecognised:(UISwipeGestureRecognizer *)gesture {
    [self.navigationController popToRootViewControllerAnimated:YES];
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
    [self setFlagButtons:nil];
    [self setSubtitlesLabel:nil];
    [super viewDidUnload];
}



@end
