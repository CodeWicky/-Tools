//
//  DWFlashFlowChainRequest.h
//  DWFlashFlow
//
//  Created by Wicky on 2018/2/1.
//  Copyright © 2018年 Wicky. All rights reserved.
//

/**
 DWFlashFlowChainRequest
 请求链
 
 Packing up a group of DWFlashFlowAbstractRequest.Each request executes serially.
 将一组DWFlashFlowAbstractRequest包装为一个请求链。每个请求间串行执行。
 */

#import "DWFlashFlowAbstractRequest.h"
#import "DWFlashFlowRequest.h"

@interface DWFlashFlowChainRequest : DWFlashFlowAbstractRequest

//Array of batch requests.
///批量请求数组。
@property (nonatomic ,strong) NSArray <__kindof DWFlashFlowAbstractRequest *>* requests;

//Indicates whether cancel all request when one of them fails.Default by YES.
///标识当请求链中的某一请求失败后是否取消整个请求链。默认为YES。
@property (nonatomic ,assign) BOOL cancelOnFailure;

//The current request of chain.
///请求链当前执行的请求。
@property (nonatomic ,weak ,readonly) DWFlashFlowAbstractRequest * currentRequest;

//The operationQueue for every request Operation.Default by a concurrent Queue and maxConcurrentOperationCount is 1.
///所有请求任务执行的队列。默认为一个最大并发数为1的并行队列。
@property (nonatomic ,strong) NSOperationQueue * requestQueue;

/**
 生成请求链对象
 
 @param requests 请求数组
 @return 请求链对象
 */
-(instancetype)initWithRequests:(NSArray <__kindof DWFlashFlowAbstractRequest *>*)requests;

/**
 Start a request with completion.
 
 开启一个任务，并提供完成回调。
 
 @param completion 完成回调
 
 @disc 调用 -start 方法时会使用request对象的requestProgress和requestCompletion作为回调。-startWithCompletion: 系方法会将非空的参数赋值给request对象，并作为回调。
 */
-(void)startWithCompletion:(RequestCompletion)completion;
-(void)start;

//Resume a request who is in DWFlashFlowRequestSuspend status.
///恢复一个处于DWFlashFlowRequestSuspend状态的request请求对象。
-(void)resume;

//Suspend a request who is in DWFlashFlowRequestExcuting status.
///暂停一个处于DWFlashFlowRequestExcuting状态的request请求对象。
-(void)suspend;

//Cancel a request who is in DWFlashFlowRequestExcuting or DWFlashFlowRequestSuspend status.
///取消一个处于DWFlashFlowRequestExcuting或DWFlashFlowRequestSuspend状态的请求对象。
-(void)cancel;

/**
 Cancel the download requests in batch request who is in DWFlashFlowRequestExcuting or DWFlashFlowRequestSuspend status and produce the download resumeData.
 
 取消一个处于DWFlashFlowRequestExcuting或DWFlashFlowRequestSuspend状态的批量请求对象中的所有下载任务并生成下载信息。
 
 @param completionHandler 取消完成回调
 
 @disc 通常用于断点下载
 */
-(void)cancelByProducingResumeData:(void (^)(NSData * resumeData))completionHandler;

@end

typedef NSDictionary *(^ChainParameter)(NSDictionary * responseInfo,DWFlashFlowRequest * r);
typedef void (^ReponseInfo)(__kindof id response,__kindof NSMutableDictionary * responseInfo);
@interface DWFlashFlowRequest (ChainParameter)

//Fetch parameter from chainRequest.Before sending DWFlashFlowRequest,chainParameterHandler will be called in which you can get data from chainRequest.The return value of chainParameterHandler will be treated as parameter of DWFlashFlowRequest.
///链请求参数获取。发送链请求中的DWFlashFlowRequest类请求前回调此回调，可以访问链请求对象维护的数据组。返回值将作为链请求中的DWFlashFlowRequest类请求的参数。
@property (nonatomic ,copy) ChainParameter chainParameterHandler;

@end

@interface DWFlashFlowAbstractRequest (ChainParameter)

//Save response into chainRequest.ResponseInfoHandler will be called after the request in chainRequest finish.You can set the response or part of it into responseInfo.
///链请求参数保存。链请求中的任何请求完成时将回调此回调，可以将响应数据或其一部分赋值给responseInfo。
@property (nonatomic ,copy) ReponseInfo responseInfoHandler;

@end
