//
//  ORBookmarksViewController.h
//  Puttio
//
//  Created by orta therox on 27/12/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WEPopoverController.h"

@interface ORInlineEditableTableViewController : UITableViewController <UITextFieldDelegate>

@property (assign) NSInteger amountOfCellsToShowBeforeScrollingOnAdd;

// It is expected that you override this function and add the offset in your version
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

- (UITableViewCell *)setupNormalCell:(UITableViewCell *)cell ForIndexPath:(NSIndexPath *)indexPath;
- (UIButton *)buttonForNewItemWithFrame:(CGRect)frame;
- (UITextField *)textFieldForEditingWithFrame:(CGRect)frame;

- (void)saveNewItemWithString:(NSString *)string;

@property (assign) WEPopoverController *container;
@property (assign) BOOL showingTextField;
@end
