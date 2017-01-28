//
//  NSArray+DWArrayUtils.m
//  tableview
//
//  Created by Wicky on 2017/1/29.
//  Copyright © 2017年 sf. All rights reserved.
//

#import "NSArray+DWArrayUtils.h"

@implementation NSArray (DWArrayUtils)
-(NSArray *)filterObjectsUsingBlock:(BOOL(^)(id obj, NSUInteger idx,NSUInteger count,BOOL * stop))block
{
    NSMutableArray * arr = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (block(obj,idx,arr.count,stop)) {
            [arr addObject:obj];
        }
    }];
    return arr.copy;
}
@end
