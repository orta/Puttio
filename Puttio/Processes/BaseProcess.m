//
//  BaseProcess.m
//  Puttio
//
//  Created by orta therox on 16/06/2012.
//  Copyright (c) 2012 ortatherox.com. All rights reserved.
//

#import "BaseProcess.h"
#import "StatusViewController.h"

@interface BaseProcess(){
    NSTimer *timer_;
    int killCount;
}
@end

@implementation BaseProcess

- (id)init {
    if (self = [super init]) {
        [StatusViewController.sharedController addProcess:self];
        self.delegate = StatusViewController.sharedController;
        [self start];
    }
    return self;
}

- (void)start {
    timer_ = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    [timer_ fire];
}

- (void)tick {
    if (self.finished) {
        [self end];
    }
}

- (void)end {
    self.finished = 1;
    [timer_ invalidate];
    [self.delegate processDidFinish:self];
}

- (NSString *)primaryDescription {
    return @"DESCRIPTION";
}

@end
