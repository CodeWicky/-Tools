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

@property (nonatomic ,strong) NSBlockOperation * op;

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

+(instancetype)dw_TransactionWithCompletion:(dispatch_block_t)completion {
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

+(instancetype)dw_TransactionWithTarget:(id)target selector:(SEL)selector {
    return [self dw_TransactionWithTarget:target selector:selector withObject:nil];
}

+(instancetype)dw_TransactionWithTarget:(id)target selector:(SEL)selector withObject:(id)object {
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

+(instancetype)dw_WaitUtil:(NSTimeInterval)timeout completion:(dispatch_block_t)completion {
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

+(instancetype)dw_WaitWithCompletion:(dispatch_block_t)completion {
    return [self dw_WaitUtil:-1 completion:completion];
}

+(instancetype)dw_WaitUtil:(NSTimeInterval)timeout target:(id)target selector:(SEL)selector {
    return [self dw_WaitUtil:timeout target:target selector:selector object:nil];
}

+(instancetype)dw_WaitUtil:(NSTimeInterval)timeout target:(id)target selector:(SEL)selector object:(id)object {
    if (!target || !selector) {
        return nil;
    }
    dispatch_block_t ab = ^(void) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [target performSelector:selector withObject:object];
#pragma clang diagnostic pop
    };
    DWTransaction * transaction = [DWTransaction dw_WaitUtil:timeout completion:ab];
    transaction.target = target;
    transaction.selector = selector;
    transaction.object = object;
    return transaction;
}

+(instancetype)dw_WaitWithTarget:(id)target selector:(SEL)selector {
    return [self dw_WaitUtil:-1 target:target selector:selector];
}

+(instancetype)dw_WaitWithTarget:(id)target selector:(SEL)selector object:(id)object {
    return [self dw_WaitUtil:-1 target:target selector:selector object:object];
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

static inline void freeTransaction(DWTransaction * trans) {
    trans.cycleSelf = nil;
    trans.target = nil;
    trans.selector = nil;
    trans.object = nil;
}
@end
