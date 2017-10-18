//
//  DWEmailHelper.h
//  AccountBook
//
//  Created by Wicky on 2017/10/16.
//  Copyright © 2017年 Wicky. All rights reserved.
//

/**
 DWEmailHelper
 
 邮件助手类
 借助第三方库SKPSMTPMessage.h发送邮件
 */

#import <Foundation/Foundation.h>
#import "SKPSMTPMessage.h"

@class DWEmailEntity;
@interface DWEmailHelper : NSObject

///单例方法
+(instancetype)shareHelper;

/**
 发送邮件

 @param entity 邮件信息实体
 @param completion 完成后处理操作
 */
+(void)sendEmailEntity:(DWEmailEntity *)entity completion:(void(^)(BOOL success,SKPSMTPMessage * msg,NSError * error))completion;

@end

///附件类，用于以文件路径生成附件实例后放入邮件信息实体
@interface DWEmailAttachment : NSObject

/**
 以文件绝对路径生成附件实例类

 @param filePath 文件路径
 @return 附件实例
 */
+(instancetype)attachmentFromFilePath:(NSString *)filePath;

@end

///信息实体类
@interface DWEmailEntity : NSObject

///标题
@property (nonatomic ,copy) NSString * subject;

///正文
@property (nonatomic ,copy) NSString * content;

///附件
@property (nonatomic ,strong) NSArray <DWEmailAttachment *>* attachments;

///接收邮箱
@property (nonatomic ,copy) NSString * reciverEmailAddress;

///发送邮箱
@property (nonatomic ,copy) NSString * hostEmailAddress;

///邮箱登录名，若为nil是则默认为发送邮箱
@property (nonatomic ,copy) NSString * loginName;

///
/**
 发送邮箱的登录密码
 
 注：
 非发送邮箱登录密码，而是授权码，即登录第三方邮件客户端的专用密码。
 */
@property (nonatomic ,copy) NSString * password;

@end
