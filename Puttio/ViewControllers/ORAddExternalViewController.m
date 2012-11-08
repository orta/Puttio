//
//  ORAddExternalViewController.m
//  Puttio
//
//  Created by orta therox on 08/11/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "ORAddExternalViewController.h"
#import "ORAddTorrentCell.h"
#import "ModalZoomView.h"

@interface ORAddExternalViewController () {
    NSArray *_sortedTorrentAddresses;
    NSMutableArray *_selectionStates;
    BOOL _startedUploads;
    BOOL _showUpdates;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ORAddExternalViewController

- (void)setTorrentAddressses:(NSSet *)torrentAddressses {

    // We need a sorted version of the addresses that doesn't get confused by prefixes
    _sortedTorrentAddresses = [torrentAddressses.allObjects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
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
    for (int i = 0; i < torrentAddressses.count; i++) {
        [_selectionStates addObject: @YES];
    }
}

- (IBAction)submit:(UIButton *)sender {
    if (_startedUploads) {
        _showUpdates = NO;
        [ModalZoomView fadeOutViewAnimated:YES];

    } else {
        [sender setTitle:@"Continue" forState:UIControlStateNormal];
        _showUpdates = YES;
        
        for (NSString *address in _sortedTorrentAddresses) {
            NSInteger index = [_sortedTorrentAddresses indexOfObject:address];
            ORAddTorrentCell *cell = (ORAddTorrentCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];

            if ([_selectionStates[index] boolValue]) {
                [[PutIOClient sharedClient] downloadTorrentOrMagnetURLAtPath:address :^(id userInfoObject) {
                    if (!_showUpdates) return;
                    
                    if ([userInfoObject isKindOfClass:[NSError class]]) {
                        cell.textLabel.text = @"Started Downloading";
                    } else {
                        cell.textLabel.text = @"Recieved Error";
                    }
                }];
            }
        }
    }
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
    ORAddTorrentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell"];
    if (cell) {
        cell.selected = YES;
        [cell.selectionTick setSelected:YES animated:NO];

        NSMutableString *displayString = [_sortedTorrentAddresses[indexPath.row] mutableCopy];
        [displayString replaceOccurrencesOfString:@"https://" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [displayString length])];
        [displayString replaceOccurrencesOfString:@"http://" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [displayString length])];
        [displayString replaceOccurrencesOfString:@"www." withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [displayString length])];

        cell.title.text = displayString;
    }
    return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL selected = [_selectionStates[indexPath.row] boolValue];
    ORAddTorrentCell *cell = (ORAddTorrentCell *)[tableView cellForRowAtIndexPath:indexPath];

    [cell.selectionTick setSelected:!selected animated:YES];
    _selectionStates[indexPath.row] = @(!selected);
}

@end
