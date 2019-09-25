//
//  DWCrashCollector.h
//  DWLogger
//
//  Created by Wicky on 2017/10/12.
//  Copyright © 2017年 Wicky. All rights reserved.
//

/**
 DWCrashCollector
 崩溃收集类
 
 可以收集异常与信号两类崩溃并保存日志。
 此类仅提供两个类型方法，无需实例化，实例化无效。
 
 version 1.0.0
 提供崩溃捕捉
 提供捕捉后崩溃处理等接口
 
 version 1.0.1
 添加默认保存目录
 添加崩溃堆栈信息
 */

#import <Foundation/Foundation.h>

typedef void(^ExceptionHandlerType)(NSException * exc);

@interface DWCrashCollector : NSObject<UIAlertViewDelegate>

///自定义崩溃如何处理
+(void)configToCollectCrashWithSavePath:(NSString *)savePath handler:(ExceptionHandlerType)handler;

///已默认行为（保存崩溃日志至指定路径）处理崩溃，当savePath为空时默认为Cache/DWLogger文件夹
+(void)collectCrashInDefaultWithSavePath:(NSString *)savePath;

///收集crash的默认行为
+(ExceptionHandlerType)defaultHandler;

///设置标识为name的crash为处理过的crash
+(void)setCrashHandledWithName:(NSString *)name;

///未被处理过的crash
+(NSMutableArray *)unHandledCrashes;

///处理未处理的crash
+(void)handleUnHandledCrashWithHandler:(void(^)(NSMutableArray <NSString *>* unHandledCrashes,NSString * lastCrash,NSString * lastCrashReason))handler;

@end
