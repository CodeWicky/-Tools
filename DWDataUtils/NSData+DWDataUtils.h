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
+(NSData *)dw_DecodeDataFromBase64String:(NSString *)aString;
-(NSString *)dw_Base64EncodedString;
+(NSData *)dw_WebSafeDecodeDataFromBase64String:(NSString *)aString;
-(NSString *)dw_WebSafeBase64EncodedStringWithPadding:(BOOL)padding;
@end
