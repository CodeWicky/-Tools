//
//  DWModelAdapter.m
//  DWModelAdapter
//
//  Created by Wicky on 2016/12/8.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#import "DWModelAdapter.h"

@implementation DWModelAdapter
-(NSObject *)convertModel:(NSObject *)modelA withAdapters:(NSDictionary *)adpaters
{
    NSString * modelACls = NSStringFromClass([modelA class]);
    NSDictionary * adapter = adpaters[modelACls];
    if (!adapter) {
        return modelA;
    }
    NSString * modelBCls = adapter[@"class"];
    NSDictionary * map = adapter[@"map"];
    NSObject * modelB = [NSClassFromString(modelBCls) new];
    for (NSString * keyA in map.allKeys) {
        id valueA = [modelA valueForKey:keyA];
        NSString * keyB = map[keyA];
        if ([valueA isKindOfClass:[NSArray class]]) {///处理数组逻辑
            NSMutableArray * arr = [NSMutableArray array];
            [valueA enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSObject * tempValue = [self convertModel:obj withAdapters:adpaters];
                [arr addObject:tempValue];
            }];
            [modelB setValue:arr forKey:keyB];
        }
        else if ([valueA isKindOfClass:[NSDictionary class]]){///处理字典逻辑
            NSMutableDictionary * dic = [NSMutableDictionary dictionary];
            [[valueA allKeys] enumerateObjectsUsingBlock:^(NSString *  _Nonnull tempKey, NSUInteger idx, BOOL * _Nonnull stop) {
                NSObject * tempValue = [valueA valueForKey:tempKey];
                NSObject * newTempValue = [self convertModel:tempValue withAdapters:adpaters];
                [dic setValue:newTempValue forKey:tempKey];
            }];
            [modelB setValue:dic forKey:keyB];
        }
        else if ([[adpaters allKeys] containsObject:NSStringFromClass([valueA class])]){///处理模型逻辑
            NSObject * tempModel = [self convertModel:valueA withAdapters:adpaters];
            [modelB setValue:tempModel forKey:keyB];
        }
        else///处理其他默认值逻辑
        {
            [modelB setValue:valueA forKey:keyB];
        }
    }
    return modelB;
}


@end
