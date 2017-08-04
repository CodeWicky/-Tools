//
//  DWUnionPayManager.h
//  AliSDKDemo
//
//  Created by Wicky on 2017/8/3.
//  Copyright © 2017年 Alipay.com. All rights reserved.
//

#import "DWAbstractManager.h"

@interface DWUnionPayManager : DWAbstractManager

/**
 提供银联支付入口

 @param orderInfo 支付信息
 @param currentVC 当前控制器
 @param completion 支付完成回调
 */
+(void)payWithOrderInfo:(id)orderInfo currentVC:(UIViewController *)currentVC completion:(PaymentCompletion)completion;
@end
