//
//  DWTransaction.m
//  hgfd
//
//  Created by Wicky on 2017/2/25.
//  Copyright © 2017年 Wicky. All rights reserved.
//


#import "DWTransaction.h"

@interface DWTransaction ()

@property (nonatomic ,strong) id target;

@property (nonatomic ,assign) SEL selector;

@property (nonatomic ,strong) id object;

@property (nonatomic ,strong) DWTransaction * cycleSelf;

#pragma mark --- Wait ---
@property (nonatomic ,strong) NSBlockOperation * op;

#pragma mark --- MissionComlpetion ---
@property (atomic ,assign) int missionCount;

@property (nonatomic ,strong) NSMutableArray <dispatch_block_t>* completionHandlerContainer;

@property (nonatomic ,strong) dispatch_semaphore_t sema;

@end

@implementation DWTransaction

static NSMutableSet * transactionSet = nil;

static inline void DWTransactionCreateObserver(){
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        transactionSet = [NSMutableSet set];
        CFRunLoopRef runloop = CFRunLoopGetCurrent();
        CFRunLoopObserverRef observer = CFRunLoopObserverCreate(CFAllocatorGetDefault(),
                                           kCFRunLoopBeforeWaiting | kCFRunLoopExit,
                                           true,      // repeat
                                           INT_MAX,  // after CATransaction(2000000)
                                           DWTransactionCallBack, NULL);
        CFRunLoopAddObserver(runloop, observer, kCFRunLoopCommonModes);
        CFRelease(observer);
    });
}

static inline void DWTransactionCallBack(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
    if (transactionSet.count == 0) return;
    NSSet *currentSet = transactionSet;
    transactionSet = [NSMutableSet new];
    [currentSet enumerateObjectsUsingBlock:^(DWTransaction *transaction, BOOL *stop) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [transaction.target performSelector:transaction.selector withObject:transaction.object];
        freeTransaction(transaction);
#pragma clang diagnostic pop
    }];
}

+(instancetype)transactionWithCompletion:(dispatch_block_t)completion {
    if (!completion) {
        return nil;
    }
    DWTransaction * transaction = [DWTransaction new];
    transaction.target = transaction;
    transaction.selector = @selector(transactionBlock:);
    transaction.object = [completion copy];
    return transaction;
}

-(void)transactionBlock:(dispatch_block_t)aBlock {
    if (aBlock) {
        aBlock();
    }
}

+(instancetype)transactionWithTarget:(id)target selector:(SEL)selector {
    return [self transactionWithTarget:target selector:selector withObject:nil];
}

+(instancetype)transactionWithTarget:(id)target selector:(SEL)selector withObject:(id)object {
    if (!target || !selector) {
        return nil;
    }
    DWTransaction * transaction = [DWTransaction new];
    transaction.target = target;
    transaction.selector = selector;
    transaction.object = object;
    return transaction;
}

-(void)commit {
    if (!self.target || !self.selector) {
        return;
    }
    DWTransactionCreateObserver();
    [transactionSet addObject:self];
}

#pragma mark --- setter/getter ---
-(NSMutableArray<dispatch_block_t> *)completionHandlerContainer {
    if (!_completionHandlerContainer) {
        _completionHandlerContainer = @[].mutableCopy;
    }
    return _completionHandlerContainer;
}

-(dispatch_semaphore_t)sema {
    if (!_sema) {
        _sema = dispatch_semaphore_create(1);
    }
    return _sema;
}

#pragma mark --- tool func ---
static inline void freeTransaction(DWTransaction * trans) {
    trans.cycleSelf = nil;
    trans.target = nil;
    trans.selector = nil;
    trans.object = nil;
    trans.completionHandlerContainer = nil;
    trans.missionCount = 0;
    trans.sema = nil;
}
@end

@implementation DWTransaction (Wait)

+(instancetype)waitUtil:(NSTimeInterval)timeout completion:(dispatch_block_t)completion {
    if (!completion) {
        return nil;
    }
    DWTransaction * transaction = [DWTransaction new];
    [transaction setupTransactionWithTimeout:timeout completion:completion];
    return transaction;
}

-(void)setupTransactionWithTimeout:(NSTimeInterval)timeout completion:(dispatch_block_t)completion {
    self.cycleSelf = self;
    __weak typeof(self)weakSelf = self;
    dispatch_block_t ab = ^(void) {
        if (completion) {
            completion();
        }
        freeTransaction(weakSelf);
    };
    NSBlockOperation * op = [NSBlockOperation blockOperationWithBlock:ab];
    if (timeout > 0) {
        [op performSelector:@selector(start) withObject:nil afterDelay:timeout];
    }
    self.op = op;
}

+(instancetype)waitWithCompletion:(dispatch_block_t)completion {
    return [self waitUtil:-1 completion:completion];
}

+(instancetype)waitUtil:(NSTimeInterval)timeout target:(id)target selector:(SEL)selector {
    return [self waitUtil:timeout target:target selector:selector object:nil];
}

+(instancetype)waitUtil:(NSTimeInterval)timeout target:(id)target selector:(SEL)selector object:(id)object {
    if (!target || !selector) {
        return nil;
    }
    dispatch_block_t ab = ^(void) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [target performSelector:selector withObject:object];
#pragma clang diagnostic pop
    };
    DWTransaction * transaction = [DWTransaction waitUtil:timeout completion:ab];
    transaction.target = target;
    transaction.selector = selector;
    transaction.object = object;
    return transaction;
}

+(instancetype)waitWithTarget:(id)target selector:(SEL)selector {
    return [self waitUtil:-1 target:target selector:selector];
}

+(instancetype)waitWithTarget:(id)target selector:(SEL)selector object:(id)object {
    return [self waitUtil:-1 target:target selector:selector object:object];
}

-(void)run {
    if (!self.op.isFinished && !self.op.isCancelled) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self.op];
        [self.op start];
    }
}

-(void)cancel {
    [self cancelWithHandler:nil];
}

-(void)cancelWithHandler:(dispatch_block_t)handler {
    if (!self.op.isFinished && !self.op.isCancelled) {
        [self.op cancel];
        if (handler) {
            handler();
        }
        freeTransaction(self);
    }
}

-(void)invalidate {
    freeTransaction(self);
}

@end

@implementation DWTransaction (MissionComlpetion)

+(instancetype)configWithMissionCompletionHandler:(dispatch_block_t)completion {
    DWTransaction * t = [DWTransaction new];
    if (completion) {
        [t.completionHandlerContainer addObject:completion];
    }
    return t;
}

-(void)addMissionCompletionHandler:(dispatch_block_t)completion {
    if (!completion) {
        return;
    }
    dispatch_semaphore_wait(self.sema, DISPATCH_TIME_FOREVER);
    [self.completionHandlerContainer addObject:completion];
    dispatch_semaphore_signal(self.sema);
}

-(void)startAnMission {
    if (!self.cycleSelf) {
        self.cycleSelf = self;
    }
    self.missionCount ++;
}

-(void)finishAnMission {
    self.missionCount --;
    if (self.missionCount == 0) {
        [self callCompletionHandler];
    }
}

-(void)callCompletionHandler {
    dispatch_semaphore_wait(self.sema, DISPATCH_TIME_FOREVER);
    [self.completionHandlerContainer enumerateObjectsUsingBlock:^(dispatch_block_t  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj();
    }];
    [self.completionHandlerContainer removeAllObjects];
    dispatch_semaphore_signal(self.sema);
    freeTransaction(self);
}

@end
