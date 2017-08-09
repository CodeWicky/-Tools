//
//  DWPaymentManager.m
//  AliSDKDemo
//
//  Created by Wicky on 2017/7/18.
//  Copyright © 2017年 Alipay.com. All rights reserved.
//

#import "DWPaymentManager.h"
#if __has_include("DWAlipayManager.h")
#import "DWAlipayManager.h"
#endif
#if __has_include("DWUnionPayManager.h")
#import "DWUnionPayManager.h"
#endif
#if __has_include("DWWeiXinManager.h")
#import "DWWeiXinManager.h"
#endif

@interface DWPaymentManager ()

///支付完成回调
@property (nonatomic ,copy) PaymentCompletion paymentCompletion;

@end

@implementation DWPaymentManager

#pragma mark --- interface method ---

+(void)registPaymentManagerWithConfigs:(NSArray<DWPaymentConfig *> *)configs {
    [configs enumerateObjectsUsingBlock:^(DWPaymentConfig * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        switch (obj.payType) {
            case DWPaymentTypeAlipay:
            {
#if __has_include("DWAlipayManager.h")
                [DWAlipayManager registIfNeedWithConfig:obj];
#endif
                break;
            }
            case DWPaymentTypeUnionPay:
            {
#if __has_include("DWUnionPayManager.h")
                [DWUnionPayManager registIfNeedWithConfig:obj];
#endif
                break;
            }
            case DWPaymentTypeWeiXin:
            {
#if __has_include("DWWeiXinManager.h")
                [DWWeiXinManager registIfNeedWithConfig:obj];
#endif
                break;
            }
            default:
                break;
        }
    }];
}

+(void)payWithOrderInfo:(id)orderInfo payType:(DWPaymentType)payType currentVC:(UIViewController *)currentVC completion:(PaymentCompletion)completion {
    BOOL invalid = NO;
    if ([orderInfo isKindOfClass:[NSString class]] && [orderInfo length] == 0) {
        invalid = YES;
    } else if (!orderInfo) {
        invalid = YES;
    }
    if (invalid) {///参数错误处理
        NSString * errorString = @"";
        if (!orderInfo) {
            errorString = [errorString stringByAppendingString:@"\nInvalid orderInfo which is nil or length equal to 0."];
        }
        if (payType == DWPaymentTypeUndefined) {
            errorString = [errorString stringByAppendingString:@"\nUndefined PaymentType."];
        }
        NSLog(@"Payment canceled.Invalid parameter:%@",errorString);
        return;
    }
    switch (payType) {
        case DWPaymentTypeAlipay:
        {
#if __has_include("DWAlipayManager.h")
            [DWAlipayManager payWithOrderInfo:orderInfo completion:completion];
#else
            NSLog(@"You hasn't import DWAlipayManager.h");
#endif
            break;
        }
        case DWPaymentTypeWeiXin:
        {
#if __has_include("DWWeiXinManager.h")
            [DWWeiXinManager payWithOrderInfo:orderInfo completion:completion];
#else
             NSLog(@"You hasn't import DWWeiXinManager.h");
#endif
            break;
        }
        case DWPaymentTypeUnionPay:
        {
#if __has_include("DWUnionPayManager.h")
            [DWUnionPayManager payWithOrderInfo:orderInfo currentVC:currentVC completion:completion];
#else
            NSLog(@"You hasn't import DWUnionPayManager.h");
#endif
            break;
        }
        default:
            break;
    }
}

+(BOOL)paymentCallBackWithUrl:(NSURL *)url paymentHandler:(BOOL (^)(DWPaymentType))handler otherHanlder:(BOOL(^)())otherHandler {
    if (!handler && !otherHandler) {
        return NO;
    }
    if (!handler && otherHandler) {
        return otherHandler();
    }
    NSString * host = url.host;
    if ([host isEqualToString:@"safepay"]) {
        return handler(DWPaymentTypeAlipay);
    } else if ([host isEqualToString:@"pay"]) {
        return handler(DWPaymentTypeWeiXin);
    } else if ([host isEqualToString:@"uppayresult"]) {
        return handler(DWPaymentTypeUnionPay);
    } else if (otherHandler) {
        return otherHandler();
    } else {
        return NO;
    }
}

+(BOOL)paymentCallBackDefaultHandlerWithUrl:(NSURL *)url otherHanlder:(BOOL (^)())otherHandler {
    return [self paymentCallBackWithUrl:url paymentHandler:^BOOL(DWPaymentType type) {
        switch (type) {
            case DWPaymentTypeAlipay:
            {
#if __has_include("DWAlipayManager.h")
                [DWAlipayManager defaultCallBackWithUrl:url];
#else
                NSLog(@"You hasn't import DWAlipayManager.h");
#endif
                return YES;
            }
            case DWPaymentTypeWeiXin:
            {
#if __has_include("DWWeiXinManager.h")
                [DWWeiXinManager defaultCallBackWithUrl:url otherHandler:otherHandler];
#else
                NSLog(@"You hasn't import DWWeiXinManager.h");
#endif
                return YES;
            }
            case DWPaymentTypeUnionPay:
            {
#if __has_include("DWUnionPayManager.h")
                [DWUnionPayManager defaultCallBackWithUrl:url];
#else
                NSLog(@"You hasn't import DWUnionPayManager.h");
#endif
                return YES;
            }
            default:
            {
                if (otherHandler) {
                    return otherHandler();
                }
                return NO;
            }
        }
    } otherHanlder:otherHandler];
}

@end
