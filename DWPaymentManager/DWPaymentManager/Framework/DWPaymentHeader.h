//
//  DWPaymentHeader.h
//  AliSDKDemo
//
//  Created by Wicky on 2017/8/3.
//  Copyright © 2017年 Alipay.com. All rights reserved.
//

/**
 头文件
 */

#ifndef DWPaymentHeader_h
#define DWPaymentHeader_h

#import <UIKit/UIKit.h>
#import "DWPaymentConfig.h"

typedef NS_ENUM(NSUInteger, PayStatus) {///支付状态
    PayStatusSuccess,///支付成功
    PayStatusPending,///支付处理中（此种状态支付结果以异步返给server的结果为准）
    PayStatusCancel,///支付取消
    PayStatusFail,///支付失败
};

/**
 支付完成回调

 @param payType 支付类型
 @param status 支付状态
 @param code 状态码
 @param message 状态描述
 @param payResult 支付结果
 */
typedef void(^PaymentCompletion)(DWPaymentType payType,PayStatus status,NSString * code,NSString * message,id payResult);

#if DEBUG
#define DevEvn//开发环境标识符
#endif

#endif /* DWPaymentHeader_h */
