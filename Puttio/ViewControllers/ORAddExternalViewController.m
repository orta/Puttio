//
//  ORAddExternalViewController.m
//  Puttio
//
//  Created by orta therox on 08/11/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ORAddExternalViewController.h"

@interface ORAddExternalViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ORAddExternalViewController

- (IBAction)submit:(id)sender {
    
}

- (IBAction)cancel:(id)sender {

}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}
@end
