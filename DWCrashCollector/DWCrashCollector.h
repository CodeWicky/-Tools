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
 */

#import <Foundation/Foundation.h>

@interface DWCrashCollector : NSObject<UIAlertViewDelegate>

///自定义崩溃如何处理
+(void)configToCollectCrashWithSavePath:(NSString *)savePath handler:(void(^)(NSException * exception))handler;

///已默认行为（保存崩溃日志至指定路径）处理崩溃
+(void)CollectCrashInDefaultWithSavePath:(NSString *)savePath;

@end
