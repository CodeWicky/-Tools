//
//  DWFlashFlowBatchRequest.h
//  DWFlashFlow
//
//  Created by Wicky on 2018/1/29.
//  Copyright © 2018年 Wicky. All rights reserved.
//

/**
    DWFlashFlowBatchRequest
    请求组
 
    Packing up a group of DWFlashFlowAbstractRequest.Each request executes in parallel.
    将一组DWFlashFlowAbstractRequest包装为一个批量请求。每个请求间并行执行。注：系统限制，同时最多执行6个任务。
 */
#import "DWFlashFlowAbstractRequest.h"
@interface DWFlashFlowBatchRequest : DWFlashFlowAbstractRequest

//Array of batch requests.
///批量请求数组。
@property (nonatomic ,strong) NSArray <__kindof DWFlashFlowAbstractRequest *>* requests;

//The operationQueue for every request Operation.Default by a concurrent Queue and maxConcurrentOperationCount is 6.
///所有请求任务执行的队列。默认为一个最大并发数为6的并行队列。
@property (nonatomic ,strong) NSOperationQueue * requestQueue;

/**
 生成批量请求对象

 @param requests 批量请求数组
 @return 批量请求对象
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
