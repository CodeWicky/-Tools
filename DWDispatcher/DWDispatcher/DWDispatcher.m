//
//  DWDispatcher.m
//  DWDispatcher
//
//  Created by Wicky on 2019/9/26.
//  Copyright © 2019 Wicky. All rights reserved.
//

#import "DWDispatcher.h"
#import <QuartzCore/QuartzCore.h>

@interface DWDispatcher ()

@property (nonatomic ,copy) DWDispatcherHandler handler;

@property (nonatomic ,strong) NSMutableArray * dispatchPool;

@property (nonatomic ,strong) NSThread * dispatchThread;

@property (nonatomic ,strong) NSTimer * dispatchTimer;

@property (nonatomic ,strong) dispatch_semaphore_t sema;

@property (nonatomic ,assign) NSTimeInterval lastPushTs;

@end

@implementation DWDispatcher

#pragma mark --- interface method ---
+(instancetype)dispatcherWithTimeInterval:(NSTimeInterval)timeInterval idleTimesToHangUp:(NSInteger)idleTimes handler:(DWDispatcherHandler)handler {
    return [[DWDispatcher alloc] initWithTimeInterval:timeInterval idleTimesToHangUp:idleTimes handler:handler];
}

-(void)dispatchObject:(id)object {
    if (!object) {
        return;
    }
    [self push:object];
}

#pragma mark --- tool method ---
-(instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval idleTimesToHangUp:(NSInteger)idleTimesToHangUp handler:(DWDispatcherHandler)handler {
    if (self = [super init]) {
        _timeInterval = timeInterval;
        _handler = handler;
        if (idleTimesToHangUp < 0) {
            _idleTimesToHangUp = 0;
        } else {
            _idleTimesToHangUp = idleTimesToHangUp;
        }
    }
    return self;
}

-(void)push:(id)obj {
    NSLog(@"Push %@!!!!",obj);
    dispatch_semaphore_wait(self.sema, DISPATCH_TIME_FOREVER);
    [self.dispatchPool addObject:obj];
    dispatch_semaphore_signal(self.sema);
    self.lastPushTs = CACurrentMediaTime();
    if (!_onService) {
        _onService = YES;
        [self performSelector:@selector(startTimer) onThread:self.dispatchThread withObject:nil waitUntilDone:NO];
    }
}

-(NSArray *)pop {
    dispatch_semaphore_wait(self.sema, DISPATCH_TIME_FOREVER);
    NSArray * items = [self.dispatchPool copy];
    [self.dispatchPool removeAllObjects];
    dispatch_semaphore_signal(self.sema);
    return items;
}

-(void)createDispatchRunloop {
    [[NSRunLoop currentRunLoop] addPort:[NSPort port] forMode:NSRunLoopCommonModes];
    [[NSRunLoop currentRunLoop] run];
}

-(void)startTimer {
    [[NSRunLoop currentRunLoop] addTimer:self.dispatchTimer forMode:NSRunLoopCommonModes];
}

#pragma mark --- timer action ---
-(void)timerAction:(NSTimer *)sender {
    NSLog(@"On service!!!!");
    NSArray * items = [self pop];
    if (items.count && self.handler) {
        NSLog(@"Pop!!!!");
        self.handler(items);
    }
    if (self.idleTimesToHangUp > 0 && CACurrentMediaTime() - self.lastPushTs > self.timeInterval * self.idleTimesToHangUp) {
        NSLog(@"Hang up!!!!");
        [self.dispatchTimer invalidate];
        self.dispatchTimer = nil;
        _onService = NO;
    }
}

#pragma mark --- setter/getter ---
-(NSMutableArray *)dispatchPool {
    if (!_dispatchPool) {
        _dispatchPool = [NSMutableArray array];
    }
    return _dispatchPool;
}

-(NSThread *)dispatchThread {
    if (!_dispatchThread) {
        _dispatchThread = [[NSThread alloc] initWithTarget:self selector:@selector(createDispatchRunloop) object:nil];
        [_dispatchThread start];
    }
    return _dispatchThread;
}

-(NSTimer *)dispatchTimer {
    if (!_dispatchTimer) {
        _dispatchTimer = [NSTimer timerWithTimeInterval:self.timeInterval target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    }
    return _dispatchTimer;
}

-(dispatch_semaphore_t)sema {
    if (!_sema) {
        _sema = dispatch_semaphore_create(1);
    }
    return _sema;
}

@end
