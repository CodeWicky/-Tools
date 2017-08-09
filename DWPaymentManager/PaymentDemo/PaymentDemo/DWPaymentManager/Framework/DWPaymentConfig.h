//
//  DWPaymentConfig.h
//  PaymentDemo
//
//  Created by Wicky on 2017/8/8.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DWPaymentType) {///支付方式枚举
    DWPaymentTypeUndefined,///未指定支付方式
    DWPaymentTypeAlipay,///支付宝
    DWPaymentTypeWeiXin,///微信
    DWPaymentTypeUnionPay,///银联
};

@interface DWPaymentConfig : NSObject

///支付类型
@property (nonatomic ,assign) DWPaymentType payType;

///支付SDK所对应的AppID
@property (nonatomic ,copy) NSString * AppID;

@end
