//
//  ORSearchCell.h
//  Puttio
//
//  Created by orta therox on 11/04/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ORSearchCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *seedersLabel;

- (void)userHasFailedToAddFile;
- (void)userHasAddedFile;
@end
