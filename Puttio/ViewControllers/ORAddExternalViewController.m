//
//  ORAddExternalViewController.m
//  Puttio
//
//  Created by orta therox on 08/11/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//


// UNUSED

#import "ORAddExternalViewController.h"
#import "ORAddTorrentCell.h"
#import "ModalZoomView.h"
#import "ORPasteboardParser.h"

@interface ORAddExternalViewController () {
    NSArray *_sortedTorrentAddresses;
    NSMutableArray *_selectionStates;
    BOOL _startedUploads;
    BOOL _showUpdates;
}
@property (strong, nonatomic) NSSet *torrentAddresses;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ORAddExternalViewController

- (void)viewDidLoad {
    NSSet *urls = [ORPasteboardParser submitableURLsInPasteboard];
    [self setTorrentAddresses:urls];
}

- (void)setTorrentAddresses:(NSSet *)torrentAddresses {
    _torrentAddresses = torrentAddresses;
    
    // We need a sorted version of the addresses that doesn't get confused by prefixes
    _sortedTorrentAddresses = [torrentAddresses.allObjects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSMutableString *mutableOne = [obj1 mutableCopy];
        NSMutableString *mutableTwo = [obj2 mutableCopy];

        [mutableOne replaceOccurrencesOfString:@"https://" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [mutableOne length])];
        [mutableOne replaceOccurrencesOfString:@"http://" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [mutableOne length])];
        [mutableOne replaceOccurrencesOfString:@"www." withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [mutableOne length])];

        [mutableTwo replaceOccurrencesOfString:@"https://" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [mutableTwo length])];
        [mutableTwo replaceOccurrencesOfString:@"http://" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [mutableTwo length])];
        [mutableTwo replaceOccurrencesOfString:@"www." withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [mutableTwo length])];

        return [mutableOne compare:mutableTwo];
    }];

    _selectionStates = [NSMutableArray array];
    for (int i = 0; i < torrentAddresses.count; i++) {
        [_selectionStates addObject: @YES];
    }
}

- (IBAction)submit:(UIButton *)sender {
//    if (_startedUploads) {
//        _showUpdates = NO;
//        [ModalZoomView fadeOutViewAnimated:YES];
//    } else {
//        [sender setTitle:@"Continue" forState:UIControlStateNormal];
//        _showUpdates = YES;
//        
//        for (NSString *address in _sortedTorrentAddresses) {
//            NSInteger index = [_sortedTorrentAddresses indexOfObject:address];
//            ORAddTorrentCell *cell = (ORAddTorrentCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
//
//            if ([_selectionStates[index] boolValue]) {
//
//                [[PutIOClient sharedClient] requestTorrentOrMagnetURLAtPath:address :^(id userInfoObject) {
//                    if (!_showUpdates) return;
//                    cell.textLabel.text = @"Started Downloading";
//                    [self removeItemFromPasteboard:address];
//
//                } failure:^(NSError *error) {
//                    cell.textLabel.text = @"Recieved Error";
//                    [self removeItemFromPasteboard:address];
//                }];
//            }
//        }
//    }
}

- (void)removeItemFromPasteboard:(NSString *)item {
#warning TODO:
    //    NSMutableArray *newPasteboardItems = [[UIPasteboard generalPasteboard].items mutableCopy];
//    for (id key in newPasteboardItems.allKeys) {
//        if ([newPasteboardItems[key] isEqual:item]) {
//            [newPasteboardItems removeObjectForKey:key];
//        }
//    }
//    [UIPasteboard generalPasteboard].item = newPasteboardItems;
}

- (IBAction)cancel:(id)sender {
    [ModalZoomView fadeOutViewAnimated:YES];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return _sortedTorrentAddresses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ORAddTorrentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TorrentCell"];
    if (cell) {
        [cell.selectionTick setSelected:YES animated:NO];

        NSMutableString *displayString = [_sortedTorrentAddresses[indexPath.row] mutableCopy];
        [displayString replaceOccurrencesOfString:@"https://" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [displayString length])];
        [displayString replaceOccurrencesOfString:@"http://" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [displayString length])];
        [displayString replaceOccurrencesOfString:@"www." withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [displayString length])];

        cell.title.text = displayString;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL selected = [_selectionStates[indexPath.row] boolValue];
    ORAddTorrentCell *cell = (ORAddTorrentCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell.selectionTick setSelected:!selected animated:YES];
    _selectionStates[indexPath.row] = @(!selected);
    cell.selected = NO;
}

- (CGSize)sizeForZoomView:(ModalZoomView *)zoomView {
    return CGSizeMake(480, (CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.tableView.bounds)) + (_torrentAddresses.count * 44) - 1);
}

@end
