//
//  ORBookmarksViewController.h
//  Puttio
//
//  Created by orta therox on 27/12/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ORInlineEditableTableViewController.h"

@protocol ORBookmarkControllerDelegate <NSObject>

- (NSString *)url;
- (NSString *)name;
- (void)setURL:(NSString *)url;

@end

@interface ORBookmarksViewController : UITableViewController

@property (weak) NSObject <ORBookmarkControllerDelegate> *delegate;
@property (weak) WEPopoverController *wePopoverController;
- (void)reloadAndHideBookmarks;

@end
