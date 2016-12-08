//
//  DWModelAdapter.h
//  DWModelAdapter
//
//  Created by Wicky on 2016/12/8.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 DWModelAdapter
 
 模型转换工具
 可以建立基本转换配置字典
 
 使用方法
 1.建立映射表
 2.将映射表置于字典中
 
 如建立A与B的映射表
 @{@"class":@"B",@"map":@{@"propertyAName1":@"propertyBName1",...}}
 
 置于字典
 @{@"A":@{@"class":@"B",@"map":@{@"propertyAName1":@"propertyBName1",...}}}
 */

@interface DWModelAdapter : NSObject
-(NSObject *)convertModel:(NSObject *)modelA withAdapters:(NSDictionary *)adpaters;
@end
