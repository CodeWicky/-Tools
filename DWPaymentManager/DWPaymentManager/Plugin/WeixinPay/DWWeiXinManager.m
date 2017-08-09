//
//  DWWeiXinManager.m
//  AliSDKDemo
//
//  Created by Wicky on 2017/8/3.
//  Copyright © 2017年 Alipay.com. All rights reserved.
//

#import "DWWeiXinManager.h"
#import "WXApi.h"
@interface DWWeiXinManager ()<WXApiDelegate>

@property (nonatomic ,copy) BOOL (^otherHandler)();

@end

static DWWeiXinManager * manager = nil;
@implementation DWWeiXinManager

+(void)payWithOrderInfo:(id)orderInfo completion:(PaymentCompletion)completion {
    [DWWeiXinManager shareManager].paymentCompletion = completion;
    [WXApi sendReq:orderInfo];
}

+(void)defaultCallBackWithUrl:(NSURL *)url otherHandler:(BOOL(^)())otherHandler {
    [DWWeiXinManager shareManager].otherHandler = otherHandler;
    [self defaultCallBackWithUrl:url];
}

+(void)defaultCallBackWithUrl:(NSURL *)url {
    [WXApi handleOpenURL:url delegate:[DWWeiXinManager shareManager]];
}

+(void)registIfNeedWithConfig:(DWPaymentConfig *)config {
    if (config.payType != DWPaymentTypeWeiXin || config.AppID.length == 0) {
        return;
    }
    //AppID 及 Des 根据项目自行配置
    [WXApi registerApp:config.AppID];
}

+(instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DWWeiXinManager alloc] init];
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

#pragma mark --- 微信支付处理结果回调 ---
#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp {
    if([resp isKindOfClass:[PayResp class]]){
        PaymentCompletion completion = [DWWeiXinManager shareManager].paymentCompletion;
        if (completion) {
            PayResp * response = (PayResp *)resp;
            PayStatus status = PayStatusFail;
            NSString * payCode = [NSString stringWithFormat:@"%d",response.errCode];
            NSMutableDictionary * result = @{}.mutableCopy;
            switch (response.errCode) {
                case WXSuccess:
                    status = PayStatusSuccess;
                    break;
                case WXErrCodeUserCancel:
                    status = PayStatusCancel;
                default:
                    break;
            }
            if (response.returnKey) {
                [result setValue:response.returnKey forKey:@"returnKey"];
            }
            [result setValue:@(response.type) forKey:@"type"];
            completion(DWPaymentTypeWeiXin,status,payCode,response.errStr,result);
        }
    } else if (self.otherHandler) {
        self.otherHandler();
    }
}

@end
