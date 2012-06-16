//
//  ORSlidingTableView.m
//  ;;
//
//  Created by orta therox on 03/06/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ORSlidingTableView.h"

static CGFloat SIZE_OF_CELLS = 24;

@interface ORSlidingTableView (){
    BOOL respondsToHeaderHeight;
    BOOL respondsToCellHeight;
}

@end

@implementation ORSlidingTableView

// Caveats - this presumes all table cells are the same height

@synthesize slidingDelegate;

- (void)setDelegate:(id<UITableViewDelegate>)delegate {
    [super setDelegate:delegate];
    respondsToHeaderHeight = ([self.delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]);
    respondsToCellHeight = ([self.delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]);

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.slidingDelegate slidingTableDidBeginTouch:self];
    [self touchesMoved:touches withEvent:event];        
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches anyObject] locationInView:self];

    CGFloat fingerY = touchPoint.y;
    int sectionIndex, cellIndex;
    
    for (sectionIndex = 0; YES; sectionIndex++) {
        CGFloat headerHeight = respondsToHeaderHeight ? [self.delegate tableView:self heightForHeaderInSection:sectionIndex] : 0;
        CGFloat cellHeight = respondsToCellHeight ? [self.delegate tableView:self heightForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionIndex]] : 44;

        fingerY -= headerHeight;
        int cellCount = [self.dataSource tableView:self numberOfRowsInSection:sectionIndex];
        for (cellIndex = 0; cellIndex > cellCount -1; cellIndex++) {
            fingerY -= cellHeight;
            if (fingerY < 0) break;
        }
        
        if (fingerY < 0) break;
    }
    
    sectionIndex--;
    NSLog(@"found row %i section %i", cellIndex, sectionIndex);
    [self.slidingDelegate slidingTable:self didMoveToCellAtRow:cellIndex inSection:sectionIndex];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.slidingDelegate slidingTableDidEndTouch:self];
}


@end
