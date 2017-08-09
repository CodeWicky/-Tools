//
//  DWUnionPayManager.m
//  AliSDKDemo
//
//  Created by Wicky on 2017/8/3.
//  Copyright © 2017年 Alipay.com. All rights reserved.
//

#import "DWUnionPayManager.h"
#import "UPPaymentControl.h"

#ifdef DevEvn
#define UnionPayScheme @"UPPayDemo"
#define UnionPayMode @"01"
#else
#define UnionPayScheme @"UPPayDemo"
#define UnionPayMode @"00"
#endif

@interface DWUnionPayManager ()

@property (nonatomic ,weak) UIViewController * currentVC;

@end

static DWUnionPayManager * manager = nil;

@implementation DWUnionPayManager

+(void)payWithOrderInfo:(id)orderInfo currentVC:(UIViewController *)currentVC completion:(PaymentCompletion)completion {
    [DWUnionPayManager shareManager].currentVC = currentVC;
    [self payWithOrderInfo:orderInfo completion:completion];
}

+(void)payWithOrderInfo:(id)orderInfo completion:(PaymentCompletion)completion {
    [DWUnionPayManager shareManager].paymentCompletion = completion;
    [[UPPaymentControl defaultControl] startPay:orderInfo fromScheme:UnionPayScheme mode:UnionPayMode viewController:[DWUnionPayManager shareManager].currentVC];
}

+(void)defaultCallBackWithUrl:(NSURL *)url {
    [[UPPaymentControl defaultControl] handlePaymentResult:url completeBlock:^(NSString *code, NSDictionary *data) {
        PaymentCompletion completion = [DWUnionPayManager shareManager].paymentCompletion;
        if (completion) {
            PayStatus status = PayStatusFail;
            if ([code isEqualToString:@"success"]) {
                status = PayStatusSuccess;
            } else if ([code isEqualToString:@"cancel"]) {
                status = PayStatusCancel;
            }
            NSMutableDictionary * result = @{}.mutableCopy;
            if (data) {
                NSString * dataStr = data[@"data"];
                if (dataStr.length) {
                    [[dataStr componentsSeparatedByString:@"&"] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (obj.length && [obj containsString:@"="]) {
                            NSArray <NSString *>* arr = [obj componentsSeparatedByString:@"="];
                            if (arr.firstObject.length) {
                                [result setValue:arr.lastObject.length?arr.lastObject:@"" forKey:arr.firstObject];
                            }
                        }
                    }];
                }
                NSString * sign = data[@"sign"];
                [result setValue:sign?:@"" forKey:@"sign"];
            }
            completion(DWPaymentTypeUnionPay, status,nil,nil,result);
        }
    }];
}

+(void)registIfNeedWithConfig:(DWPaymentConfig *)config {
    ///Nothing To Do;
}

+(instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DWUnionPayManager alloc] init];
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
