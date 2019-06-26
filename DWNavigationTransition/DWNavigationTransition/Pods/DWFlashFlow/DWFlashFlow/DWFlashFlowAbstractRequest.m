//
//  DWFlashFlowAbstractRequest.m
//  DWFlashFlow
//
//  Created by Wicky on 2018/1/29.
//  Copyright © 2018年 Wicky. All rights reserved.
//

#import "DWFlashFlowAbstractRequest.h"
#import "DWFlashFlowManager.h"

@interface DWFlashFlowAbstractRequest ()

@property (nonatomic ,assign ,getter=isFinished) BOOL finished;

@property (nonatomic ,assign ,getter=isExecuting) BOOL executing;

@property (nonatomic ,strong) DWFlashFlowAbstractRequest * cycleSelf;

@end

@implementation DWFlashFlowAbstractRequest
@synthesize finished = _finished;
@synthesize executing = _executing;

-(void)finishOperation {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    _finished = YES;
    _executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    freeOperation(self);
}

#pragma mark --- override ---
-(instancetype)init {
    if ([self class] == [DWFlashFlowAbstractRequest class]) {
        NSAssert(NO, @"DWFlashFlowAbstractRequest is just an abstract class and you should use subclass of it.");
        return nil;
    }
    if (self = [super init]) {
        _requestID = keyForRequest(self);
        _finishAfterComplete = YES;
        _status = DWFlashFlowRequestReady;
    }
    return self;
}

-(void)start {
    if ([self class] == [DWFlashFlowAbstractRequest class]) {
        NSAssert(NO, @"DWFlashFlowAbstractRequest is just an abstract class and you should use subclass of it.");
        return;
    }
    if (self.isCancelled) {
        [self willChangeValueForKey:@"isFinished"];
        _finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    ///持有自身，防止标志完成之前释放
    self.cycleSelf = self;
    [super start];
}

-(void)main {
    ///配置request为执行状态
    [self willChangeValueForKey:@"isExecuting"];
    _executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [super main];
}

-(void)cancel {
    [super cancel];
    freeOperation(self);
}

-(void)setValue:(id)value forKey:(NSString *)key {
    static NSArray * readonlyKeys = nil;
    if (!readonlyKeys) {
        readonlyKeys = @[@"requestID",@"status",@"response"];
    }
    if ([readonlyKeys containsObject:key]) {
        NSAssert(NO, @"You can't set %@ for it's only use for framework.",key);
    } else {
        [super setValue:value forKey:key];
    }
}

-(void)dealloc {
    NSLog(@"%@<%@> dealloc",NSStringFromClass([self class]) ,self.customID.length?self.customID:self.requestID);
}

#pragma mark --- tool func ---
static inline void freeOperation(DWFlashFlowAbstractRequest * op) {
    op.cycleSelf = nil;
}

static inline NSString * keyForRequest(DWFlashFlowAbstractRequest * r) {
    return [NSString stringWithFormat:@"%08x%p",(int)[[NSDate date] timeIntervalSince1970] * 100000,r];
}
@end
