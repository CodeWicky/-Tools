//
//  DWFlashFlowAFNLinker.m
//  DWFlashFlow
//
//  Created by Wicky on 2017/12/4.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "DWFlashFlowAFNLinker.h"
#import <DWNetworkAFNManager/DWNetworkAFNManager.h>


@interface DWFlashFlowRequest (Private)

-(void)privateCancel;

@end

@implementation DWFlashFlowRequest (Private)

-(void)privateCancel {
    [super cancel];
}

@end

@implementation DWFlashFlowAFNLinker

#pragma mark --- interface method ---
-(void)sendRequest:(DWFlashFlowRequest *)request progress:(ProgressCallback)progress completion:(Completion)completion {
    DWNetworkAFNManager * manager = managerFromRequest(request);
    manager.requestSerializer = requestSerializerFromType(request.requestSerializerType);
    manager.requestSerializer.timeoutInterval = request.timeoutInterval;
    manager.responseSerializer = responseSerializerFromType(request.responseSerializerType);
    NSString * urlString = request.configuration.actualURL;
    NSString * method = [self methodFromRequest:request];
    NSDictionary * parameters = request.configuration.actualParameters;
    NSDictionary * headers = request.configuration.actualHeaders;
    configRequestSerializer(manager.requestSerializer, headers);
    switch (request.requestType) {
        case DWFlashFlowRequestTypeUpload:
        {
            NSURLSessionUploadTask * t = [self uploadWithManager:manager urlString:urlString method:method parameters:parameters uploadFiles:request.files progress:progress completion:completion];
            configRequestWithTask(request, t);
        }
            break;
        case DWFlashFlowRequestTypeDownload:
        {
            DestinationCallback d = [self destinationFromRequest:request];
            NSURLSessionDownloadTask * t = [self downloadWithManager:manager urlString:urlString method:method parameters:parameters destination:d progress:progress completion:completion];
            configRequestWithTask(request, t);
        }
            break;
        default:
        {
            NSURLSessionDataTask * t = [self requestWithManager:manager urlString:urlString method:method parameters:parameters completion:completion];
            configRequestWithTask(request, t);
        }
            break;
    }
}

-(void)sendResumeDataRequest:(DWFlashFlowRequest *)request progress:(ProgressCallback)progress completion:(Completion)completion {
    if (request.requestType != DWFlashFlowRequestTypeDownload) {
        return;
    }
    if (!request.resumeData) {
        return;
    }
    if (request.status != DWFlashFlowRequestCanceled) {
        return;
    }
    DWNetworkAFNManager * m = managerFromRequest(request);
    DestinationCallback d = [self destinationFromRequest:request];
    NSURLSessionDownloadTask * t = [self downloadWithManager:m resumeData:request.resumeData destination:d progress:progress completion:completion];
    configRequestWithTask(request, t);
}

-(void)resumeRequest:(DWFlashFlowRequest *)request {
    if (request.status == DWFlashFlowRequestSuspend) {
        [request.task resume];
        configRequestWithStatus(request, DWFlashFlowRequestExcuting);
    }
}

-(void)suspendRequest:(DWFlashFlowRequest *)request {
    if (request.status == DWFlashFlowRequestExcuting) {
        [request.task suspend];
        configRequestWithStatus(request, DWFlashFlowRequestSuspend);
    }
}

-(void)cancelRequest:(DWFlashFlowRequest *)request {
    if (request.status == DWFlashFlowRequestExcuting || request.status == DWFlashFlowRequestSuspend) {
        if (!request.isCancelled) {
            [request privateCancel];
        }
        [request.task cancel];
    }
    if (request.status != DWFlashFlowRequestFinish) {
        configRequestWithStatus(request, DWFlashFlowRequestCanceled);
    }
}

-(void)cancelRequest:(DWFlashFlowRequest *)request produceResumeData:(BOOL)produce completion:(void (^)(NSData *))completion {
    ///如果不是下载任务则无法产生resumeData
    if (request.requestType != DWFlashFlowRequestTypeDownload) {
        produce = NO;
    }
    
    ///只有进行中或挂起的任务可以取消
    if (request.status == DWFlashFlowRequestExcuting || request.status == DWFlashFlowRequestSuspend) {
        if (!produce) {///如果不生成resumeData直接调用普通取消方法
            [self cancelRequest:request];
            if (completion) {
                completion(nil);
            }
        } else {///否则生成resumeData
            NSURLSessionDownloadTask * task = request.task;
            [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                configRequestWithStatus(request, DWFlashFlowRequestCanceled);
                configRequestWithResumeData(request, resumeData);
                if (completion) {
                    completion(resumeData);
                }
            }];
        }
    }
}

#pragma mark --- tool method ---
-(NSURLSessionDataTask *)requestWithManager:(DWNetworkAFNManager *)m urlString:(NSString *)urlString method:(NSString *)method parameters:(id)parameters completion:(Completion)completion {
    return [m request:urlString method:method parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (completion) {
            completion(YES,responseObject,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) {
            completion(NO,nil,error);
        }
    }];
}

-(NSURLSessionDownloadTask *)downloadWithManager:(DWNetworkAFNManager *)m urlString:(NSString *)urlString method:(NSString *)method parameters:(id)parameters destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination progress:(void (^)(NSProgress * downloadProgress))downloadProgressBlock completion:(Completion)completion {
    return [m downLoad:urlString method:method parameters:parameters destination:destination progress:downloadProgressBlock success:^(NSURLSessionDownloadTask * _Nonnull task, NSURLResponse * _Nullable response, NSURL * _Nullable filePath) {
        if (completion) {
            completion(YES,filePath,nil);
        }
    } failure:^(NSURLSessionDownloadTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) {
            completion(NO,nil,error);
        }
    }];
}

-(NSURLSessionDownloadTask *)downloadWithManager:(DWNetworkAFNManager *)m resumeData:(NSData *)resumeData destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination progress:(void (^)(NSProgress * downloadProgress))downloadProgressBlock completion:(Completion)completion {
    return [m downloadWithResumeData:resumeData destination:destination progress:downloadProgressBlock success:^(NSURLSessionDownloadTask * _Nonnull task, NSURLResponse * _Nullable response, NSURL * _Nullable filePath) {
        if (completion) {
            completion(YES,filePath,nil);
        }
    } failure:^(NSURLSessionDownloadTask * _Nullable task, NSError * _Nonnull error) {
        if (completion) {
            completion(NO,nil,error);
        }
    }];
}
-(NSURLSessionUploadTask *)uploadWithManager:(DWNetworkAFNManager *)m urlString:(NSString *)urlString method:(NSString *)method parameters:(id)parameters uploadFiles:(NSArray<DWNetworkUploadFile *> *)files progress:(ProgressCallback)uploadProgressBlock completion:(Completion)completion {
    return [m upload:urlString method:method uploadFiles:files parameters:parameters progress:uploadProgressBlock success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if (completion) {
            completion(YES,responseObject,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        if (completion) {
            completion(NO,nil,error);
        }
    }];
}

#pragma mark --- tool func ---

static inline __kindof AFHTTPRequestSerializer * requestSerializerFromType(DWFlashFlowRequestSerializerType type) {
    switch (type) {
        case DWFlashFlowRequestSerializerTypeJSON:
        {
            return [AFJSONRequestSerializer serializer];
        }
        case DWFlashFlowRequestSerializerTypePlist:
        {
            return [AFPropertyListRequestSerializer serializer];
        }
        default:
            return [AFHTTPRequestSerializer serializer];
    }
}

static inline __kindof AFHTTPResponseSerializer * responseSerializerFromType(DWFlashFlowResponseSerializerType type) {
    switch (type) {
        case DWFlashFlowResponseSerializerTypeJSON:
        {
            return [AFJSONResponseSerializer serializer];
        }
        case DWFlashFlowResponseSerializerTypePlist:
        {
            return [AFPropertyListResponseSerializer serializer];
        }
        case DWFlashFlowResponseSerializerTypeXML:
        {
            return [AFXMLParserResponseSerializer serializer];
        }
        default:
            return [AFHTTPResponseSerializer serializer];
    }
}

static inline void configRequestSerializer(__kindof AFHTTPRequestSerializer * serializer,NSDictionary * headers) {
    if (!headers.allKeys.count) {
        return ;
    } else {
        [headers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [serializer setValue:obj forHTTPHeaderField:key];
        }];
    }
}

static inline void configRequestWithTask(DWFlashFlowRequest * request,__kindof NSURLSessionTask * task) {
    [request setValue:task forKey:@"_task"];
}

static inline void configRequestWithStatus(DWFlashFlowAbstractRequest * r,DWFlashFlowRequestStatus status) {
    [r willChangeValueForKey:@"status"];
    [r setValue:@(status) forKey:@"_status"];
    [r didChangeValueForKey:@"status"];
}

static inline void configRequestWithResumeData(DWFlashFlowRequest * r,NSData * resumeData) {
    [r setValue:resumeData forKey:@"_resumeData"];
}

static inline DWNetworkAFNManager * managerFromRequest(DWFlashFlowRequest * r) {
    DWNetworkAFNManager * m = [DWNetworkAFNManager manager];
    m.userName = r.userName;
    m.password = r.password;
    return m;
}

@end
