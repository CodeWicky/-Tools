//
//  DWPaymentManager.h
//  AliSDKDemo
//
//  Created by Wicky on 2017/7/18.
//  Copyright © 2017年 Alipay.com. All rights reserved.
//


/**
 DWPaymentManager 
 支付工具类
 
 统一支付入口，统一支付回调。代码入侵性小。
 
 使用方法：
 需要支持哪种支付方式拖入哪种支付方式对应管理者即可。eg：
 需要支持支付宝，无需微信支付及广银联，则你工程中需要的文件为：
 DWAbstractManager、DWPaymentHeader、DWPaymentManager、DWAlipayManager即可。
 使用时仅引入DWPaymentManager头文件即可。
 
 version 1.0.0
 提供三种支付方式：微信、支付宝、广银联
 统一支付入口及支付完成回调
 模块化结构，代码入侵性更小，通用性更强
 提供正式、测试环境标志符 DevEvn 。根据情况做不同配置即可。
 
 version 1.0.1
 注册方法改造，提供注册模型类
 支付完成回调统一，整合现有支付方式支付结果
 */

#import "DWPaymentHeader.h"
@interface DWPaymentManager : NSObject

#pragma mark --- 管理类注册 ---
/**
 以下API为注册几个支付渠道的通用配置，写在-application:didFinishLaunchingWithOptions:中即可
 */


/**
 注册支付管理类

 @param configs 各支付渠道注册所需配置模型
 
 注：
 当前状态下，仅微信支付需要注册AppID
 */
+(void)registPaymentManagerWithConfigs:(NSArray <DWPaymentConfig *>*)configs;

#pragma mark --- 支付入口 ---
/**
 以下为支付入口，所有支付方式统一调支付API
 */

/**
 以orderInfo进行支付

 @param orderInfo 订单字符串
 @param payType 支付类型
 @param currentVC 当前控制器
 @param completion 支付完成同步回调
 
 注：
 目前状态下，支付宝及银联传入后台返回的orderString为一个字符串。
 微信支付为一个请求对象，由于目前没有联调微信所以方案未定。参考方案为后台返回一个字典，转化为微信所需对象后传入SDK。
 */
+(void)payWithOrderInfo:(id)orderInfo payType:(DWPaymentType)payType currentVC:(UIViewController *)currentVC completion:(PaymentCompletion)completion;

#pragma mark --- 支付回调入口 ---
/**
 以下两个API决定支付SDK是否能够打开APP进行回调，在-application:openURL:options:（iOS9.0及以后）和
 -application:openURL:sourceApplication:annotation:（iOS9.0以前）中直接返回即可。
 非支付系回调可在otherHandler中另行判断做返回。
 */

/**
 支付完成回调

 @param url 回调Url
 @param handler 预设支付方式对应回调
 @param otherHandler 未预设Url回调
 @return 返回是否允许回调
 */
+(BOOL)paymentCallBackWithUrl:(NSURL *)url paymentHandler:(BOOL(^)(DWPaymentType type))handler otherHanlder:(BOOL(^)())otherHandler;

/**
 提供默认行为的支付完成回调

 @param url 回调Url
 @param otherHandler 未预设Url回调
 @return 返回是否允许回调
 */
+(BOOL)paymentCallBackDefaultHandlerWithUrl:(NSURL *)url otherHanlder:(BOOL (^)())otherHandler;
@end
