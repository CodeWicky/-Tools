//
//  DWFlashFlowAbstractRequest.h
//  DWFlashFlow
//
//  Created by Wicky on 2018/1/29.
//  Copyright © 2018年 Wicky. All rights reserved.
//

/**
    DWFlashFlowAbstractRequest
    请求对象抽象类
    主要改写NSOperation的状态并添加公用属性。
 */
#import <Foundation/Foundation.h>

@protocol DWFlashFlowRequestOperationProtocol

@required
-(void)start;
-(void)cancel;
@end

@class DWFlashFlowAbstractRequest;

typedef NS_ENUM(NSUInteger, DWFlashFlowRequestStatus) {///请求所处状态
    DWFlashFlowRequestReady,
    DWFlashFlowRequestExcuting,
    DWFlashFlowRequestSuspend,
    DWFlashFlowRequestCanceled,
    DWFlashFlowRequestFinish
};

///完成回调
typedef void(^RequestCompletion)(BOOL success,id response,NSError * error,DWFlashFlowAbstractRequest * request);

@interface DWFlashFlowAbstractRequest : NSOperation<DWFlashFlowRequestOperationProtocol>

///The unique ID for each request.
///每个请求对象的唯一标识。
@property (nonatomic ,copy ,readonly) NSString * requestID;

//The custom ID for each request which is set by developer.It will use customID as key first in batchRequest and chainRequest.
///由开发者设置的标识。批量请求和链请求中会优先使用customID作为合并key。
@property (nonatomic ,copy) NSString * customID;

//The current status for request.KVO is supported.
///请求的当前状态。支持KVO。
@property (nonatomic ,assign ,readonly) DWFlashFlowRequestStatus status;

//Indicate whether the operation will be finish after complete.Default by true.
///标识是否请求完成后才将任务标志为结束状态，默认为真。
@property (nonatomic ,assign) BOOL finishAfterComplete;

//Callback for request compleltion.Use together with -start.
///请求完成的回调。配合 -start 方法使用。
@property (nonatomic ,copy) RequestCompletion requestCompletion;

//The response for request.It only set by framework.
///请求的响应，只读，由框架进行赋值。
@property (nonatomic ,strong ,readonly) id response;

//The error for request.It only set by framework.
///请求的错误信息，只读，由框架进行赋值
@property (nonatomic ,strong ,readonly) NSError * error;

/**
 Indicates this operation has been finished.
 
 标志着任务结束。
 
 @disc 框架内部调用，开发者无需手动调用
 */
-(void)finishOperation;

/**
 *  任务开始或取消
 */
-(void)start NS_REQUIRES_SUPER;
-(void)cancel NS_REQUIRES_SUPER;

@end
