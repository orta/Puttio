//
//  BaseProcess.h
//  Puttio
//
//  Created by orta therox on 16/06/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseProcess : NSObject

@property (assign) CGFloat progress;
@property (assign) BOOL finished;

- (void)start;
- (void)tick;
- (void)end;

- (NSString *)primaryDescription;
@end
