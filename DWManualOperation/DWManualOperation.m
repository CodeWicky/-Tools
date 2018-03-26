//
//  DWManualOperation.m
//  a
//
//  Created by Wicky on 2018/1/17.
//  Copyright © 2018年 Wicky. All rights reserved.
//

#import "DWManualOperation.h"

@interface DWManualOperation ()

///继承自NSOperation时为了自行控制执行状态，需实重写以下两个属性，重写后，系统无法改变状态，需要自行触发状态改变。改变状态时应调用 -willChangeValueForKey: 和 -didChangeValueForKey: 来保证KVO正常触发。executing默认状态系统为 -main 方法开始时改变为YES。任务处理完成时改变executing为NO，finished为YES。

///为保证单独使用时，Operation可以在调用-finishOperation之前不被释放，故自身持有自身，完成时在释放自身持有。
///为保证子类在NSOperationQueue中可以有正常响应，应保证两个状态时刻正确。其正确状态为：
///-start中如果isCanceled状态为真则将finished置为YES并不调用-main方法。
///-main中将executing置为YES。
///任务处于完成状态时将executing置为NO,finished置为YES。
@property (nonatomic ,assign ,getter=isFinished) BOOL finished;

@property (nonatomic ,assign ,getter=isExecuting) BOOL executing;

@property (nonatomic ,strong) NSMutableArray <OperationHandler>* handlerContainer;

@property (atomic ,assign) NSUInteger handlerCount;

@property (nonatomic ,strong) DWManualOperation * cycleSelf;

@end

@implementation DWManualOperation
@synthesize finished = _finished;
@synthesize executing = _executing;

#pragma mark --- interface method ---
+(instancetype)manualOperationWithHandler:(OperationHandler)handler {
    DWManualOperation * op = [DWManualOperation new];
    if (handler) {
        [op.handlerContainer addObject:handler];
    }
    return op;
}

-(void)addExecutionHandler:(OperationHandler)handler {
    if (self.isExecuting || self.isFinished) {///执行中或完成的任务不可以再添加回调
        return;
    }
    if (handler) {
        [self.handlerContainer addObject:handler];
    }
}

-(void)handlerDone {
    if (self.isExecuting && !self.isFinished && self.handlerCount > 0) {
        self.handlerCount --;
        if (self.handlerCount == 0) {
            [self finishOperation];
        }
    }
}

-(void)finishOperation {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    _finished = YES;
    _executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

#pragma mark --- override ---
-(instancetype)init {
    if (self = [super init]) {
        _concurrentHandler = YES;
        self.completionBlock = nil;
    }
    return self;
}

-(void)start {
    NSLog(@"start");
    ///如果是被取消状态则置为完成状态并返回，为了配合NSOperationQueue使用
    if (self.isCancelled) {
        [self willChangeValueForKey:@"isFinished"];
        _finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    if (self.isExecuting || self.isFinished) {///正在执行或已经完成的任务不可以调用开始方法。
        return;
    }
    self.cycleSelf = self;
    _handlerCount = self.handlerContainer.count;
    [super start];
}

-(void)cancel {
    [super cancel];
}

-(void)main {///系统实现中 -start 方法中会调用 -main 方法
    [self willChangeValueForKey:@"isExecuting"];
    _executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [super main];
    __weak typeof(self)weakSelf = self;
    NSEnumerationOptions opt = NSEnumerationConcurrent;
    if (!self.concurrentHandler) {
        opt = 0;
    }
    [self.handlerContainer enumerateObjectsWithOptions:(opt) usingBlock:^(OperationHandler  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj(weakSelf);
    }];
}

-(void)dealloc {
    NSLog(@"dealloc");
}

#pragma mark --- tool func ---
static inline void freeOperation(DWManualOperation * op) {
    op.cycleSelf = nil;
}

#pragma mark --- setter/getter ---
-(void)setConcurrentHandler:(BOOL)concurrentHandler {
    if (self.isExecuting || self.isFinished) {
        return;
    }
    _concurrentHandler = concurrentHandler;
}

-(void)setCompletionBlock:(void (^)(void))completionBlock {
    __weak typeof(self)weakSelf = self;
    dispatch_block_t ab = ^(void) {
        if (completionBlock) {
            completionBlock();
        }
        freeOperation(weakSelf);
    };
    [super setCompletionBlock:ab];
}

-(NSMutableArray<OperationHandler> *)handlerContainer {
    if (!_handlerContainer) {
        _handlerContainer = @[].mutableCopy;
    }
    return _handlerContainer;
}

@end
