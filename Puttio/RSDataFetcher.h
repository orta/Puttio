// RSDataFetcher.h
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

#import <Foundation/Foundation.h>

@class RSDataFetcher;
@protocol RSDataFetcherDelegate;

@interface RSDataFetcher : NSObject <NSFetchedResultsControllerDelegate>{
  NSFetchedResultsController *_fetchedResults;
  UITableView *_updateTableView;
  NSUInteger _tag;
  id<RSDataFetcherDelegate> delegate;
  
  NSUInteger sectionOffset;
}

@property (assign) id<RSDataFetcherDelegate> delegate;
@property (nonatomic) NSUInteger sectionOffset;

//Longest way
- (id)initWithFetchRequest:(NSFetchRequest*)fetchRequest inContext:(NSManagedObjectContext*)context withKeyPath:(NSString*)keyPath usingCache:(NSString*)cache inTableView:(UITableView*)tableView;
- (void)refreshRequestWithPredicate:(NSPredicate*)predicate andSortDescriptors:(NSArray*)sortDescriptors;

- (void)performFetch;
- (void)performUpdate;
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSArray*)sections;
- (NSFetchRequest*)fetchRequest;
- (NSManagedObjectContext*)managedObjectContext;
- (NSUInteger)count;
- (NSArray*)fetchedObjects;
- (NSIndexSet*)sectionIndexSet;
//Tag
- (void)setTag:(NSUInteger)tag;
- (NSUInteger)tag;

@end

@protocol RSDataFetcherDelegate <NSObject>
@optional
-(void)dataFetcherDidFinishUpdating:(RSDataFetcher*)dataFetcher;
@end

