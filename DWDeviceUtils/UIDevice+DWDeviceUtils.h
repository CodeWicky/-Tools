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
+(NSString *)dw_ProjectBuildNo;

///获取当前工程BundleID
+(NSString *)dw_ProjectBundleId;

///获取当前工程工程名称
+(NSString *)dw_ProjectDisplayName;

///获取当前工程版本号
+(NSString *)dw_ProjectVersion;

///获取当前设备UUID
+(NSString *)dw_DeviceUUID;

///获取当前设备别名
+(NSString *)dw_DeviceUserName;

///获取当前设备名
+(NSString *)dw_DeviceName;

///获取当前设备系统版本
+(NSString *)dw_DeviceSystemVersion;

///获取当前设备型号
+(NSString *)dw_DeviceModel;

///获取当前设备具体型号
+(NSString *)dw_DeviceDetailModel;

///获取当前设备平台号
+(NSString *)dw_DevicePlatform;

///获取当前设备CPU架构
+(NSString *)dw_DeviceCPUType;

///获取当前手机运营商
+(NSString *)dw_MobileOperator;

///获取当前开发SDK版本
+(NSString *)dw_DevelopSDKVersion;

@end
