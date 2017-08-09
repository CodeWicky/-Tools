//
//  DWAbstractManager.h
//  AliSDKDemo
//
//  Created by Wicky on 2017/8/3.
//  Copyright © 2017年 Alipay.com. All rights reserved.
//

/**
 支付抽象类。
 
 提供抽象方法，以便规范化支付流程。
 具体支付方式不同参数不同需在子类自行实现其他接口。
 */

#import "DWPaymentHeader.h"
@interface DWAbstractManager : NSObject

///支付完成回调
@property (nonatomic ,copy) PaymentCompletion paymentCompletion;

///以下均为抽象方法，子类需自行重写父类方法。

/**
 支付方法

 @param orderInfo 支付信息
 @param completion 支付成功回调
 */
+(void)payWithOrderInfo:(id)orderInfo completion:(PaymentCompletion)completion;

/**
 默认支付回调

 @param url 回调url
 */
+(void)defaultCallBackWithUrl:(NSURL *)url;


/**
 注册SDK
 */
+(void)registIfNeedWithConfig:(DWPaymentConfig *)config;

@end
