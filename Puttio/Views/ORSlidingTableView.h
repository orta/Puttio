//
//  ORSlidingTableView.h
//  Puttio
//
//  Created by orta therox on 03/06/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ORSlidingTableView;
@protocol ORSlidingTableViewDelegate <NSObject>
- (void)slidingTableDidBeginTouch:(ORSlidingTableView *)table;
- (void)slidingTable:(ORSlidingTableView *)table didMoveToCellAtIndex:(NSInteger)index;
- (void)slidingTableDidEndTouch:(ORSlidingTableView *)table;
@end

@interface ORSlidingTableView : UITableView

@property (weak) IBOutlet NSObject <ORSlidingTableViewDelegate> *slidingDelegate;

@end
