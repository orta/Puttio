//
//  ORInlineEditableTableViewController
//  Puttio
//
//  Created by orta therox on 27/12/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ORInlineEditableTableViewController.h"
#import "Bookmark.h"

static CGSize ButtonSize = { .height = 37 };
static CGSize ButtonInset = { .height = 10, .width = 10 };

@interface ORInlineEditableTableViewController (){
    UITextField *_editingTextField;
    UIButton *_newButton;
}

@end

@implementation ORInlineEditableTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        _amountOfCellsToShowBeforeScrollingOnAdd = 6;
        self.tableView.bounces = NO;
    }
    return self;
}

#pragma mark - Table view data source

// It is expected that you override this function and add the offset in your version
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self currentOffset];
}

- (CGFloat)currentOffset {
    return (_showingTextField) ? 2 : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger itemsCount = [self tableView:tableView numberOfRowsInSection:indexPath.section] - [self currentOffset];
    
    BOOL rowHasTextfield = indexPath.row == itemsCount && _showingTextField;
    BOOL rowHasButton = (indexPath.row == itemsCount && !_showingTextField) || indexPath.row > itemsCount;

    NSString *cellIdentifier = @"ORTextCell";
    if (rowHasButton) cellIdentifier = @"ORButtonCell";
    if (rowHasTextfield) cellIdentifier = @"ORTextFieldCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.row < itemsCount) {
        cell = [self setupNormalCell:cell ForIndexPath:indexPath];
    }

    if (rowHasTextfield)  {
        [_editingTextField removeFromSuperview];
        _editingTextField = [self textFieldForEditingWithFrame:cell.frame];
        cell.accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.contentView addSubview:_editingTextField];
        [_editingTextField becomeFirstResponder];
        
        if (itemsCount >= _amountOfCellsToShowBeforeScrollingOnAdd) {
            NSIndexPath *lastCellPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:indexPath.section];
            [tableView scrollToRowAtIndexPath:lastCellPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }

    if (rowHasButton) {
        [_newButton removeFromSuperview];
        cell.accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];

        _newButton = [self buttonForNewItemWithFrame:cell.frame];
        [cell.contentView addSubview:_newButton];

        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (UITableViewCell *)setupNormalCell:(UITableViewCell *)cell ForIndexPath:(NSIndexPath *)indexPath {
    return cell;
}

- (UIButton *)buttonForNewItemWithFrame:(CGRect)frame {
    UIButton *newButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if (_showingTextField){
        [newButton setTitle:@"SAVE" forState:UIControlStateNormal];
    }else{
        [newButton setTitle:@"NEW" forState:UIControlStateNormal];
    }
    [newButton addTarget:self action:@selector(createNewItem) forControlEvents:UIControlEventTouchUpInside];
    newButton.backgroundColor = [UIColor grayColor];
    newButton.frame = CGRectMake(ButtonInset.height, ButtonInset.width, frame.size.width - (ButtonInset.width * 2), frame.size.height - (ButtonInset.height * 2));
    [newButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    return newButton;
}

- (UITextField *)textFieldForEditingWithFrame:(CGRect)frame {
    CGRect textFieldFrame = CGRectMake(ButtonInset.width, 4, frame.size.width - (ButtonInset.width * 2), ButtonSize.height);
    UITextField *editingTextField = [[UITextField alloc] initWithFrame:textFieldFrame];
    editingTextField.text = @"";
    editingTextField.delegate = self;
    editingTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    editingTextField.textAlignment = UITextAlignmentLeft;
    return editingTextField;
}

- (void)createNewItem {
    // Is it a "Done" button?
    if (_showingTextField)  {
        [self textFieldShouldReturn:_editingTextField];
    } else {
        _showingTextField = YES;
        NSInteger itemsCount = [self tableView:self.tableView numberOfRowsInSection:0] - [self currentOffset];
        NSIndexPath *path = [NSIndexPath indexPathForRow:itemsCount inSection:0];


        [self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        [_newButton setTitle:@"DONE" forState:UIControlStateNormal];
        _newButton.enabled = NO;
        _newButton.alpha = .3;
        
        if (itemsCount < _amountOfCellsToShowBeforeScrollingOnAdd) {
            UIView *popover = _container.view;
            if (popover) {
                CGRect newFrame = popover.frame;
                newFrame.size.height += [self tableView:self.tableView heightForRowAtIndexPath:path];
                [UIView animateWithDuration: 0.15 animations:^{
                    popover.frame = newFrame;
                }];
            }
        }
    }
}

- (void)saveNewItemWithString:(NSString *)string {

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField.text isEqualToString:@""]) return NO;
    [self saveNewItemWithString:textField.text];
    [self updateTableViewThenDismiss];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    int length = textField.text.length + string.length - range.length;

    if (length == 0) {
        _newButton.enabled = NO;
        _newButton.alpha = 0.3;
    } else {
        _newButton.enabled = YES;
        _newButton.alpha = 1;
    }
    return YES;
}

- (void)updateTableViewThenDismiss {
    [self.tableView reloadData];
    [self.container performSelector:@selector(dismissPopoverAnimated:) withObject:@(YES) afterDelay:0.3];
}

#pragma mark - Table view delegate


- (CGSize)contentSizeForViewInPopover {
    NSInteger itemsCount = [self tableView:self.tableView numberOfRowsInSection:0];
    return CGSizeMake(320, itemsCount * [self tableView:self.tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]);
}


@end
