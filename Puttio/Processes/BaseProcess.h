//
//  BaseProcess.h
//  Puttio
//
//  Created by orta therox on 16/06/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BaseProcess;
@protocol BaseProcessDelegate <NSObject>
- (void)processDidFinish:(BaseProcess *)process;
@end

@interface BaseProcess : NSObject

@property (nonatomic, assign) CGFloat progress;
@property (assign) BOOL finished;
@property (weak) id <BaseProcessDelegate> delegate;
- (void)start;
- (void)tick;
- (void)end;

- (NSString *)primaryDescription;
@end
