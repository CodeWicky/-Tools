//
//  UIDevice+DWDeviceUtils.h
//  DWLogger
//
//  Created by Wicky on 2017/10/9.
//  Copyright © 2017年 Wicky. All rights reserved.
//

/**
 DWDeviceUtils
 提供Device相关信息及便捷方法
 */

#import <UIKit/UIKit.h>

@interface UIDevice (DWDeviceSystemInfo)

///获取当前工程Build号
+(NSString *)dw_projectBuildNo;

///获取当前工程BundleID
+(NSString *)dw_projectBundleId;

///获取当前工程工程名称
+(NSString *)dw_projectDisplayName;

///获取当前工程版本号
+(NSString *)dw_projectVersion;

///获取当前设备UUID
+(NSString *)dw_deviceUUID;

///获取当前设备别名
+(NSString *)dw_deviceUserName;

///获取当前设备名
+(NSString *)dw_deviceName;

///获取当前设备系统版本
+(NSString *)dw_deviceSystemVersion;

///获取当前设备型号
+(NSString *)dw_deviceModel;

///获取当前设备具体型号
+(NSString *)dw_deviceDetailModel;

///获取当前设备平台号
+(NSString *)dw_devicePlatform;

///获取当前设备CPU架构
+(NSString *)dw_deviceCPUType;

///获取当前设备总内存大小(Kb)
+(CGFloat)dw_deviceTotalMemory;

///获取当前设备可用内存大小(Kb)
+(CGFloat)dw_deviceFreeMemory;

///获取当前手机运营商
+(NSString *)dw_mobileOperator;

///获取当前开发SDK版本
+(NSString *)dw_developSDKVersion;

///获取当前手机电量
+(CGFloat)dw_batteryVolumn;

@end
