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

typedef NS_ENUM(NSUInteger, DWPaymentType) {///支付方式枚举
    DWPaymentTypeUndefined,///未指定支付方式
    DWPaymentTypeAlipay,///支付宝
    DWPaymentTypeWeiXin,///微信
    DWPaymentTypeUnionPay,///银联
};

typedef void(^PaymentCompletion)(DWPaymentType payType,id payResult);

#if DEBUG
#define DevEvn//开发环境标识符
#endif

#endif /* DWPaymentHeader_h */
