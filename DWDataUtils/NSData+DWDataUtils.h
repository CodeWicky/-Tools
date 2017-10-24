//
//  NSData+DWDataUtils.h
//  AccountBook
//
//  Created by Wicky on 2017/10/8.
//  Copyright © 2017年 Wicky. All rights reserved.
//


/**
 DWDataUtils
 
 提供NSData的相关便捷方法
 
 version 1.0.0
 提供Base64编解码方法
 */

#import <Foundation/Foundation.h>

@interface NSData (DWDataEncodeUtils)

///解码一个base64字符串
+(NSData *)dw_DecodeDataFromBase64String:(NSString *)aString;

///将data进行base64编码
-(NSString *)dw_Base64EncodedString;

///解码一个webSafe的base64字符串
+(NSData *)dw_WebSafeDecodeDataFromBase64String:(NSString *)aString;


/**
 将data进行webSafe的base64编码

 @param padding 转码是是否用空格占位空出的两字节
 */
-(NSString *)dw_WebSafeBase64EncodedStringWithPadding:(BOOL)padding;
@end
