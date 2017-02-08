//
//  DWMD5Utils.h
//  DWAsyncImage
//
//  Created by Wicky on 2017/2/8.
//  Copyright © 2017年 Wicky. All rights reserved.
//

///
/**
 MD5加密类
 为字符串或NSData提供MD5加密并提供Category
 */

#import <Foundation/Foundation.h>

@interface DWMD5Utils : NSObject

+(NSString *)dw_GetMD5StringFromString:(NSString *)str;

+(NSString *)dw_GetMD5StringFromData:(NSData *)data;

@end

@interface NSString (DWMD5Utils)

@property (nonatomic,copy,readonly) NSString * dw_MD5String;

@end

@interface NSData (DWMD5Utils)

@property (nonatomic,copy,readonly) NSString * dw_MD5String;

@end
