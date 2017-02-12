//
//  NSArray+DWArrayUtils.m
//  tableview
//
//  Created by Wicky on 2017/1/29.
//  Copyright © 2017年 sf. All rights reserved.
//

#import "NSArray+DWArrayUtils.h"

@implementation NSArray (DWArrayUtils)
-(NSArray *)dw_FilterObjectsUsingBlock:(BOOL(^)(id obj, NSUInteger idx,NSUInteger count,BOOL * stop))block
{
    NSMutableArray * arr = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (block(obj,idx,arr.count,stop)) {
            [arr addObject:obj];
        }
    }];
    return arr.copy;
}
-(NSArray *)dw_ComplementaryArrayWithArr:(NSArray *)arr usingEqualBlock:(BOOL (^)(id,id))block
{
    NSMutableArray * array = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj1, NSUInteger idx, BOOL * _Nonnull stop) {
        __block BOOL contain = NO;
        [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj2, NSUInteger idx, BOOL * _Nonnull stop) {
            contain = block(obj1,obj2);
            if (contain) {
                *stop = YES;
            }
        }];
        if (!contain) {
            [array addObject:obj1];
        }
    }];
    return array.copy;
}
-(NSArray *)dw_ComplementaryArrayFromArr:(NSArray *)arr usingEqualBlock:(BOOL (^)(id,id))block
{
    return [arr dw_ComplementaryArrayWithArr:self usingEqualBlock:block];
}
@end
