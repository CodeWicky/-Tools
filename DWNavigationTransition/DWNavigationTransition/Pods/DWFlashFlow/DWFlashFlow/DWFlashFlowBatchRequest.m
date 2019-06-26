//
//  DWFlashFlowBatchRequest.m
//  DWFlashFlow
//
//  Created by Wicky on 2018/1/29.
//  Copyright © 2018年 Wicky. All rights reserved.
//

#import "DWFlashFlowBatchRequest.h"
#import "DWFlashFlowManager.h"

@implementation DWFlashFlowBatchRequest

-(instancetype)initWithRequests:(NSArray<__kindof DWFlashFlowAbstractRequest *> *)requests {
    if (self = [super init]) {
        _requests = requests;
    }
    return self;
}

-(void)startWithCompletion:(RequestCompletion)completion {
    if (completion) {
        self.requestCompletion = completion;
    }
    [super start];
}

-(void)cancelByProducingResumeData:(void (^)(NSData *))completionHandler {
    [super cancel];
    [DWFlashFlowManager cancelRequest:self produceResumeData:YES completion:completionHandler];
}

-(void)suspend {
    [DWFlashFlowManager suspendRequest:self];
}

-(void)resume {
    [DWFlashFlowManager resumeRequest:self];
}

#pragma mark --- override ---
-(void)start {
    [super start];
}

-(void)main {
    [super main];
    [DWFlashFlowManager sendRequest:self completion:self.requestCompletion];
}

-(void)cancel {
    [super cancel];
    [DWFlashFlowManager cancelRequest:self];
}

#pragma mark --- setter/getter ---
-(NSOperationQueue *)requestQueue {
    if (!_requestQueue) {
        _requestQueue = [[NSOperationQueue alloc] init];
        _requestQueue.maxConcurrentOperationCount = 6;
    }
    return _requestQueue;
}

@end
