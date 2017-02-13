//
//  NSArray+DWArrayUtils.h
//  tableview
//
//  Created by Wicky on 2017/1/29.
//  Copyright © 2017年 sf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (DWArrayUtils)
///根据block过滤数组
/**
 block  返回保留条件的block
 
 e.g.
 return obj.length > 0;
 则返回数组中长度大于0的字符串组成的数组
 */
-(NSArray *)dw_FilterObjectsUsingBlock:(BOOL(^)(id obj, NSUInteger idx,NSUInteger count,BOOL * stop))block;

///获取自身中相对arr的补集
/**
 block  返回判断对象相等的条件
 
 e.g.
 return [obj1 isEqualToString:obj2];
 则若两字符串相同，则排除，返回不相同字符串的数组
 */
-(NSArray *)dw_ComplementaryArrayWithArr:(NSArray *)arr usingEqualBlock:(BOOL(^)(id obj1,id obj2))block;

///获取arr中相对于自身的补集
-(NSArray *)dw_ComplementaryArrayFromArr:(NSArray *)arr usingEqualBlock:(BOOL(^)(id obj1,id obj2))block;

///将数组按数量分为多个数组
-(NSArray *)dw_SplitArrayByCapacity:(NSUInteger)capacity;
@end
