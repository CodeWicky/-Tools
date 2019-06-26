//
//  DWFlashFlowChainRequest.m
//  DWFlashFlow
//
//  Created by Wicky on 2018/2/1.
//  Copyright © 2018年 Wicky. All rights reserved.
//

#import "DWFlashFlowChainRequest.h"
#import "DWFlashFlowManager.h"
#import <objc/runtime.h>

@implementation DWFlashFlowChainRequest

-(instancetype)initWithRequests:(NSArray<__kindof DWFlashFlowAbstractRequest *> *)requests {
    if (self = [super init]) {
        _requests = requests;
        _cancelOnFailure = YES;
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

#pragma mark --- tool func ---
static inline void configRequestWithResponse(DWFlashFlowAbstractRequest * r,id response) {
    [r setValue:response forKey:@"_response"];
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

-(void)setValue:(id)value forKey:(NSString *)key {
    static NSArray * readonlyKeys = nil;
    if (!readonlyKeys) {
        readonlyKeys = @[@"currentRequest"];
    }
    if ([readonlyKeys containsObject:key]) {
        NSAssert(NO, @"You can't set %@ for it's only use for framework.",key);
    } else {
        [super setValue:value forKey:key];
    }
}

#pragma mark --- setter/getter ---
-(id)response {
    NSMutableDictionary *r = [super response];
    if (!r) {
        r = @{}.mutableCopy;
        configRequestWithResponse(self, r);
    }
    return r;
}

-(NSOperationQueue *)requestQueue {
    if (!_requestQueue) {
        _requestQueue = [[NSOperationQueue alloc] init];
        _requestQueue.maxConcurrentOperationCount = 1;
    }
    return _requestQueue;
}

@end

@implementation DWFlashFlowRequest (ChainParameter)

-(ChainParameter)chainParameterHandler {
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setChainParameterHandler:(ChainParameter)chainParameterHandler {
    objc_setAssociatedObject(self, @selector(chainParameterHandler), chainParameterHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

@implementation DWFlashFlowAbstractRequest (ChainParameter)

-(ReponseInfo)responseInfoHandler {
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setResponseInfoHandler:(ReponseInfo)responseInfoHandler {
    objc_setAssociatedObject(self, @selector(responseInfoHandler), responseInfoHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
