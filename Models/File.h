//
//  File.h
//  Puttio
//
//  Created by orta therox on 25/03/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "ORDisplayItemProtocol.h"

// These used to be NSManagedObjects
// but it was really starting to clog up iCloud sync
// so you'll see references to File & Folder in the xcdatamodel
// but the ones in there do nothing now. ./

@interface File : PKFile <ORDisplayItemProtocol>

@property (nonatomic, retain) NSNumber * watched;

@end
