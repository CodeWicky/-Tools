//
//  DWFlashFlow.h
//  DWFlashFlow
//
//  Created by Wicky on 2018/3/26.
//  Copyright © 2018年 Wicky. All rights reserved.
//

/**
 DWFlashFlow
 数据请求框架
 
 提供Operation行为的请求任务，以及批量请求和链请求的支持。
 默认提供AFN作为核心请求组件，可通过重写DWFlashFlowManager中+classForLinker属性改变核心请求组件。
 提供数据请求的全局配置，但请求对象非单例对象。
 
 version 1.0.0
 Operation行为实现
 普通、批量、链请求实现
 提供核心请求组件更换接口
 提供全局配置管理类
 
 version 1.0.1
 添加缓存机制，修复请求链中cancelOnFailure初始值赋值错误问题
 
 version 1.0.2
 添加customID，可以由开发者自行设置。方便在批量请求和链请求中区分数据来源
 
 version 1.0.2.1
 修复释放request引用时的判空处理，防止无效移除导致的崩溃
 
 version 1.0.2.2
 修复URL拼接时与预期结果不同的问题，修改baseLinker中当request为nil时返回的处理block为nil
 添加预处理相关注释，阐明预处理回调具体行为作用及行为规范
 
 version 1.0.2.3
 修复取消任务时，被取消的任务不触发回调的bug
 
 version 1.0.2.4
 任务完成时，移除临时回调
 
 version 1.0.2.5
 修复调用 -startWithCompletion系方法导致的重复请求。
 
 */

#ifndef DWFlashFlow_h
#define DWFlashFlow_h

#import "DWFlashFlowManager.h"
#import "DWFlashFlowBaseLinker.h"
#import "DWFlashFlowAFNLinker.h"
#import "DWFlashFlowAbstractRequest.h"
#import "DWFlashFlowRequest.h"
#import "DWFlashFlowBatchRequest.h"
#import "DWFlashFlowChainRequest.h"


#endif /* DWFlashFlow_h */
