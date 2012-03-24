//
//  LoginViewController.m
//  Puttio
//
//  Created by orta therox on 22/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "LoginViewController.h"
#import "V1PutIOClient.h"

@implementation LoginViewController
@synthesize usernameTextField;
@synthesize apiKeyTextField;
@synthesize passwordTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [usernameTextField becomeFirstResponder];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

// http://api.put.io/v1/user?method=info&request={"api_key":"YOUR_API_KEY","api_secret":"YOUR_API_SECRET","params":{}} 

- (IBAction)login:(id)sender {
    V1PutIOClient *client = [V1PutIOClient sharedClient];
    client.apiKey = usernameTextField.text;
    client.apiSecret = apiKeyTextField.text;
    
    NSDictionary *params = [V1PutIOClient paramsForRequestAtMethod:@"info" withParams:[NSDictionary dictionary]];
    [client getPath:@"user" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([[responseObject valueForKeyPath:@"error"] boolValue] == NO) {
            // passed
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:client.apiKey forKey:APIKeyDefault];
            [defaults setObject:client.apiSecret forKey:APISecretDefault];
            [defaults synchronize];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:OAuthTokenWasSavedNotification object:nil userInfo:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed %@", error);
    }];

}

@end
