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
        [transaction.target performSelector:transaction.selector];
#pragma clang diagnostic pop
    }];
}

+(instancetype)dw_TransactionWithTarget:(id)target selector:(SEL)selector {
    if (!target || !selector) {
        return nil;
    }
    DWTransaction * transaction = [DWTransaction new];
    transaction.target = target;
    transaction.selector = selector;
    return transaction;
}

-(void)commit {
    if (!self.target || !self.selector) {
        return;
    }
    DWTransactionCreateObserver();
    [transactionSet addObject:self];
}
@end
