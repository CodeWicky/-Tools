//
//  NSString+DWStringUtils.h
//  RegExp
//
//  Created by Wicky on 17/1/8.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DWStringUtils)
///生成由N个元字符串组成的字符串
/**
 metaString     元字符串，组成字符串的元素
 count          元字符串的个数
 */
+(NSString *)stringWithMetaString:(NSString *)metaString count:(NSUInteger)count;
@end
