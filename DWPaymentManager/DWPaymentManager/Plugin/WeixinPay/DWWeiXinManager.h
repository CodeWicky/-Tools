//
//  DWWeiXinManager.h
//  AliSDKDemo
//
//  Created by Wicky on 2017/8/3.
//  Copyright © 2017年 Alipay.com. All rights reserved.
//

#import "DWAbstractManager.h"

@interface DWWeiXinManager : DWAbstractManager

/**
 当不使用提供的默认支付完成回调实现时，可考虑调用此API，也可自行实现。
 此API实现了微信支付的默认回调并提供非微信支付回调的回调接口
 
 @param url 回调url
 @param otherHandler 非微信支付的回调接口
 */
+(void)defaultCallBackWithUrl:(NSURL *)url otherHandler:(BOOL(^)())otherHandler;
@end
