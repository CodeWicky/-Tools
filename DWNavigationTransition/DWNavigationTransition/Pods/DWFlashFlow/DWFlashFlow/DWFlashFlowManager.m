//
//  DWFlashFlowManager.m
//  DWFlashFlow
//
//  Created by Wicky on 2017/12/4.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "DWFlashFlowManager.h"
#import "DWFlashFlowRequest.h"
#import "DWFlashFlowBatchRequest.h"
#import "DWFlashFlowChainRequest.h"
#import <objc/runtime.h>

@interface DWFlashFlowAbstractRequest (Private)

@property (nonatomic ,weak) DWFlashFlowChainRequest * chainRequest;

@end

@implementation DWFlashFlowAbstractRequest (Private)

-(DWFlashFlowChainRequest *)chainRequest {
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setChainRequest:(DWFlashFlowChainRequest *)chainRequest {
    objc_setAssociatedObject(self, @selector(chainRequest), chainRequest, OBJC_ASSOCIATION_ASSIGN);
}

@end

@interface DWFlashFlowRequest (Private)

@property (nonatomic ,copy) RequestCompletion oriCompletion;

@end

@implementation DWFlashFlowRequest (Private)

-(RequestCompletion)oriCompletion {
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setOriCompletion:(RequestCompletion)oriCompletion {
    objc_setAssociatedObject(self, @selector(oriCompletion), oriCompletion, OBJC_ASSOCIATION_COPY);
}

@end

@interface DWFlashFlowBatchRequest (Private)

@property (nonatomic ,assign) BOOL successStatus;

@end

@implementation DWFlashFlowBatchRequest (Private)

-(BOOL)successStatus {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

-(void)setSuccessStatus:(BOOL)successStatus {
    objc_setAssociatedObject(self, @selector(successStatus), @(successStatus), OBJC_ASSOCIATION_ASSIGN);
}

@end

@interface DWFlashFlowChainRequest (Private)

@property (nonatomic ,strong) NSMutableDictionary * responseInfo;
@property (nonatomic ,assign) BOOL successStatus;

@end

@implementation DWFlashFlowChainRequest (Private)

-(NSMutableDictionary *)responseInfo {
    NSMutableDictionary * r = objc_getAssociatedObject(self, _cmd);
    if (!r) {
        r = @{}.mutableCopy;
        self.responseInfo = r;
    }
    return r;
}

-(void)setResponseInfo:(id)responseInfo {
    objc_setAssociatedObject(self, @selector(responseInfo), responseInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)successStatus {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

-(void)setSuccessStatus:(BOOL)successStatus {
    objc_setAssociatedObject(self, @selector(successStatus), @(successStatus), OBJC_ASSOCIATION_ASSIGN);
}

@end



#define isKindofClass(A) varIsKindofClass(request,A)
#define varIsKindofClass(var,A) ([var isKindOfClass:[A class]])

NSString * const responseCacheErrorDomain = @"com.DWFlashFlow.error.responseCache";
NSString * const requestCanceledErrorDomain = @"com.DWFlashFlow.error.requestCanceled";
NSString * const requestBatchFailErrorDomian = @"com.DWFlashFlow.error.requestFail.batch";
NSString * const requestChainFailErrorDomain = @"com.DWFlashFlow.error.requestFail.chain";
const NSInteger CacheOnlyButNoCache = 10001;
const NSInteger RequestCanceled = 10002;
const NSInteger BatchRequestFail = 10003;
const NSInteger ChainReuqestFail = 10004;

static DWFlashFlowManager * mgr = nil;

@interface DWFlashFlowManager ()

@property (nonatomic ,strong) DWFlashFlowBaseLinker * linker;

@property (nonatomic ,strong) NSMutableDictionary * requestContainer;

@end

@implementation DWFlashFlowManager

#pragma mark --- 发送 ---
+(void)sendRequest:(__kindof DWFlashFlowAbstractRequest *)request completion:(RequestCompletion)completion {
    [self sendRequest:request progress:nil completion:completion];
}

+(void)sendRequest:(__kindof DWFlashFlowAbstractRequest *)request progress:(ProgressCallback)progress completion:(RequestCompletion)completion {
    if (!request) {///如果为空则直接返回
        return;
    }
    
    ///保存request对象避免任务完成前释放
    NSString * key = request.requestID;
    DWFlashFlowManager * m = [self manager];
    [m saveRequest:request withKey:key];
    if (isKindofClass(DWFlashFlowRequest)) {
        [m sendNormalRequest:request progress:progress completion:completion];
    } else if (isKindofClass(DWFlashFlowBatchRequest)) {
        [m sendBatchRequest:request progress:progress completion:completion];
    } else if (isKindofClass(DWFlashFlowChainRequest)) {
        [m sendChainRequest:request progress:progress completion:completion];
    }
    
    ///配置当前请求
    if (request.chainRequest) {
        configChainRequestWithCurrentRequest(request.chainRequest, request);
    }
}

#pragma mark --- 取消 ---
+(void)cancelRequest:(__kindof DWFlashFlowAbstractRequest *)request {
    if (isKindofClass(DWFlashFlowRequest)) {
        [self cancelNormalRequest:request];
    } else if (isKindofClass(DWFlashFlowBatchRequest) || isKindofClass(DWFlashFlowChainRequest)) {
        [self cancelGroupRequest:request];
    }
}

+(void)cancelRequest:(__kindof DWFlashFlowAbstractRequest *)request produceResumeData:(BOOL)produce completion:(void (^)(NSData *))completion {
    if (isKindofClass(DWFlashFlowRequest) ) {
        [self cancelNormalRequest:request produceResumeData:produce completion:completion];
    } else if (isKindofClass(DWFlashFlowBatchRequest) || isKindofClass(DWFlashFlowChainRequest)) {
        [self cancelGroupRequest:request produceResumeData:produce completion:completion];
    }
}

+(void)cancelAll {
    enumerateRequest([DWFlashFlowManager manager], ^(NSString *key, DWFlashFlowRequest * request, BOOL * stop) {
        [self cancelRequest:request];
    });
}

#pragma mark --- 暂停 ---
+(void)suspendRequest:(__kindof DWFlashFlowAbstractRequest *)request {
    if (isKindofClass(DWFlashFlowRequest)) {
        [self suspendNormalRequest:request];
    } else if (isKindofClass(DWFlashFlowBatchRequest) || isKindofClass(DWFlashFlowChainRequest)) {
        [self suspendGroupRequest:request];
    }
}

+(void)suspendAll {
    enumerateRequest([DWFlashFlowManager manager], ^(NSString *key, DWFlashFlowRequest * request, BOOL * stop) {
        [self suspendRequest:request];
    });
}

#pragma mark --- 恢复 ---
+(void)resumeRequest:(__kindof DWFlashFlowAbstractRequest *)request {
    if (isKindofClass(DWFlashFlowRequest)) {
        [self resumeNormalRequest:request];
    } else if (isKindofClass(DWFlashFlowBatchRequest) || isKindofClass(DWFlashFlowChainRequest)) {
        [self resumeGroupRequest:request];
    }
}

+(void)resumeAll {
    enumerateRequest([DWFlashFlowManager manager], ^(NSString *key, DWFlashFlowRequest * request, BOOL * stop) {
        [self resumeRequest:request];
    });
}

#pragma mark --- 取Request ---
+(__kindof DWFlashFlowAbstractRequest *)requestForID:(NSString *)requestID {
    if (!requestID) {
        return nil;
    }
    return [[DWFlashFlowManager manager].requestContainer valueForKey:requestID];
}

#pragma mark --- tool method ---
+(void)afterFire:(dispatch_block_t)ab {
    if (ab) {
        ab();
    }
}

-(void)saveRequest:(DWFlashFlowRequest *)r withKey:(NSString *)key {
    [self.requestContainer setValue:r forKey:key];
}

-(void)removeRequestWithKey:(NSString *)key {
    if (!key.length) {
        return;
    }
    [self.requestContainer removeObjectForKey:key];
}

-(DWFlashFlowRequest *)requestForKey:(NSString *)key {
    return self.requestContainer[key];
}

-(void)configRequestWithGlobal:(DWFlashFlowRequest *)r {
    DWFlashFlowRequestConfig * config = [DWFlashFlowRequestConfig new];
    config.actualURL = [self.linker requestURLFromRequest:r];
    id p = [self.linker parametersFromRequest:r];
    if (self.encryptor && r.needEncrypt) {
        p = [self.encryptor encrypt:p];
    }
    config.actualParameters = p;
    config.actualHeaders = [self.linker headersFromRequest:r];
    config.actualPreprocessing = [self.linker preprocessorFromRequest:r];
    config.actualReprocessor = [self.linker reprocessorFromRequest:r];
    configRequestWithConfig(r,config);
}

///考虑是否存储缓存的请求结束动作，此处包括请求状态的配置请求状态、缓存响应数据、回调成功动作
-(void)requestCompleteActionWithRequest:(DWFlashFlowRequest *)r success:(BOOL)success response:(id)response error:(NSError *)error cacheResponse:(BOOL)cacheResponse needRequestThen:(BOOL)needRequestThen completion:(RequestCompletion)completion {
    
    ///如果不是先行回调继续请求的话则将请求状态置为完成（即请求确实已经完成）
    if (!needRequestThen) {
        ///改变请求状态
        if (r.status != DWFlashFlowRequestCanceled) {
            configRequestWithStatus(r, DWFlashFlowRequestFinish);
        }
    }
    ///如果考虑缓存则此处缓存数据(当且仅当是普通请求且请求完成且请求成功且数据不为空且需要缓存时才缓存)
    if (cacheResponse && success && r.status == DWFlashFlowRequestFinish && response && r.requestType == DWFlashFlowRequestTypeNormal) {
        ///如果当前缓存策略需要缓存则异步缓存
        NSArray * savePolicy = @[@(DWFlashFlowCachePolicyLoadOnlyAndSave),
                                 @(DWFlashFlowCachePolicyLocalThenLoad),
                                 @(DWFlashFlowCachePolicyLocalElseLoad),
                                 @(DWFlashFlowCachePolicyLocalOnly)];
        if ([savePolicy containsObject:@(r.cachePolicy)]) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self.cacheHandler storeCachedResponse:response forKey:r.configuration.actualURL request:r];
            });
        }
    }
    ///处理响应数据并回调
    [self requestCompleteActionWithRequest:r success:success response:response error:error needRequestThen:needRequestThen completion:completion];
}

///回调成功动作，此处包括数据的处理（解密、二次处理、配置请求，执行回调）
-(void)requestCompleteActionWithRequest:(DWFlashFlowRequest *)r success:(BOOL)success response:(id)response error:(NSError *)error needRequestThen:(BOOL)needRequestThen completion:(RequestCompletion)completion {
    
    ///解密数据
    if (self.encryptor && r.needEncrypt) {
        response = [self.encryptor decrypt:response];
    }
    ProcessorBlock reprocessor = r.configuration.actualReprocessor;
    ///二次处理响应数据
    if (reprocessor) {
        response = reprocessor(r,response);
    }
    ///赋值响应数据
    configRequestWithResponse(r, response);
    ///赋值错误
    if (error) {
        configRequestWithError(r, error);
    }
    ///配置链请求响应
    if (r.chainRequest && r.responseInfoHandler) {
        __weak typeof(r)weakR = r;
        r.responseInfoHandler(weakR.response, weakR.chainRequest.responseInfo);
    }
    ///回调请求结果
    if (completion) {
        __weak typeof(r)weakR = r;
        completion(success,response,error,weakR);
    }
    ///还需继续请求，不做实际结束回调
    if (!needRequestThen) {
        [self requestFinishAction:r];
    }
}

-(void)requestFinishAction:(DWFlashFlowRequest *)request {
    ///标志完成任务
    if (request.finishAfterComplete) {
        [request finishOperation];
    }
    ///清除实际请求配置
    configRequestWithConfig(request, nil);
    ///释放引用
    [self removeRequestWithKey:request.requestID];
}

#pragma mark --- tool method - 发送 ---
-(void)sendNormalRequest:(DWFlashFlowRequest *)request progress:(ProgressCallback)progress completion:(RequestCompletion)completion {
    NSString * key = request.requestID;
    
    ///如果是连请求中的普通请求从链请求中获取
    if (request.chainRequest && request.chainParameterHandler) {
        __weak typeof(request)weakR = request;
        request.parameters = request.chainParameterHandler(weakR.chainRequest.responseInfo,weakR);
    }
    
    ///预处理实际请求配置
    [self configRequestWithGlobal:request];
    
    ///预处理参数
    ProcessorBlock preprocessing = request.configuration.actualPreprocessing;
    if (preprocessing) {
        request.configuration.actualParameters = preprocessing(request,request.configuration.actualParameters);
    }
    
    ///补充完成时回调动作，主要为添加重试逻辑、移除request对象并调用原始完成回调
    Completion ab = ^(BOOL success,id response,NSError * error) {
        DWFlashFlowRequest * r = [self requestForKey:key];
        if (r.retryCount > 0 && !success) {///如果有重试次数且为失败状态进入重试逻辑
            if (r.status == DWFlashFlowRequestCanceled) {///如果为取消状态则直接完成任务，不进行重试
                [self requestCompleteActionWithRequest:r success:success response:response error:error cacheResponse:NO needRequestThen:NO completion:completion];
            } else {///否则延时重试
                r.retryCount --;
                dispatch_block_t tempB = ^(){
                    [[self class] sendRequest:r progress:progress completion:completion];
                };
                [self performSelector:@selector(afterFire:) withObject:tempB afterDelay:r.retryDelayInterval];
            }
        } else {///不进入重试逻辑则直接完成任务
            ///此处回调则考虑缓存数据，且请求完成，无需继续请求
            [self requestCompleteActionWithRequest:r success:success response:response error:error cacheResponse:YES needRequestThen:NO completion:completion];
        }
    };
    
    ///根据任务是否为断点下载分配linker调用API
    if (request.status == DWFlashFlowRequestCanceled && request.resumeData) {
        [self.linker sendResumeDataRequest:request progress:progress completion:ab];
    } else {
        ///此处为准备工作完成，可以根据缓存策略决定是否发送请求
        [self sendNormalRequestConsiderCachePolicy:request progress:progress requestCompletion:completion retryCompletion:ab];
    }
    ///配置request为执行状态
    configRequestWithStatus(request, DWFlashFlowRequestExcuting);
    ///标志完成任务
    if (!request.finishAfterComplete) {
        [request finishOperation];
    }
}


/**
 根据缓存策略决定发送动作

 @param request 请求实例
 @param progress 过程回调
 @param requestCompletion 请求完成回调
 @param retryCompletion 添加重试机制的完成回调
 */
-(void)sendNormalRequestConsiderCachePolicy:(DWFlashFlowRequest *)request progress:(ProgressCallback)progress requestCompletion:(RequestCompletion)requestCompletion retryCompletion:(Completion)retryCompletion {
    ///此处为准备工作完成，可以根据缓存策略决定是否发送请求（当且仅当是普通请求且需要加载本地缓存时才读本地缓存）
    NSArray * localPolicy = @[@(DWFlashFlowCachePolicyLocalThenLoad),@(DWFlashFlowCachePolicyLocalElseLoad),@(DWFlashFlowCachePolicyLocalOnly)];
    if (request.requestType == DWFlashFlowRequestTypeNormal && [localPolicy containsObject:@(request.cachePolicy)]) {
        ///存在加载本地缓存需求
        ///先取出缓存数据
        id response = [self.cacheHandler cachedResponseForKey:request.configuration.actualURL];
        
        if (!response) {
            ///如果缓存数据为空，按缓存策略执行动作
            if (request.cachePolicy == DWFlashFlowCachePolicyLocalOnly) {
                ///如果为只读本地模式且本地则直接回调失败，不走重试逻辑，直接以不考虑缓存模式调用完成方法
                if (requestCompletion) {
                    [self requestCompleteActionWithRequest:request success:NO response:nil error:[NSError errorWithDomain:responseCacheErrorDomain code:CacheOnlyButNoCache userInfo:@{@"errMsg":@"Cache policy is DWFlashFlowCachePolicyLocalOnly but there's no cache found"}] cacheResponse:NO needRequestThen:NO completion:requestCompletion];
                }
            } else if (request.cachePolicy == DWFlashFlowCachePolicyLocalElseLoad) {
                ///如果为优先本地模式，则请求远端
                [self.linker sendRequest:request progress:progress completion:retryCompletion];
            } else if (request.cachePolicy == DWFlashFlowCachePolicyLocalThenLoad) {
                ///如果为本地远程均需模式，由于本地未命中缓存，所以直接请求远端
                [self.linker sendRequest:request progress:progress completion:retryCompletion];
            }
        } else {
            ///命中缓存，先调用请求结束动作（不考虑存储缓存），再根据缓存策略决定后续动作
            if (request.cachePolicy == DWFlashFlowCachePolicyLocalOnly) {
                ///如果为只读本地模式则无后续操作，请求结束动作（不继续请求）
                [self requestCompleteActionWithRequest:request success:YES response:response error:nil cacheResponse:NO needRequestThen:NO  completion:requestCompletion];
            } else if (request.cachePolicy == DWFlashFlowCachePolicyLocalElseLoad) {
                ///如果为优先本地模式，调用请求结束动作（不继续请求）
                [self requestCompleteActionWithRequest:request success:YES response:response error:nil cacheResponse:NO needRequestThen:NO completion:requestCompletion];
            } else if (request.cachePolicy == DWFlashFlowCachePolicyLocalThenLoad) {
                ///如果为本地远程均需模式，先调用请求结束动作（继续请求），请求远端
                [self requestCompleteActionWithRequest:request success:YES response:response error:nil cacheResponse:NO needRequestThen:YES  completion:requestCompletion];
                [self.linker sendRequest:request progress:progress completion:retryCompletion];
            }
        }
    } else {
        ///如果缓存策略中无需取本地缓存则直接请求
        [self.linker sendRequest:request progress:progress completion:retryCompletion];
    }
}

-(void)sendBatchRequest:(DWFlashFlowBatchRequest *)request progress:(ProgressCallback)progress completion:(RequestCompletion)completion {
    request.successStatus = YES;
    __weak typeof(request)weakR = request;
    
    NSBlockOperation * blockOP = [NSBlockOperation blockOperationWithBlock:^{
        NSMutableDictionary * tempRes = @{}.mutableCopy;
        NSMutableDictionary * tempErr = @{}.mutableCopy;
        [weakR.requests enumerateObjectsUsingBlock:^(__kindof DWFlashFlowAbstractRequest * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ///优先使用customID，提高可阅读性
            if (obj.response && (obj.requestID.length || obj.customID.length)) {
                [tempRes setValue:obj.response forKey:obj.customID.length?obj.customID:obj.requestID];
            }
            if (obj.error && (obj.requestID.length || obj.customID.length)) {
                [tempErr setValue:obj.error forKey:obj.customID.length?obj.customID:obj.requestID];
            }
            if (varIsKindofClass(obj,DWFlashFlowRequest)) {
                ((DWFlashFlowRequest *)obj).oriCompletion = nil;
            }
        }];
        ///赋值响应数据
        configRequestWithResponse(weakR, tempRes);
        if (tempErr.allKeys.count) {
            NSError * error = [NSError errorWithDomain:requestBatchFailErrorDomian code:BatchRequestFail userInfo:@{@"errMsg":@"One of the request in batchRequest get an error.",@"errInfo":tempErr}];
            ///赋值错误信息
            configRequestWithError(weakR, error);
        }
        
        ///更改请求状态
        configRequestWithStatus(weakR, DWFlashFlowRequestFinish);
        
        ///配置链请求响应
        if (weakR.chainRequest && weakR.responseInfoHandler) {
            weakR.responseInfoHandler(weakR.response, weakR.chainRequest.responseInfo);
        }
        
        if (completion) {
            ///回调请求结果
            completion(weakR.successStatus,weakR.response,weakR.error,weakR);
        }
        ///标志完成任务
        if (weakR.finishAfterComplete) {
            [weakR finishOperation];
        }
        ///释放引用
        [self removeRequestWithKey:weakR.requestID];
    }];
    
    [request.requests enumerateObjectsUsingBlock:^(__kindof DWFlashFlowAbstractRequest * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ///修改完成回调，保留每个请求状态
        RequestCompletion objCpl = obj.requestCompletion;
        RequestCompletion ab = ^(BOOL success,id response,NSError * error,DWFlashFlowAbstractRequest * r) {
            weakR.successStatus &= success;
            if (objCpl) {
                objCpl(success,response,error,r);
            }
        };
        obj.requestCompletion = ab;
        
        if (varIsKindofClass(obj,DWFlashFlowRequest)) {
            ((DWFlashFlowRequest *)obj).oriCompletion = objCpl;
        }
        
        ///添加依赖
        [blockOP addDependency:obj];
    }];
    
    ///执行
    [request.requestQueue addOperation:blockOP];
    [request.requestQueue addOperations:request.requests waitUntilFinished:NO];
    ///配置request为执行状态
    configRequestWithStatus(request, DWFlashFlowRequestExcuting);
}

-(void)sendChainRequest:(DWFlashFlowChainRequest *)request progress:(ProgressCallback)progress completion:(RequestCompletion)completion {
    request.successStatus = YES;
    __weak typeof(request)weakR = request;
    
    NSBlockOperation * blockOP = [NSBlockOperation blockOperationWithBlock:^{
        NSMutableDictionary * tempRes = @{}.mutableCopy;
        NSMutableDictionary * tempErr = @{}.mutableCopy;
        [weakR.requests enumerateObjectsUsingBlock:^(__kindof DWFlashFlowAbstractRequest * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ///优先使用customID，提高可阅读性
            if (obj.response && (obj.requestID.length || obj.customID.length)) {
                [tempRes setValue:obj.response forKey:obj.customID.length?obj.customID:obj.requestID];
            }
            if (obj.error && (obj.requestID.length || obj.customID.length)) {
                [tempErr setValue:obj.error forKey:obj.customID.length?obj.customID:obj.requestID];
            }
            if (varIsKindofClass(obj,DWFlashFlowRequest)) {
                ((DWFlashFlowRequest *)obj).oriCompletion = nil;
            }
        }];
        ///赋值响应数据
        configRequestWithResponse(request, tempRes);
        if (tempErr.allKeys.count) {
            NSError * error = [NSError errorWithDomain:requestChainFailErrorDomain code:ChainReuqestFail userInfo:@{@"errMsg":@"One of the request in chainRequest get an error.",@"errInfo":tempErr}];
            ///赋值错误数据
            configRequestWithError(weakR, error);
        }
        
        ///更改请求状态
        configRequestWithStatus(weakR, DWFlashFlowRequestFinish);
        
        ///配置链请求响应
        if (weakR.chainRequest && weakR.responseInfoHandler) {
            weakR.responseInfoHandler(weakR.response, weakR.chainRequest.responseInfo);
        }
        
        if (completion) {
            ///回调请求结果
            completion(weakR.successStatus,weakR.response,weakR.error,weakR);
        }
        
        ///标志完成任务
        if (weakR.finishAfterComplete) {
            [weakR finishOperation];
        }
        ///释放引用
        [self removeRequestWithKey:weakR.requestID];
    }];
    
    __block DWFlashFlowAbstractRequest * lastR = nil;
    [request.requests enumerateObjectsUsingBlock:^(__kindof DWFlashFlowAbstractRequest * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        ///配置ChainRequest
        obj.chainRequest = weakR;
        
        ///修改完成回调，保留每个请求状态
        RequestCompletion objCpl = obj.requestCompletion;
        RequestCompletion ab = ^(BOOL success,id response,NSError * error,DWFlashFlowAbstractRequest * r) {
            weakR.successStatus &= success;
            
            ///完成回调
            if (objCpl) {
                objCpl(success,response,error,r);
            }
            
            ///失败取消
            if (!success && weakR.cancelOnFailure) {
                [weakR cancel];
            }
        };
        obj.requestCompletion = ab;
        
        if (varIsKindofClass(obj,DWFlashFlowRequest)) {
            ((DWFlashFlowRequest *)obj).oriCompletion = objCpl;
        }
        
        ///添加依赖
        if (lastR) {
            [obj addDependency:lastR];
        }
        lastR = obj;
    }];
    
    [blockOP addDependency:lastR];
    
    ///执行
    [request.requestQueue addOperation:blockOP];
    [request.requestQueue addOperations:request.requests waitUntilFinished:NO];
    ///配置request为执行状态
    configRequestWithStatus(request, DWFlashFlowRequestExcuting);
}

#pragma mark --- tool method - 取消 ---
+(void)cancelNormalRequest:(DWFlashFlowRequest *)request {
    DWFlashFlowManager * m = [self manager];
    [m.linker cancelRequest:request];
}

+(void)cancelGroupRequest:(DWFlashFlowBatchRequest *)request {
    if (request.status == DWFlashFlowRequestExcuting || request.status == DWFlashFlowRequestSuspend) {
        [request.requests enumerateObjectsUsingBlock:^(__kindof DWFlashFlowAbstractRequest * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj cancel];
            if (obj.status == DWFlashFlowRequestCanceled && varIsKindofClass(obj,DWFlashFlowRequest)) {
                NSError * error = [NSError errorWithDomain:requestCanceledErrorDomain code:RequestCanceled userInfo:@{@"errMsg":@"The request has been canceled before start."}];
                configRequestWithError(obj, error);
                if (((DWFlashFlowRequest *)obj).oriCompletion) {
                    ((DWFlashFlowRequest *)obj).oriCompletion(NO, nil,obj.error , obj);
                }
            }
        }];
        configRequestWithStatus(request, DWFlashFlowRequestCanceled);
    }
}

+(void)cancelNormalRequest:(DWFlashFlowRequest *)request produceResumeData:(BOOL)produce completion:(void (^)(NSData *))completion {
    DWFlashFlowManager * m = [self manager];
    [m.linker cancelRequest:request produceResumeData:produce completion:completion];
}

+(void)cancelGroupRequest:(DWFlashFlowBatchRequest *)request produceResumeData:(BOOL)produce completion:(void (^)(NSData *))completion {
    if (!produce) {
        [self cancelGroupRequest:request];
    } else {
        [request.requests enumerateObjectsUsingBlock:^(__kindof DWFlashFlowAbstractRequest * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self cancelRequest:obj produceResumeData:produce completion:completion];
        }];
        configRequestWithStatus(request, DWFlashFlowRequestCanceled);
    }
}

#pragma mark --- tool method - 挂起 ---
+(void)suspendNormalRequest:(DWFlashFlowRequest *)request {
    DWFlashFlowManager * m = [self manager];
    [m.linker suspendRequest:request];
}

+(void)suspendGroupRequest:(DWFlashFlowBatchRequest *)request {
    if (request.status == DWFlashFlowRequestExcuting) {
        [request.requests enumerateObjectsUsingBlock:^(__kindof DWFlashFlowAbstractRequest * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self suspendRequest:obj];
        }];
        request.requestQueue.suspended = YES;
        configRequestWithStatus(request, DWFlashFlowRequestSuspend);
    }
}

#pragma mark --- tool method - 恢复 ---
+(void)resumeNormalRequest:(DWFlashFlowRequest *)request {
    DWFlashFlowManager * m = [self manager];
    [m.linker resumeRequest:request];
}

+(void)resumeGroupRequest:(DWFlashFlowBatchRequest *)request {
    if (request.status == DWFlashFlowRequestSuspend) {
        request.requestQueue.suspended = NO;
        [request.requests enumerateObjectsUsingBlock:^(__kindof DWFlashFlowAbstractRequest * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self resumeRequest:obj];
        }];
        configRequestWithStatus(request, DWFlashFlowRequestExcuting);
    }
}

#pragma mark --- tool func ---
static inline void configRequestWithStatus(DWFlashFlowAbstractRequest * r,DWFlashFlowRequestStatus status) {
    [r willChangeValueForKey:@"status"];
    [r setValue:@(status) forKey:@"_status"];
    [r didChangeValueForKey:@"status"];
}

static inline void configRequestWithResponse(DWFlashFlowAbstractRequest * r,id response) {
    [r setValue:response forKey:@"_response"];
}

static inline void configRequestWithConfig(DWFlashFlowRequest * r,DWFlashFlowRequestConfig * config) {
    [r setValue:config forKey:@"_configuration"];
}

static inline void configRequestWithError(DWFlashFlowAbstractRequest * r,NSError * error) {
    [r setValue:error forKey:@"_error"];
}

static inline void configChainRequestWithCurrentRequest(DWFlashFlowChainRequest * chain,DWFlashFlowRequest * request) {
    [chain setValue:request forKey:@"_currentRequest"];
}
static void enumerateRequest(DWFlashFlowManager * m,void(^enumerator)(NSString * key,DWFlashFlowRequest * request,BOOL * stop)) {
    if (!enumerator) {
        return;
    }
    NSArray * keys = [m.requestContainer.allKeys copy];
    if (!keys.count) {
        return;
    }
    BOOL stop = NO;
    for (NSString * key in keys) {
        DWFlashFlowRequest * r = [[m class] requestForID:key];
        enumerator(key,r,&stop);
        if (stop) {
            break;
        }
    }
}

#pragma mark --- singleton ---
+(instancetype)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mgr = [[self alloc] init];
        mgr.appVersion = -1;
        mgr.globalExpiredInterval = 0;
    });
    return mgr;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mgr = [super allocWithZone:zone];
    });
    return mgr;
}

-(id)copyWithZone:(struct _NSZone *)zone {
    return self;
}

-(id)mutableCopyWithZone:(struct _NSZone *)zone {
    return self;
}

#pragma mark --- Linker ---
+(Class)classForLinker {
    return NSClassFromString(@"DWFlashFlowAFNLinker");
}

-(DWFlashFlowBaseLinker *)linker {
    if (!_linker) {
        id temp = [[[self class] classForLinker] new];
        if (varIsKindofClass(temp, DWFlashFlowBaseLinker)) {
            _linker = temp;
        }
    }
    return _linker;
}

#pragma mark --- setter/getter ---
-(NSMutableDictionary *)requestContainer {
    if (!_requestContainer) {
        _requestContainer = @{}.mutableCopy;
    }
    return _requestContainer;
}

-(id<DWFlashFlowCacheProtocol>)cacheHandler {
    if (!_cacheHandler) {
        _cacheHandler = [DWFlashFlowAdvancedCache cacheHandler];
    }
    return _cacheHandler;
}

@end
