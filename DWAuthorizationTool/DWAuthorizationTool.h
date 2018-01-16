//
//  DWAuthorizationTool.h
//  a
//
//  Created by Wicky on 2018/1/15.
//  Copyright © 2018年 Wicky. All rights reserved.
//

/**
 DWAuthorizationTool
 授权工具类，提供授权状态获取及获取授权功能。
 
 version 1.0.0
 提供通讯录、相机、定位、相册、麦克风、日历、备忘录权限查询及获取功能。
 */
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DWAuthorizationStatus) {
    DWAuthorizationStatusNotDetermined,///未决定
    DWAuthorizationStatusRestricted,///受限
    DWAuthorizationStatusDenied,///拒绝
    DWAuthorizationStatusAuthorized///授权
};

typedef void(^RequestAuthorization)(BOOL authorized,DWAuthorizationStatus status,NSError * error);

@interface DWAuthorizationTool : NSObject

#pragma mark --- Query ---
+(DWAuthorizationStatus)queryAddressBookStatus;
+(DWAuthorizationStatus)queryCameraStauts;
+(DWAuthorizationStatus)queryLocationStatus;
+(DWAuthorizationStatus)queryPhotoAlbumStatus;
+(DWAuthorizationStatus)queryMicrophoneStatus;
+(DWAuthorizationStatus)queryCalendarStatus;
+(DWAuthorizationStatus)queryReminderStatus;

#pragma mark --- Request ---
+(void)requestLocation:(RequestAuthorization)completion;
+(void)requestAddressBook:(RequestAuthorization)completion;
+(void)requestCamera:(RequestAuthorization)completion;
+(void)requestPhotoAlbum:(RequestAuthorization)completion;
+(void)requestMicrophone:(RequestAuthorization)completion;
+(void)requestCalendar:(RequestAuthorization)completion;
+(void)requestReminder:(RequestAuthorization)completion;

@end
