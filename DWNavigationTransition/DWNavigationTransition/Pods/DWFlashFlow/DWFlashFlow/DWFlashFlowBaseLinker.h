//
//  DWFlashFlowBaseLinker.h
//  DWFlashFlow
//
//  Created by Wicky on 2017/12/22.
//  Copyright © 2017年 Wicky. All rights reserved.
//

/**
    DWFlashFlowBaseLinker
    Linker负责组装request部分信息（task等）并对接三方请求框架完成请求。
 */

#import <Foundation/Foundation.h>
#import "DWFlashFlowRequest.h"

///完成回调
typedef void(^Completion)(BOOL success,id response,NSError * error);
@protocol DWFlashFlowRequestProtocol

///Request protocol for linker.
@required

-(void)sendRequest:(DWFlashFlowRequest *)request progress:(ProgressCallback)progress completion:(Completion)completion;

-(void)sendResumeDataRequest:(DWFlashFlowRequest *)request progress:(ProgressCallback)progress completion:(Completion)completion;

-(void)resumeRequest:(DWFlashFlowRequest *)request;

-(void)suspendRequest:(DWFlashFlowRequest *)request;

-(void)cancelRequest:(DWFlashFlowRequest *)request;

-(void)cancelRequest:(DWFlashFlowRequest *)request produceResumeData:(BOOL)produce completion:(void (^)(NSData *))completion;

@end

@interface DWFlashFlowBaseLinker : NSObject<DWFlashFlowRequestProtocol>

//Get actual request url from request.
///获取请求实际地址。
-(NSString *)requestURLFromRequest:(DWFlashFlowRequest *)r;

//Get actual request parameter from request.
///获取请求实际参数。
-(NSDictionary *)parametersFromRequest:(DWFlashFlowRequest *)r;

//Get actual request method from request.
///获取请求实际方式。
-(NSString *)methodFromRequest:(DWFlashFlowRequest *)r;

//Get actual request headers from request.
///获取请求实际请求头。
-(NSDictionary *)headersFromRequest:(DWFlashFlowRequest *)r;

//Get actual download request destination from request.
///获取下载请求实际保存地址。
-(DestinationCallback)destinationFromRequest:(DWFlashFlowRequest *)r;

//Get actual request preprocessor from request.
///获取请求实际预处理。
-(ProcessorBlock)preprocessorFromRequest:(DWFlashFlowRequest *)r;

//Get actual request reprocessor from request.
///获取请求实际二次处理。
-(ProcessorBlock)reprocessorFromRequest:(DWFlashFlowRequest *)r;

@end
