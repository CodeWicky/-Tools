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

+(void)registIfNeed {
    //AppID 及 Des 根据项目自行配置
    [WXApi registerApp:@"wx7e1a39693cb1a1f1"];
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
        PayResp * response = (PayResp *)resp;
        //支付返回结果，实际支付结果需要去微信服务器端查询
        NSMutableDictionary * result = @{}.mutableCopy;
        if (response.errStr) {
            [result setValue:response.errStr forKey:@"data"];
        }
        if (response.errCode) {
            [result setValue:@(response.errCode) forKey:@"code"];
        }
        if (response.returnKey) {
            [result setValue:response.returnKey forKey:@"returnKey"];
        }
        PaymentCompletion completion = [DWWeiXinManager shareManager].paymentCompletion;
        if (completion) {
            completion(DWPaymentTypeWeiXin,result);
        }
    } else if (self.otherHandler) {
        self.otherHandler();
    }
}

@end
