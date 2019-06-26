//
//  DWFlashFlowRequest.h
//  DWFlashFlow
//
//  Created by Wicky on 2017/12/4.
//  Copyright © 2017年 Wicky. All rights reserved.
//

/**
    DWFlashFlowRequest
    请求对象
 
    Send a request as an operation.
    Actually it just a data model class,the related information will pass to DWFlashFlowManager.
 
    请求对象，将任务作为请求对象进行操作。
    实际为数据模型类，相关管理配置信息等将交由DWFlashFlowManager处理。
 */

#import "DWFlashFlowAbstractRequest.h"


typedef NS_ENUM(NSUInteger, DWFlashFlowMethod) {///请求方式
    DWFlashFlowMethodGET = 0,
    DWFlashFlowMethodPOST,
    DWFlashFlowMethodPUT,
    DWFlashFlowMethodPATCH,
    DWFlashFlowMethodHEAD,
    DWFlashFlowMethodDELETE,
};

typedef NS_ENUM(NSUInteger, DWFlashFlowRequestType) {///请求类型
    DWFlashFlowRequestTypeNormal,
    DWFlashFlowRequestTypeDownload,
    DWFlashFlowRequestTypeUpload,
};

typedef NS_ENUM(NSUInteger, DWFlashFlowRequestSerializerType) {///请求解析方式
    DWFlashFlowRequestSerializerTypeJSON,
    DWFlashFlowRequestSerializerTypePlist,
    DWFlashFlowRequestSerializerTypeRaw,
};

typedef NS_ENUM(NSUInteger, DWFlashFlowResponseSerializerType) {///响应解析方式
    DWFlashFlowResponseSerializerTypeJSON,
    DWFlashFlowResponseSerializerTypePlist,
    DWFlashFlowResponseSerializerTypeXML,
    DWFlashFlowResponseSerializerTypeRaw,
};

typedef NS_ENUM(NSUInteger, DWFlashFlowCachePolicy) {///缓存策略
    DWFlashFlowCachePolicyLoadOnly,///仅加载远端数据并且不缓存响应数据
    DWFlashFlowCachePolicyLoadOnlyAndSave,///仅加载远端数据并且缓存响应数据
    DWFlashFlowCachePolicyLocalThenLoad,///首先加载本地数据同时请求远端数据，请求成功后缓存响应数据并再次调用完成回调
    DWFlashFlowCachePolicyLocalElseLoad,///优先加载本地数据，若本地数据不存在则请求远端数据，若成功则缓存数据并回调
    DWFlashFlowCachePolicyLocalOnly,///只加载本地数据
};

@class DWFlashFlowRequest;
///下载文件存储路径回调
typedef NSURL * (^DestinationCallback)(NSURL *targetPath, NSURLResponse *response);

///进度回调
typedef void (^ProgressCallback)(NSProgress * progress);

///处理回调
typedef id(^ProcessorBlock)(DWFlashFlowRequest * request,id data);

@class DWFlashFlowRequestConfig;
@interface DWFlashFlowRequest : DWFlashFlowAbstractRequest<NSCopying>

///ApiURL,who will append to baseURL and make the actual URL to request.
///eg.: baseURL = @"http://www.baidu.com/";
///apiURL = @"getInfo";
///the actual url to request is : @"http://www.baidu.com/getInfo";
///If the fullURL is available,fullURL will be the actual URL.
///eg.: baseURL = @"http://www.baidu.com/";
///apiURL = @"getInfo";
///fullURL = @"http://www.google.com";
///the actual url to request is : @"http://www.google.com";

///apiURL 是用来拼接在baseURL之后作为实际请求地址的url。
///如：baseURL = @"http://www.baidu.com/";
///apiURL = @"getInfo";
///实际请求地址即为 : @"http://www.baidu.com/getInfo";
///如果设置了fullURL则将忽略apiURL及baseURL而使用fullURL作为实际请求地址。
///如: baseURL = @"http://www.baidu.com/";
///apiURL = @"getInfo";
///fullURL = @"http://www.google.com";
///实际请求地址即为 : @"http://www.google.com";
@property (nonatomic ,copy) NSString * apiURL;
@property (nonatomic ,copy) NSString * fullURL;

//Request Method,GET by default.
///请求方式，默认为GET请求
@property (nonatomic ,assign) DWFlashFlowMethod method;

//Request type indicate whether the request is about to download/upload or neither of them.DWFlashFlowRequestTypeNormal bt default.
///标识请求任务类型是 普通/上传/下载 中的对应类型，默认是普通类型
@property (nonatomic ,assign) DWFlashFlowRequestType requestType;

//SerializerType for request/response.JSON by default.
///请求/响应 的解析方式，默认为JSON。
@property (nonatomic ,assign) DWFlashFlowRequestSerializerType requestSerializerType;
@property (nonatomic ,assign) DWFlashFlowResponseSerializerType responseSerializerType;

//The parameters of the request.Parameters will combine with globalParameters when useGlobalParameters is true and useGlobalParameters is true by default.
///请求参数，如果useGlobalParameters为真时，且设置过全局参数， parameter请求参数将与全局参数组合作为实际请求参数。useGlobalParameters默认为真
@property (nonatomic ,strong) NSDictionary * parameters;
@property (nonatomic ,assign) BOOL useGlobalParameters;

//The headers of the request.Headers will combine with globalHeaders when useGlobalHeaders is true and useGlobalHeaders is true by default.
///请求头，如果useGlobalHeaders为真时，且设置过全局请求头， headers请求头将与全局请求头组合作为实际请求头。useGlobalHeaders默认为真
@property (nonatomic ,strong) NSDictionary * headers;
@property (nonatomic ,assign) BOOL useGlobalHeaders;

//Flag indicates whether the request parameter need to be encrypt and decrypt by manager.
///标识请求的参数和响应是否需要加解密。
@property (nonatomic ,assign) BOOL needEncrypt;

//The max time limit for request.Beyond this the request will be timeout.
///请求的超时时间。
@property (nonatomic ,assign) NSTimeInterval timeoutInterval;

//UserName and password to login.
///登录所需用户名及密码。
@property (nonatomic ,copy) NSString * userName;
@property (nonatomic ,copy) NSString * password;

//Retry performance when request has failed.RetryCount is 0 and retryDelayInterval is 2s by default.
///请求失败后重试行为。重试次数默认为0，重试发起请求间隔默认为2秒。
@property (nonatomic ,assign) NSUInteger retryCount;
@property (nonatomic ,assign) NSTimeInterval retryDelayInterval;

//The action before make a request.If preprocessorBeforeRequest is nil,but useGlobalPreprocessor is true and globalPreprocessor not nil will use globalPreprocessor instead.And useGlobalPreprocessor is true by default.
///发生请求之前的预处理，在请求之前的回调。如果未设置preprocessorBeforeRequest，但是useGlobalPreprocessor为真且设置过全局预处理globalPreprocessor将会使用全局预处理。useGlobalPreprocessor默认为真。
///注：1.系统对参数的实际预处理由 Linker 中 -preprocessorFromRequest: 方法决定。
///   2.原则上开发者重写Linker中 -preprocessorFromRequest: 方法时应保证若preprocessorBeforeRequest与全局回调同时存在，先调用preprocessorBeforeRequest，再调用全局回调。
///   3.预处理回调发生在请求发送之前。
///   4.预处理回调中可以对请求做最后处理，可以修改除预处理回调和二次处理回调之外的所有属性（事实上我并不建议你在预处理中修改除了请求参数外的其他属性）
///   5.预处理回调有两个入参，第一个为request对象，第二个为将要请求的请求参数。回调有一个返回值，将作为最终请求的实际参数
///   6.预处理回调中若想修改headers或者URL时，请处理request.configuration中的对应值（此处修改configuration.actualParameters无效，该属性将在回调结束后被赋值为回调的返回值）
@property (nonatomic ,copy) ProcessorBlock preprocessorBeforeRequest;
@property (nonatomic ,assign) BOOL useGlobalPreprocessor;

//The action after recieve response.If reprocessingAfterResponse is nil,but useGlobalReprocessing is true and globalReprocessing not nil will use globalReprocessing instead.And useGlobalReprocessing is true by default.
///收到响应后立即出发的回调，对响应做二次处理。如果未设置reprocessingAfterResponse，但是useGlobalReprocessing为真且设置过全局二次处理globalReprocessing将会使用全局二次处理。useGlobalReprocessing默认为真。
///注：1.系统对响应数据的实际二次处理由 Linker 中 -reprocessorFromRequest: 方法决定。
///   2.原则上开发者重写Linker中 -reprocessorFromRequest: 方法时应保证若reprocessingAfterResponse与全局回调同时存在，先调用全局回调，再调用reprocessingAfterResponse。
///   3.二次处理回调发生在响应之后，请求 成功/失败 回调发生之前。
@property (nonatomic ,copy) ProcessorBlock reprocessingAfterResponse;
@property (nonatomic ,assign) BOOL useGlobalReprocessing;

//The NSURLSessionTask who send the request.It only set by framework.
///发送请求的NSURLSessionTask对象，只读，由框架进行赋值。
@property (nonatomic ,strong ,readonly) __kindof NSURLSessionTask * task;

//Callbacks for request which indicate progress.Use together with -start.If you use The method -startWithCompletion: or -startWithProgress:completion: will ignore requestProgress and requestCompletion and use the parameters you pass.
///展示进度或完成的回调。他们应该配合 -start 方法使用。如果使用 -startWithCompletion: 或 -startWithProgress:completion:这两个方法，那么这两个属性将被忽略，转而使用你所传入的参数。
@property (nonatomic ,copy) ProgressCallback requestProgress;

//Indicate the savePath for each download request.If destination is available will use it,otherwise use downloadSavePath.
///指定下载路径。如果destination可用则使用回调，否则下载地址将有downloadSavePath指定。
@property (nonatomic ,copy) DestinationCallback destination;
@property (nonatomic ,copy) NSString * downloadSavePath;

//ResumeData for download request produced by calling -cancelByProducingResumeData: and set by completion.It could be used for broken-point continuingly-transferring.
///resumeData是下载任务调用-cancelByProducingResumeData:完成时被设置的属性，其可以供断点下载使用。
@property (nonatomic ,strong ,readonly) NSData * resumeData;

//Files to be uploaded.The type of each file is not a File.It may be base on your 3rd netFramework.eg.:DWNetworkUploadFile in DWNetworkAFNManager.
///将要上传的文件数组。这里需要说明的是并不是文件系统意义的文件，而是取决于你实际的网络请求三方所需要的文件封装。例如，在DWNetworkAFNManager中所需上传的文件类封装是DWNetworkUploadFile.
@property (nonatomic ,strong) NSArray <id>* files;

//The actual config for request which is combined with global.
///request对象经过全局参数组合过得实际参数
@property (nonatomic ,strong ,readonly) DWFlashFlowRequestConfig * configuration;

//Cache policy for request,DWFlashFlowCachePolicyLoadOnly by default.
///响应数据缓存缓存策略，默认为DWFlashFlowCachePolicyLoadOnly模式。
@property (nonatomic ,assign) DWFlashFlowCachePolicy cachePolicy;

//Expired time interval for response cache.
///响应缓存过期时间
@property (nonatomic ,assign) NSTimeInterval expiredInterval;

/**
 Start a request with progressCallback and completion.
 
 开启一个任务，并提供进度回调及完成回调。
 
 @param progress 进度回调
 @param completion 完成回调
 
 @disc 1.-startWithCompletion: 时默认无进度回调
 
       2.调用 -start 方法时会使用request对象的requestProgress和requestCompletion作为回调。另外两个 -start... 系方法会将非空的参数赋值给request对象，并作为回调。
 */
-(void)startWithProgress:(ProgressCallback)progress completion:(RequestCompletion)completion;
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
 Cancel a download request who is in DWFlashFlowRequestExcuting or DWFlashFlowRequestSuspend status and produce the download resumeData.
 
 取消一个处于DWFlashFlowRequestExcuting或DWFlashFlowRequestSuspend状态的下载对象并生成下载信息。

 @param completionHandler 取消完成回调
 
 @disc 通常用于断点下载
 */
-(void)cancelByProducingResumeData:(void (^)(NSData * resumeData))completionHandler;


/**
 Create a request with another request.
 
 以一个请求对象生成另一个请求对象。

 @param request 想要复制的request对象
 @return 新的request对象
 
 @disc 效果等同于 -copy 。
 */
+(instancetype)requestWithRequest:(DWFlashFlowRequest *)request;


/**
 Create a request with resumeData.
 
 以下载信息创建请求对象

 @param resumeData 中断的现在任务信息
 @return 请求对象
 
 @disc 配合 -cancelByProducingResumeData: 方法实现断点下载。生成request对象后请务必设置 destination 或 downloadSavePath。
 */
+(instancetype)requestWithResumeData:(NSData *)resumeData;

@end

/**
    DWFlashFlowRequestConfig
    请求配置类
 
    The related configuration of the request is passed to the Liker after configuring by the Manager,then the Linker will send the request according to it.The configuration will be set to nil by framework after the request is completed.
    由Manager组装请求的相关配置后，将配置传给Liker，Linker根据配置发送请求，请求完成后再由框架置为nil。
 */
@interface DWFlashFlowRequestConfig : NSObject

//Actual request URL
///实际请求的URL
@property (nonatomic ,copy) NSString * actualURL;

//Actual request Parameters
///实际请求的参数
@property (nonatomic ,strong) NSDictionary * actualParameters;

//Actual request Headers
///实际请求的请求头
@property (nonatomic ,strong) NSDictionary * actualHeaders;

//Actual request preprocessing
///实际请求的预处理回调
@property (nonatomic ,copy) ProcessorBlock actualPreprocessing;

//Actual request reprocessor
///实际请求的二次处理回调
@property (nonatomic ,copy) ProcessorBlock actualReprocessor;

@end

