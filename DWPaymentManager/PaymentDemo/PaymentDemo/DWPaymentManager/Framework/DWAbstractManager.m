//
//  DWAbstractManager.m
//  AliSDKDemo
//
//  Created by Wicky on 2017/8/3.
//  Copyright © 2017年 Alipay.com. All rights reserved.
//

#import "DWAbstractManager.h"

#define AbstractMethodNotImplemented() \
@throw [NSException exceptionWithName:NSInternalInconsistencyException \
                               reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)] \
                             userInfo:nil]

@implementation DWAbstractManager

+(void)payWithOrderInfo:(id)orderInfo completion:(PaymentCompletion)completion {
    AbstractMethodNotImplemented();
}

+(void)defaultCallBackWithUrl:(NSURL *)url {
    AbstractMethodNotImplemented();
}

+(void)registIfNeedWithConfig:(DWPaymentConfig *)config {
    AbstractMethodNotImplemented();
}

#pragma mark --- singlton ---

-(id)copyWithZone:(NSZone *)zone {
    return self;
}

-(id)mutableCopyWithZone:(NSZone *)zone {
    return self;
}
@end
