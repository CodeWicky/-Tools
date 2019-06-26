//
//  DWNetworkAFNManager.h
//  DWNetwork
//
//  Created by Wicky on 2017/11/16.
//  Copyright © 2017年 Wicky. All rights reserved.
//


/**
 DWNetworkAFNManager
 
 基于AFN3.0 封装的请求类。
 解决AFN的内存泄漏且不采用单例模式（考虑到每个请求的请求头应该具有差异性，故不考虑单例模式）
 解决PNG上传痛点（直接以文件形式加载PNG文件至NSData后上传至服务端，图片无法读取）
 
 version 1.0.0
 提供非单例模式，解决PNG上传
 
 versin 1.0.1
 去除超时属性，改为使用requestSerializer中的timeoutInterval控制，保持与AFN行为一致
 */

#import <AFNetworking/AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN


///上传数据模型
@interface DWNetworkUploadFile : NSObject

///与服务器协定上传字段名
@property (nonatomic ,copy ,nullable) NSString * name;

///上传数据元数据模型
@property (nonatomic ,strong ,nullable) NSData * fileData;

///上传数据服务器存储对应name
@property (nonatomic ,copy ,nullable) NSString * fileName;

///文件类型
@property (nonatomic ,copy ,nullable) NSString * mimeType;

///文件URL
@property (nonatomic ,copy ,nullable) NSURL * fileURL;

///以文件路径及上传字段名生成上传模型。自动填充mimeType字段，选择填充fileData
-(instancetype)initWithFilePath:(nonnull NSString *)filePath name:(nonnull NSString *)name loadData:(BOOL)load;

///以文件路径及上传字段名生成上传模型。自动填充mimeType字段
-(instancetype)initWithFilePath:(nonnull NSString *)filePath name:(nonnull NSString *)name;

///以data及上传字段名生成上传模型。自动填充mimeType字段
-(instancetype)initWithData:(nonnull NSData *)data name:(nonnull NSString *)name fileName:(nullable NSString *)fileName;

@end

@interface DWNetworkAFNManager : AFURLSessionManager

@property (nonatomic ,strong) AFHTTPRequestSerializer * requestSerializer;

@property (nonatomic ,copy) NSString * userName;

@property (nonatomic ,copy) NSString * password;


/**
 基本请求，请求与响应均采用JSON形式

 @param URLString 请求地址
 @param parameters 参数
 @param success 成功回调
 @param failure 失败回到
 */
+(void)GET:(nonnull NSString *)URLString
         parameter:(nullable id)parameters
           success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
           failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

+(void)POST:(nonnull NSString *)URLString
         parameters:(nullable id)parameters
            success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
            failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

+(void)DOWNLOAD:(nonnull NSString *)URLString
     parameters:(nullable id)parameters
       savePath:(nullable NSString *)savePath
       progress:(nullable void (^)(NSProgress * _Nonnull downloadProgress)) downloadProgressBlock
        success:(nullable void (^)(NSURLSessionDownloadTask *task, NSURLResponse * _Nullable response,NSURL * _Nullable filePath))success
        failure:(nullable void (^)(NSURLSessionDownloadTask * _Nullable task, NSError *error))failure;

+(void)UPLOAD:(nonnull NSString *)URLString
   parameters:(nullable id)parameters
  uploadFiles:(NSArray<DWNetworkUploadFile *> *)files
     progress:(void (^)(NSProgress * _Nonnull uploadProgress))uploadProgressBlock
      success:(void (^)(NSURLSessionDataTask * task, id responseObject))success
      failure:(void (^)(NSURLSessionDataTask * task, NSError * error))failure;


/**
 生成实例的方法

 @return 实例
 */
+(instancetype)manager;

/**
 数据请求

 @param URLString 请求地址
 @param method 请求方式
 @param parameters 请求参数
 @param success 成功回调
 @param failure 失败回调
 @return 数据请求task对象
 */
-(nullable NSURLSessionDataTask *)request:(nonnull NSString *)URLString
                                   method:(nullable NSString *)method
                               parameters:(nullable id)parameters
                                  success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                  failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;


/**
 数据下载

 @param URLString 下载地址
 @param method 请求方式
 @param parameters 请求参数
 @param destination 文件保存地址回调
 @param downloadProgressBlock 下载进度回调
 @param success 现在成功回调
 @param failure 现在失败回调
 @return 数据下载task对象
 */
-(nullable NSURLSessionDownloadTask *)downLoad:(nonnull NSString *)URLString
                                        method:(nullable NSString *)method
                                    parameters:(nullable id)parameters
                                   destination:(nullable NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                      progress:(nullable void (^)(NSProgress * _Nonnull downloadProgress)) downloadProgressBlock
                                       success:(nullable void (^)(NSURLSessionDownloadTask *task, NSURLResponse * _Nullable response,NSURL * _Nullable filePath))success
                                       failure:(nullable void (^)(NSURLSessionDownloadTask * _Nullable task, NSError *error))failure;



/**
 根据保存的被中断的下载信息恢复下载

 @param resumeData 下载信息
 @param destination 文件保存地址回调
 @param downloadProgressBlock 下载进度回调
 @param success 现在成功回调
 @param failure 下载失败回调
 @return 数据下载task对象
 */
-(nullable NSURLSessionDownloadTask *)downloadWithResumeData:(NSData *)resumeData
                                                 destination:(NSURL * _Nonnull (^)(NSURL * _Nonnull, NSURLResponse * _Nonnull))destination
                                                    progress:(void (^)(NSProgress * _Nonnull downloadProgress))downloadProgressBlock
                                                     success:(nullable void (^)(NSURLSessionDownloadTask *task, NSURLResponse * _Nullable response,NSURL * _Nullable filePath))success
                                                     failure:(nullable void (^)(NSURLSessionDownloadTask * _Nullable task, NSError *error))failure;

/**
 将数据封装在Body中上传数据，仅支持单文件上传

 @param URLString 上传地址
 @param method 上传方式（仅POST,PUT有效。传入无效方式默认为POST）
 @param file 上传文件
 @param uploadProgressBlock 上传进度
 @param success 成功回调
 @param failure 失败回调
 @return 数据上传task
 
 此种方式将数据置于Body中，故无法传参
 file中fileData与fileURL不同时为空，否则无法加载数据。均存在有效值时fileData优先。
 */
-(nullable NSURLSessionUploadTask *)upload:(nonnull NSString *)URLString
                                    method:(nullable NSString *)method
                                      file:(nonnull DWNetworkUploadFile *)file
                                  progress:(void (^)(NSProgress * _Nonnull uploadProgress))uploadProgressBlock
                                   success:(void (^)(NSURLSessionDataTask * task, id responseObject))success
                                   failure:(void (^)(NSURLSessionDataTask * task, NSError * error))failure;


/**
 将数据封装在Form-Data中上传数据，支持多文件上传

 @param URLString 上传地址
 @param method 上传方式（仅POST,PUT有效。传入无效方式默认为POST）
 @param files 上传文件数组
 @param parameters 参数
 @param uploadProgressBlock 上传进度回调
 @param success 成功回调
 @param failure 失败回调
 @return 数据上传task
 
 uploadFiles中的file对象name为必传属性，为上传时与server协定字段。
 file中fileData与fileURL不同时为空，否则无法加载数据。均存在有效值时fileData优先。
 */
-(NSURLSessionUploadTask *)upload:(NSString *)URLString
                           method:(NSString *)method
                      uploadFiles:(NSArray<DWNetworkUploadFile *> *)files
                       parameters:(nullable id)parameters
                         progress:(void (^)(NSProgress * _Nonnull uploadProgress))uploadProgressBlock
                          success:(void (^)(NSURLSessionDataTask * task, id responseObject))success
                          failure:(void (^)(NSURLSessionDataTask * task, NSError * error))failure;

@end



NS_ASSUME_NONNULL_END
