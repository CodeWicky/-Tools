//
//  NSObject+DWRuntimeUtils.h
//  runtime
//
//  Created by Wicky on 16/9/18.
//  Copyright © 2016年 Wicky. All rights reserved.
//


/*
 DWRuntimeUtils
 
 简介：灵活的帮你生成model，一句话动态添加属性
 
 version 1.0.0
 利用runtime添加属性
 model的各种转换
 */

#import <Foundation/Foundation.h>
@interface NSObject (DWRuntimeUtils)

///详细属性
@property (nonatomic ,copy ,readonly) NSString * dw_Description;

///动态添加属性
/*
 propertyName       添加属性名
 propertyClass      添加属性的数据类型
 
 注：若添加属性已存在，则不添加，否则添加
 */
+(void)dw_AddPropertyWithName:(NSString *)propertyName
                propertyClass:(Class)propertyClass;

///安全赋值
/*
 value      要赋的值
 key        要赋值的键
 
 注：若属性存在，则直接赋值，否则先动态添加属性，再赋值
 */
-(void)dw_SafeSetValue:(id)value forKey:(NSString *)key;

///安全取值
/*
 key        要取值的键
 
 注：如果键存在，则直接取值，否则返回nil
 */
-(id)dw_SafeValueForKey:(NSString *)key;

///检查是否包含属性
+(BOOL)dw_ContainProperty:(NSString *)property;

///获取属性列表
+(NSArray *)dw_GetAllProperties;

///获取实例变量列表
+(NSArray *)dw_GetAllIvar;


///获取对象的所有方法
+(NSArray *)dw_GetAllMethods;

///根据字典设置模型
/*
 dictionary     数据源字典
 
 注：字典中，模型已存在的key会直接赋值，不存在的key会先动态添加属性，再赋值
 */
+(id)dw_CreateModelWithDictionary:(NSDictionary *)dictionary;

///根据model生成字典
-(NSDictionary *)dw_CreateDictionary;

///根据Json数据生成model
+(id)dw_CreateModelWithJsonData:(NSData *)data;

///根据model生成Json数据
-(NSData *)dw_CreateJsonData;

///根据Json字符串生成Model
+(id)dw_CreateModelWithJsonString:(NSString *)string;

///根据model生成Json字符串
-(NSString *)dw_CreateJsonString;

///交换实例方法
+(BOOL)dw_SwizzlingInstanceMethodWithSelectorA:(SEL)selA selectorB:(SEL)selB;

///交换类方法
+(BOOL)dw_SwizzlingClassMethodWithSelectorA:(SEL)selA selectorB:(SEL)selB;

///为方法绑定实现
+(void)dw_SetMethod:(IMP)method forSelector:(SEL)sel type:(NSString *)type;
@end
