//
//  DWFlashFlowRequest.m
//  DWFlashFlow
//
//  Created by Wicky on 2017/12/4.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "DWFlashFlowRequest.h"
#import "DWFlashFlowManager.h"

@implementation DWFlashFlowRequest

+(instancetype)requestWithRequest:(DWFlashFlowRequest *)request {
    return [request copy];
}

+(instancetype)requestWithResumeData:(NSData *)resumeData {
    DWFlashFlowRequest * r = [DWFlashFlowRequest new];
    r.requestType = DWFlashFlowRequestTypeDownload;
    configRequestWithStatus(r, DWFlashFlowRequestCanceled);
    configRequestWithResumeData(r, resumeData);
    return r;
}

-(void)startWithCompletion:(RequestCompletion)completion {
    if (completion) {
        self.requestCompletion = completion;
    }
    [super start];
}

-(void)startWithProgress:(ProgressCallback)progress completion:(RequestCompletion)completion {
    if (progress) {
        self.requestProgress = progress;
    }
    if (completion) {
        self.requestCompletion = completion;
    }
    [super start];
}

-(void)cancelByProducingResumeData:(void (^)(NSData *))completionHandler {
    [super cancel];
    [DWFlashFlowManager cancelRequest:self produceResumeData:YES completion:completionHandler];
}

-(void)resume {
    [DWFlashFlowManager resumeRequest:self];
}

-(void)suspend {
    [DWFlashFlowManager suspendRequest:self];
}

#pragma mark --- override ---
-(instancetype)init {
    if (self = [super init]) {
        _useGlobalParameters = YES;
        _useGlobalHeaders = YES;
        _needEncrypt = YES;
        _timeoutInterval = 60;
        _retryCount = 0;
        _retryDelayInterval = 2;
        _useGlobalPreprocessor = YES;
        _useGlobalReprocessing = YES;
        _method = DWFlashFlowMethodGET;
        _requestType = DWFlashFlowRequestTypeNormal;
        _requestSerializerType = DWFlashFlowRequestSerializerTypeJSON;
        _responseSerializerType = DWFlashFlowResponseSerializerTypeJSON;
        _cachePolicy = DWFlashFlowCachePolicyLoadOnly;
        _expiredInterval = 0;
    }
    return self;
}

-(id)copyWithZone:(NSZone *)zone {
    DWFlashFlowRequest * r = [[[self class] allocWithZone:zone] init];
    configRequestWithStatus(r, self.status);
    r.customID = self.customID;
    r.finishAfterComplete = self.finishAfterComplete;
    r.requestCompletion = [self.requestCompletion copy];
    r.apiURL = self.apiURL;
    r.fullURL = self.fullURL;
    r.method = self.method;
    r.requestType = self.requestType;
    r.requestSerializerType = self.requestSerializerType;
    r.responseSerializerType = self.responseSerializerType;
    r.parameters = [self.parameters copy];
    r.useGlobalParameters = self.useGlobalParameters;
    r.headers = [self.headers copy];
    r.useGlobalHeaders = self.useGlobalHeaders;
    r.needEncrypt = self.needEncrypt;
    r.timeoutInterval = self.timeoutInterval;
    r.userName = self.userName;
    r.password = self.password;
    r.retryCount = self.retryCount;
    r.retryDelayInterval = self.retryDelayInterval;
    r.preprocessorBeforeRequest = [self.preprocessorBeforeRequest copy];
    r.useGlobalPreprocessor = self.useGlobalPreprocessor;
    r.reprocessingAfterResponse = [self.reprocessingAfterResponse copy];
    r.useGlobalReprocessing = self.useGlobalReprocessing;
    r.requestProgress = [self.requestProgress copy];
    configRequestWithError(r, [self.error copy]);
    r.destination = [self.destination copy];
    r.downloadSavePath = self.downloadSavePath;
    configRequestWithResumeData(r, [self.resumeData copy]);
    r.files = [self.files copy];
    r.cachePolicy = self.cachePolicy;
    r.expiredInterval = self.expiredInterval;
    return r;
}

-(void)setValue:(id)value forKey:(NSString *)key {
    static NSArray * readonlyKeys = nil;
    if (!readonlyKeys) {
        readonlyKeys = @[@"task",@"resumeData",@"configuration",@"error"];
    }
    if ([readonlyKeys containsObject:key]) {
        NSAssert(NO, @"You can't set %@ for it's only use for framework.",key);
    } else {
        [super setValue:value forKey:key];
    }
}

-(void)start {
    [super start];
}

-(void)main {
    [super main];
    [DWFlashFlowManager sendRequest:self progress:self.requestProgress completion:self.requestCompletion];
}

-(void)cancel {
    [super cancel];
    [DWFlashFlowManager cancelRequest:self];
}

#pragma mark --- tool func ---
static inline void configRequestWithStatus(DWFlashFlowRequest * r,DWFlashFlowRequestStatus status) {
    [r willChangeValueForKey:@"status"];
    [r setValue:@(status) forKey:@"_status"];
    [r didChangeValueForKey:@"status"];
}

static inline void configRequestWithResumeData(DWFlashFlowRequest * r,NSData * resumeData) {
    [r setValue:resumeData forKey:@"_resumeData"];
}

static inline void configRequestWithError(DWFlashFlowRequest * r,NSError * error) {
    [r setValue:error forKey:@"_error"];
}
@end

@implementation DWFlashFlowRequestConfig

@end

