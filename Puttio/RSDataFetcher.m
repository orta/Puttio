// RSDataFetcher.m
//
// Copyright (c) 2012 Michael Dinerstein
// Written for Boundabout (http://www.boundaboutwith.us)
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "RSDataFetcher.h"

@implementation RSDataFetcher
@synthesize delegate;
@synthesize sectionOffset;

- (id)initWithFetchRequest:(NSFetchRequest*)fetchRequest inContext:(NSManagedObjectContext*)context withKeyPath:(NSString*)keyPath usingCache:(NSString*)cache inTableView:(UITableView*)tableView{
  self = [super init];
  if (self){
    sectionOffset = 0;
    _updateTableView = tableView;
    _fetchedResults = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:context sectionNameKeyPath:keyPath cacheName:cache];
  }
  return self;
}

- (void)refreshRequestWithPredicate:(NSPredicate*)predicate andSortDescriptors:(NSArray*)sortDescriptors{
  //Featured Tour Request  
  if ([_fetchedResults cacheName]){
    [NSFetchedResultsController deleteCacheWithName:[_fetchedResults cacheName]];
  }
  [[_fetchedResults fetchRequest] setPredicate:predicate];
  [[_fetchedResults fetchRequest] setSortDescriptors:sortDescriptors];
  
  NSError *error;
  if (![_fetchedResults performFetch:&error]){
    NSLog(@"ERR: %@",[error localizedDescription]);
    exit(-1);
  }
  
  [_updateTableView reloadData];
}

- (void)dealloc{
  [_fetchedResults release];
  [super dealloc];
}

- (void)performFetch{
  NSError *error;
  if (![_fetchedResults performFetch:&error]) {
    NSLog(@"ERR: %@", [error localizedDescription]);
    exit(-1);  // Fail
  }
}

- (void)performUpdate{
  NSMutableArray *oldObjectsBySection = [[NSMutableArray alloc] initWithCapacity:[[_fetchedResults sections] count]];
  for (id<NSFetchedResultsSectionInfo> sectInfo in [_fetchedResults sections]){
    [oldObjectsBySection addObject:[[[NSArray alloc] initWithArray:[sectInfo objects]] autorelease]];
  }
  [self performFetch];
  NSMutableArray *newObjectsBySection = [[NSMutableArray alloc] initWithCapacity:[[_fetchedResults sections] count]];
  for (id<NSFetchedResultsSectionInfo> sectInfo in [_fetchedResults sections]){
    [newObjectsBySection addObject:[[[NSArray alloc] initWithArray:[sectInfo objects]] autorelease]];
  }
  
  [_updateTableView beginUpdates];
  //If the number of sections are equal, our job is pretty easy:
  NSUInteger numSects = 0;
  if ([newObjectsBySection count] == [oldObjectsBySection count]){
    numSects = [oldObjectsBySection count];
  }
  else if ([newObjectsBySection count] > [oldObjectsBySection count]){
    //Insert sections
    NSRange sectionRange = NSMakeRange([oldObjectsBySection count]+sectionOffset, [newObjectsBySection count]-[oldObjectsBySection count]);
    [_updateTableView insertSections:[NSIndexSet indexSetWithIndexesInRange:sectionRange] withRowAnimation:UITableViewRowAnimationFade];
    
    numSects = [oldObjectsBySection count];
  }
  else{
    //Delete sections
    NSRange sectionRange = NSMakeRange([newObjectsBySection count]+sectionOffset, [oldObjectsBySection count]-[newObjectsBySection count]);
    [_updateTableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:sectionRange] withRowAnimation:UITableViewRowAnimationFade];
    
    numSects = [newObjectsBySection count];
  }
  
  for (int s = 0; s < numSects; s++){
    NSArray *oldSection = [oldObjectsBySection objectAtIndex:s];
    NSArray *newSection = [newObjectsBySection objectAtIndex:s];
    
    NSMutableArray *updateSet = [[NSMutableArray alloc] init];
    int r = 0;
    for (; r < [oldSection count]; r++){
      id oldObj = [oldSection objectAtIndex:r];
      id newObj = [newSection count] == r ? nil : [newSection objectAtIndex:r];
      if (!newObj){
        NSMutableArray *deleteSet = [[NSMutableArray alloc] init];
        for (; r < [oldSection count]; r++){
          [deleteSet addObject:[NSIndexPath indexPathForRow:r inSection:s+sectionOffset]];
        }
        [_updateTableView deleteRowsAtIndexPaths:deleteSet withRowAnimation:UITableViewRowAnimationFade];
        [deleteSet release];
        //Delete all rows after this one
        break;
      }
      
      if (oldObj == newObj){
        continue;
      }
      else{
        //Update the rows here
        [updateSet addObject:[NSIndexPath indexPathForRow:r inSection:s+sectionOffset]];
      }
    }
    //Determine if we need to insert sections
    if (r < [newSection count]){
      NSMutableArray *insertSet = [[NSMutableArray alloc] init];
      for (; r < [newSection count]; r++){
        [insertSet addObject:[NSIndexPath indexPathForRow:r inSection:s+sectionOffset]];
      }
      [_updateTableView insertRowsAtIndexPaths:insertSet withRowAnimation:UITableViewRowAnimationFade];
      [insertSet release];
    }
    
    [_updateTableView reloadRowsAtIndexPaths:updateSet withRowAnimation:UITableViewRowAnimationFade];
    //Update? No need to, really.
    [updateSet release];
  }
  [oldObjectsBySection release];
  [newObjectsBySection release];
  [_updateTableView endUpdates];
  if (self.delegate != NULL && [self.delegate respondsToSelector:@selector(dataFetcherDidFinishUpdating:)]){
    [delegate dataFetcherDidFinishUpdating:self];
  }
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath{
  return [_fetchedResults objectAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-sectionOffset]];
}

- (NSArray*)sections{
  if (sectionOffset == 0)
    return [_fetchedResults sections];
  
  //If it's greater than 0, we need to insert dummy objects for the resulting table
  NSMutableArray *sectArr = [[NSMutableArray alloc] initWithCapacity:[[_fetchedResults sections] count]+sectionOffset];
  for (int i = 0; i < sectionOffset; i++){
    [sectArr addObject:[NSNull null]];
  }
  for (int k = 0; k <[[_fetchedResults sections] count]; k++){
    [sectArr addObject:[[_fetchedResults sections] objectAtIndex:k]];
  }
  NSArray *retArr = [NSArray arrayWithArray:sectArr];
  [sectArr release];
  return retArr;
}

- (NSIndexSet*)sectionIndexSet{
  return [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [[self sections] count])];
}

- (NSFetchRequest*)fetchRequest{
  return [_fetchedResults fetchRequest];
}

- (NSManagedObjectContext*)managedObjectContext{
  return [_fetchedResults managedObjectContext];
}

- (NSUInteger)count{
  return [[_fetchedResults fetchedObjects] count];
}

- (NSArray*)fetchedObjects{
  return [_fetchedResults fetchedObjects];
}

//Tag
- (void)setTag:(NSUInteger)tag{
  _tag = tag;
}
- (NSUInteger)tag{
  return _tag;
}

@end
