//
//  DWAlipayManager.m
//  AliSDKDemo
//
//  Created by Wicky on 2017/8/3.
//  Copyright © 2017年 Alipay.com. All rights reserved.
//

#import "DWAlipayManager.h"
#import <AlipaySDK/AlipaySDK.h>


static DWAlipayManager * manager = nil;
@implementation DWAlipayManager

+(void)payWithOrderInfo:(id)orderInfo completion:(PaymentCompletion)completion {
    [DWAlipayManager shareManager].paymentCompletion = completion;
    NSString * appScheme = @"AlipayDemo";
    // NOTE: 调用支付结果开始支付
    [[AlipaySDK defaultService] payOrder:orderInfo fromScheme:appScheme callback:^(NSDictionary *resultDic) {
        PaymentCompletion completion = [DWAlipayManager shareManager].paymentCompletion;
        if (completion) {
            completion(DWPaymentTypeAlipay,resultDic);
        }
    }];
}

+(void)defaultCallBackWithUrl:(NSURL *)url {
    // 支付跳转支付宝钱包进行支付，处理支付结果
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
        NSLog(@"result = %@",resultDic);
    }];
    
    // 授权跳转支付宝钱包进行支付，处理支付结果
    [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
        NSLog(@"result = %@",resultDic);
        // 解析 auth code
        NSString *result = resultDic[@"result"];
        NSString *authCode = nil;
        if (result.length>0) {
            NSArray *resultArr = [result componentsSeparatedByString:@"&"];
            for (NSString *subResult in resultArr) {
                if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                    authCode = [subResult substringFromIndex:10];
                    break;
                }
            }
        }
        NSLog(@"授权结果 authCode = %@", authCode?:@"");
    }];
}

+(void)registIfNeed {
    ///Nothing To Do.
}

+(instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DWAlipayManager alloc] init];
    });
    return manager;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [super allocWithZone:zone];
    });
    return manager;
}

@end
