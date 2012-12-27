//
//  ORBookmarksViewController.m
//  Puttio
//
//  Created by orta therox on 27/12/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ORBookmarksViewController.h"
#import "Bookmark.h"
#import "ORFlatButton.h"

@implementation ORBookmarksViewController

// It is expected that you override this function and add the offset in your version
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger offset = [super tableView:tableView numberOfRowsInSection:section];
    return [Bookmark count:nil] + offset;
}

- (UITableViewCell *)setupNormalCell:(UITableViewCell *)cell ForIndexPath:(NSIndexPath *)indexPath {
    Bookmark *bookmark = [Bookmark findAllSortedBy:@"lastAccessed" ascending:NO][indexPath.row];
    cell.textLabel.text = bookmark.name;
    cell.detailTextLabel.text = bookmark.url;
    return cell;
}

- (UITextField *)textFieldForEditingWithFrame:(CGRect)frame {
    frame.size.height = 66;
    frame.size.width = [UIDevice isPad] ? 320: 300;

    CGRect textFieldFrame = CGRectInset(frame, 10, 10);
    UITextField *editingTextField = [[UITextField alloc] initWithFrame:textFieldFrame];
    editingTextField.text = _delegate.name;
    editingTextField.delegate = self;
    editingTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    editingTextField.textAlignment = UITextAlignmentLeft;
    return editingTextField;
}

- (void)saveNewItemWithString:(NSString *)string {
    Bookmark *bookmark = [Bookmark object];
    bookmark.name = string;
    bookmark.url = _delegate.url;
    bookmark.lastAccessed = [NSDate date];
    if ([[bookmark managedObjectContext] persistentStoreCoordinator].persistentStores.count) {
        [[bookmark managedObjectContext] save:nil];
    } else {
        NSLog(@"could not save");
    }
}

- (UIButton *)buttonForNewItemWithFrame:(CGRect)frame {
    frame.size.height = 66;
    frame.size.width = [UIDevice isPad] ? 320: 300;
    
    UIButton *newButton = [ORFlatButton buttonWithType:UIButtonTypeCustom];
    if (self.showingTextField){
        [newButton setTitle:@"Save" forState:UIControlStateNormal];
    }else{
        [newButton setTitle:@"Bookmark Page" forState:UIControlStateNormal];
    }
    [newButton addTarget:self action:@selector(createNewItem) forControlEvents:UIControlEventTouchUpInside];
    newButton.frame = CGRectInset(frame, 10, 10);
    return newButton;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Bookmark *bookmark = [Bookmark findAllSortedBy:@"lastAccessed" ascending:NO][indexPath.row];

    bookmark.lastAccessed = [NSDate date];
    if ([[bookmark managedObjectContext] persistentStoreCoordinator].persistentStores.count) {
        [[bookmark managedObjectContext] save:nil];
    } else {
        NSLog(@"could not save");
    }

    [_delegate setURL:bookmark.url];
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Bookmark *bookmark = [Bookmark findAllSortedBy:@"lastAccessed" ascending:NO][indexPath.row];
        [bookmark deleteEntity];
        if ([[bookmark managedObjectContext] persistentStoreCoordinator].persistentStores.count) {
            [[bookmark managedObjectContext] save:nil];
        } else {
            NSLog(@"could not save");
        }

        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
