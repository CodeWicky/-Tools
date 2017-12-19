//
//  DWCrashCollector.m
//  DWLogger
//
//  Created by Wicky on 2017/10/12.
//  Copyright © 2017年 Wicky. All rights reserved.
//
#import <UIKit/UIKit.h>

#import "DWCrashCollector.h"
#import "UIDevice+DWDeviceUtils.h"
#import "DWFileManager.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>

volatile int32_t UncaughtExceptionCount = 0;

const int32_t UncaughtExceptionMaximum = 10;

static NSString * sP = nil;

static ExceptionHandlerType expHandler = nil;

static dispatch_queue_t serialQ = nil;

@implementation DWCrashCollector

+(void)collectCrashInDefaultWithSavePath:(NSString *)savePath {
    if (!savePath.length) {
        savePath = [DWFileManager dw_DocumentsDir];
    }
    [self configToCollectCrashWithSavePath:savePath handler:[self defaultHandler]];
}

+(void)configToCollectCrashWithSavePath:(NSString *)savePath handler:(ExceptionHandlerType)handler {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        serialQ = dispatch_queue_create("com.crashCollector.serialQueue", DISPATCH_QUEUE_SERIAL);
        uninstallCollector();
        installCollector(savePath,handler);
    });
}

+(ExceptionHandlerType)defaultHandler {
    __weak typeof(self)weakSelf = self;
    ExceptionHandlerType handler = ^(NSException * exception) {
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMdd-HHmmss"];
        NSDate * date = [NSDate date];
        NSString * folderName = [formatter stringFromDate:date];
        [DWFileManager dw_CreateDirectoryAtPath:[NSString stringWithFormat:@"%@/Crash",sP]];
        [weakSelf configLastCrashWithName:folderName reason:exception.reason];
        NSString * path = [sP stringByAppendingPathComponent:[NSString stringWithFormat:@"Crash/%@",folderName]];
        NSString * crashFilePath = [path stringByAppendingPathComponent:@"CrashLog.crash"];
        [DWFileManager dw_CreateFileAtPath:crashFilePath];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString * timeStr = [formatter stringFromDate:date];
        NSString * crashStr = @"";
        crashStr = [crashStr stringByAppendingString:[NSString stringWithFormat:@"Project Name: %@\n",[UIDevice dw_ProjectDisplayName]]];
        crashStr = [crashStr stringByAppendingString:[NSString stringWithFormat:@"Project Bundle ID: %@\n",[UIDevice dw_ProjectBundleId]]];
        crashStr = [crashStr stringByAppendingString:[NSString stringWithFormat:@"Project Version: %@\n",[UIDevice dw_ProjectVersion]]];
        crashStr = [crashStr stringByAppendingString:[NSString stringWithFormat:@"Project Build: %@\n",[UIDevice dw_ProjectBuildNo]]];
        crashStr = [crashStr stringByAppendingString:[NSString stringWithFormat:@"Crash Time: %@\n",timeStr]];
        crashStr = [crashStr stringByAppendingString:[NSString stringWithFormat:@"Device Model: %@\n",[UIDevice dw_DeviceDetailModel]]];
        crashStr = [crashStr stringByAppendingString:[NSString stringWithFormat:@"Device System: %@\n",[UIDevice dw_DeviceSystemVersion]]];
        crashStr = [crashStr stringByAppendingString:[NSString stringWithFormat:@"Device CPU Arch: %@\n",[UIDevice dw_DeviceCPUType]]];
        crashStr = [crashStr stringByAppendingString:[NSString stringWithFormat:@"Crash Detail:\n%@\n%@.\n%@",exception.name,exception.reason,[NSThread callStackSymbols]]];
        writeDataString2File(crashStr, crashFilePath);
        saveCrashImage2Path(path);
        printf("\nCrash Log Path Is %s\n\n",crashFilePath.UTF8String);
        
        uninstallCollector();
        if ([[exception name] isEqual:@"DWCrashCollectorSignalErrorName"]) {
            kill(getpid(), [[[exception userInfo] objectForKey:@"DWCrashCollectorSignalKey"] intValue]);
        } else {
            [exception raise];
        }
    };
    return handler;
}

+(void)configLastCrashWithName:(NSString *)name reason:(NSString *)reason {
    if (!name.length) {
        return;
    }
    NSString * path = crashConfigPath();
    NSMutableDictionary * config = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    if (!config) {
        config = @{}.mutableCopy;
        config[@"UnHandleCrash"] = @[].mutableCopy;
    }
    [config setValue:name forKey:@"LastCrash"];
    [config setValue:reason forKey:@"LastCrashReason"];
    NSMutableArray * unHandleCrash = config[@"UnHandleCrash"];
    if (![unHandleCrash containsObject:name]) {
        [unHandleCrash addObject:name];
    }
    [config writeToFile:path atomically:YES];
}

+(void)setCrashHandledWithName:(NSString *)name {
    if (!name.length) {
        return;
    }
    dispatch_async(serialQ, ^{
        NSString * path = crashConfigPath();
        NSMutableDictionary * config = [NSMutableDictionary dictionaryWithContentsOfFile:path];
        if (!config) {
            return;
        }
        NSMutableArray * unHandleCrash = config[@"UnHandleCrash"];
        if ([unHandleCrash containsObject:name]) {
            [unHandleCrash removeObject:name];
        }
        if ([config[@"LastCrash"] isEqualToString:name]) {
            config[@"LastCrash"] = @"";
            config[@"LastCrashReason"] = @"";
        }
        [config writeToFile:path atomically:YES];
    });
}

+(NSMutableArray *)unHandledCrashes {
    NSString * path = crashConfigPath();
    NSMutableDictionary * config = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    if (!config) {
        return nil;
    }
    return config[@"UnHandleCrash"];
}


+(void)handleUnHandledCrashWithHandler:(void(^)(NSMutableArray <NSString *>*,NSString *,NSString *))handler {
    if (!handler) {
        return;
    }
    NSString * path = crashConfigPath();
    NSMutableDictionary * config = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    if (!config) {
        return;
    }
    NSMutableArray * unHandleCrash = config[@"UnHandleCrash"];
    if (!unHandleCrash.count) {
        return;
    }
    handler(unHandleCrash,config[@"LastCrash"],config[@"LastCrashReason"]);
}

#pragma mark --- exception Hanlder ---
static void exceptionHandler(NSException *exception)
{
    if (expHandler) {
        expHandler(exception);
    }
}

static void signalCollector(int signal)
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
#pragma clang diagnostic pop
    if (exceptionCount > UncaughtExceptionMaximum) {
        return;
    }
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:signal] forKey:@"DWCrashCollectorSignalKey"];
    
    NSString * signalStr = @"Unknown Signal";
    if (signal == SIGABRT) {
        signalStr = @"SIGABRT";
    } else if (signal == SIGILL) {
        signalStr = @"SIGILL";
    } else if (signal == SIGSEGV) {
        signalStr = @"SIGSEGV";
    } else if (signal == SIGFPE) {
        signalStr = @"SIGFPE";
    } else if (signal == SIGBUS) {
        signalStr = @"SIGBUS";
    } else if (signal == SIGPIPE) {
        signalStr = @"SIGPIPE";
    }
    
    NSString * reason = [NSString stringWithFormat:@"%@ error was raised",signalStr];
    NSException * exc =[NSException exceptionWithName:@"DWCrashCollectorSignalErrorName" reason:reason userInfo:userInfo];
    @throw exc;
}

#pragma mark --- inline method ---

static inline void saveCrashImage2Path(NSString * path) {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds),CGRectGetHeight([UIScreen mainScreen].bounds)),NO,1);
    [[UIApplication sharedApplication].keyWindow  drawViewHierarchyInRect:CGRectMake(0,0,CGRectGetWidth([UIScreen mainScreen].bounds),CGRectGetHeight([UIScreen mainScreen].bounds))afterScreenUpdates:NO];
    UIImage *snapshot =UIGraphicsGetImageFromCurrentImageContext();
    [UIImageJPEGRepresentation(snapshot,1.0)writeToFile:[NSString stringWithFormat:@"%@/%@",path,@"CrashSnap.jpg"] atomically:YES];
    UIGraphicsEndImageContext();
}

static inline void writeDataString2File(NSString * data,NSString * path) {
    NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:path];
    [file seekToEndOfFile];
    [file writeData:[data dataUsingEncoding:NSUTF8StringEncoding]];
    [file closeFile];
}

static inline  void installCollector(NSString * savePath,void(^handler)(NSException * exc)) {
    sP = savePath;
    expHandler = handler;
    NSSetUncaughtExceptionHandler(&exceptionHandler);
    signal(SIGABRT, signalCollector);
    signal(SIGILL, signalCollector);
    signal(SIGSEGV, signalCollector);
    signal(SIGFPE, signalCollector);
    signal(SIGBUS, signalCollector);
    signal(SIGPIPE, signalCollector);
}

static inline void uninstallCollector() {
    sP = nil;
    expHandler = nil;
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
}

static inline NSString * crashConfigPath() {
    return [sP stringByAppendingPathComponent:@"Crash/CrashConfig.plist"];
}

#pragma mark --- over write ---
-(instancetype)init {
    return nil;
}

@end

