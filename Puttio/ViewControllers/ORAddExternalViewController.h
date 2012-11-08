//
//  ORAddExternalViewController.h
//  Puttio
//
//  Created by orta therox on 08/11/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ORAddExternalViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSSet *torrentAddressses;

@end
