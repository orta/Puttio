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
#import "ModalZoomView.h"
#import "ORAddBookmarkViewController.h"

@implementation ORBookmarksViewController

// It is expected that you override this function and add the offset in your version
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger offset = 1;
    return [Bookmark count:nil] + offset;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"BookmarkCell";
    BOOL isLastCell = (indexPath.row == [Bookmark count:nil]);
    if (isLastCell) {
        identifier = @"AddButtonCell";
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        if (isLastCell) {
            [cell.contentView addSubview:[self buttonForNewItemWithFrame:cell.frame]];
        }
    }
    if (!isLastCell) {
        Bookmark *bookmark = [Bookmark findAllSortedBy:@"lastAccessed" ascending:NO][indexPath.row];
        cell.textLabel.text = bookmark.name;
        cell.detailTextLabel.text = bookmark.url;
    }
    return cell;
}

- (UIButton *)buttonForNewItemWithFrame:(CGRect)frame {
    frame.size.height = 66;
    frame.size.width = [UIDevice isPad] ? 320: 300;
    
    UIButton *newButton = [ORFlatButton buttonWithType:UIButtonTypeCustom];
    [newButton setTitle:@"Bookmark Page" forState:UIControlStateNormal];

    [newButton addTarget:self action:@selector(createNewItem) forControlEvents:UIControlEventTouchUpInside];
    newButton.frame = CGRectInset(frame, 10, 10);
    return newButton;
}

- (void)createNewItem {
   ORAddBookmarkViewController *controller = [ModalZoomView showWithViewControllerIdentifier:@"AddBookmarkView"];
    controller.name = _delegate.name;
    controller.address = _delegate.url;
    controller.bookmarksController = self;
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

- (CGSize)contentSizeForViewInPopover {
    return CGSizeMake(320, ([Bookmark count:nil] + 1) * 66);
}

- (void)reloadAndHideBookmarks {
    [self.tableView reloadData];
    [self performSelector:@selector(dismissModal) withObject:nil afterDelay:1];
}

- (void)dismissModal {
    [_wePopoverController dismissPopoverAnimated:YES];
}

@end
