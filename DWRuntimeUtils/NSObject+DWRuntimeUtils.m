//
//  NSObject+DWRuntimeUtils.m
//  runtime
//
//  Created by Wicky on 16/9/18.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#import "NSObject+DWRuntimeUtils.h"
#import <objc/runtime.h>

@interface NSObject ()

@end

@implementation NSObject (DWRuntimeUtils)

-(NSString *)dw_Description
{
    NSArray * allKeys = [[self class] dw_GetAllProperties];
    //分割线
    NSString * starStr = @"\n********************\n";
    //类名及地址
    NSString * descriptionStr = [NSString stringWithFormat:@"\n\n<%@:%p>",[self class],self];
    descriptionStr = [descriptionStr stringByAppendingString:starStr];
    for (NSString * key in allKeys) {
        id value = [self dw_SafeValueForKey:key];
        //每个属性及对应值
        descriptionStr = [descriptionStr stringByAppendingString:[NSString stringWithFormat:@"\n%@ = %@;\n",key,value]];
    }
    descriptionStr = [descriptionStr stringByAppendingString:starStr];
    return descriptionStr;
}

#pragma mark ---动态添加属性---
+(void)dw_AddPropertyWithName:(NSString *)propertyName
             propertyClass:(Class)propertyClass
{
    //如果包含本属性，则不添加
    if ([self dw_ContainProperty:propertyName]) {
        return;
    }
    /*
     objc_property_attribute_t type = { "T", "@\"NSString\"" };
     objc_property_attribute_t ownership = { "C", "" }; // C = copy
     objc_property_attribute_t backingivar  = { "V", "_privateName" };
     objc_property_attribute_t attrs[] = { type, ownership, backingivar };
     class_addProperty([SomeClass class], "name", attrs, 3);
     */
    
    //objc_property_attribute_t所代表的意思可以调用getPropertyNameList打印，大概就能猜出
    objc_property_attribute_t type = { "T", [[NSString stringWithFormat:@"@\"%@\"",NSStringFromClass(propertyClass)] UTF8String]};
    objc_property_attribute_t ownership = { "&", "N" };
    objc_property_attribute_t backingivar  = { "V", [[NSString stringWithFormat:@"_%@", propertyName] UTF8String] };
    objc_property_attribute_t attrs[] = { type, ownership, backingivar };
    //添加属性
    if (class_addProperty([self class], [propertyName UTF8String], attrs, 3)) {
        //添加get和set方法
        class_addMethod([self class], NSSelectorFromString(propertyName), (IMP)getter, "@@:");
        NSString * setString = [NSString stringWithFormat:@"set%@:",[[[propertyName substringToIndex:1] uppercaseString] stringByAppendingString:[propertyName substringFromIndex:1]]];
        class_addMethod([self class], NSSelectorFromString(setString), (IMP)setter, "v@:@");
    }
}

id getter(id self1, SEL _cmd1) {
    //利用associate取出绑定的值
    return objc_getAssociatedObject(self1, _cmd1);
}

void setter(id self1, SEL _cmd1, id newValue) {
    //移除set
    NSString *key = [NSStringFromSelector(_cmd1) substringFromIndex:3];
    //首字母小写
    NSString *head = [[key substringToIndex:1] lowercaseString];
    key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:head];
    //移除后缀 ":"
    key = [key substringToIndex:key.length - 1];
    //利用associate绑定赋值
    objc_setAssociatedObject(self1, NSSelectorFromString(key), newValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark ---安全赋值---
-(void)dw_SafeSetValue:(id)value forKey:(NSString *)key
{
    if (value == nil) {
        return;
    }
    [[self class] dw_AddPropertyWithName:key propertyClass:[value class]];
    [self setValue:value forKey:key];
}

#pragma mark ---安全取值---
-(id)dw_SafeValueForKey:(NSString *)key
{
    if ([[self class] dw_ContainProperty:key]) {
        return [self valueForKey:key];
    }
    return nil;
}

#pragma mark ---是否包含属性---
+(BOOL)dw_ContainProperty:(NSString *)property
{
    return [[self dw_GetAllProperties] containsObject:property];
}

#pragma mark ---获取属性列表---
+(NSArray *)dw_GetAllProperties
{
    unsigned int outCount = 0;
    //获取属性数组
    objc_property_t *propertyList = class_copyPropertyList([self class], &outCount);
    
    NSMutableArray *arrM = [NSMutableArray arrayWithCapacity:outCount];
    //遍历数组
    for (int i = 0; i < outCount; ++i) {
        objc_property_t property = propertyList[i];
        //获取属性名
        const char *cName = property_getName(property);
        //将其转换成c字符串
        NSString *propertyName = [NSString stringWithCString:cName encoding:NSUTF8StringEncoding];
        //加入数组
        [arrM addObject:propertyName];
    }
    //在使用了c函数的creat, copy等函数是记得手动释放,要不然会引起内存泄露问题
    free(propertyList);
    return arrM.copy;
}

#pragma mark ---获取实例变量列表---
+(NSArray *)dw_GetAllIvar
{
    unsigned int count = 0;
    Ivar *ivarList = class_copyIvarList([self class], &count);
    NSMutableArray * arrM = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++) {
        Ivar ivar = ivarList[i];
        const char *cName = ivar_getName(ivar);
        [arrM addObject:[NSString stringWithCString:cName encoding:NSUTF8StringEncoding]];
    }
    free(ivarList);
    return arrM.copy;
}

#pragma mark --- 获取方法列表 ---
+(NSArray *)dw_GetAllMethods
{
    unsigned int count_f =0;
    //获取方法链表
    Method* methodList_f = class_copyMethodList([self class],&count_f);
    NSMutableArray *methodsArray = [NSMutableArray arrayWithCapacity:count_f];
    for(int i=0;i<count_f;i++)
    {
        Method temp_f = methodList_f[i];
        SEL name_f = method_getName(temp_f);
        NSString *methodStr = NSStringFromSelector(name_f);
        [methodsArray addObject:methodStr];
    }
    free(methodList_f);
    return methodsArray;
}

#pragma mark ---根据字典设置模型---
+(id)dw_CreateModelWithDictionary:(NSDictionary *)dictionary
{
    id model = [[self alloc] init];
    ///遍历赋值
    for (NSString * key in dictionary.allKeys) {
        [model dw_SafeSetValue:[dictionary valueForKey:key] forKey:key];
    }
    return model;
}

#pragma mark ---根据model生成字典---
-(NSDictionary *)dw_CreateDictionary
{
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    NSArray * allKeys = [[self class] dw_GetAllProperties];
    for (NSString * key in allKeys) {
        id value = [self dw_SafeValueForKey:key];
        if (value == nil) {
            value = (id)[NSNull null];
        }
        [dic setValue:value forKey:key];
    }
    return dic.copy;
}

#pragma mark ---根据Json数据生成model---
+(id)dw_CreateModelWithJsonData:(NSData *)data
{
    NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    return [self dw_CreateModelWithDictionary:dic];
}

#pragma mark ---根据model生成Json数据---
-(NSData *)dw_CreateJsonData
{
    NSDictionary * dic = [self dw_CreateDictionary];
    return [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
}

#pragma mark ---根据Json字符串生成Model---
+(id)dw_CreateModelWithJsonString:(NSString *)string
{
    NSData * data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return [self dw_CreateModelWithJsonData:data];
}

#pragma mark ---根据model生成Json字符串---
-(NSString *)dw_CreateJsonString
{
    NSData * data = [self dw_CreateJsonData];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

#pragma mark ---交换实例方法---
+(BOOL)dw_SwizzlingInstanceMethodWithSelectorA:(SEL)selA selectorB:(SEL)selB
{
    return [self dw_SwizzlingSelA:selA selB:selB handler:^(Method * methodA, Method * methodB) {
        *methodA = class_getInstanceMethod([self class], selA);
        *methodB = class_getInstanceMethod([self class], selB);
    }];
}

#pragma mark ---交换类方法---
+(BOOL)dw_SwizzlingClassMethodWithSelectorA:(SEL)selA selectorB:(SEL)selB
{
    return [self dw_SwizzlingSelA:selA selB:selB handler:^(Method * methodA, Method * methodB) {
        *methodA = class_getClassMethod([self class], selA);
        *methodB = class_getClassMethod([self class], selB);
    }];
}

+(BOOL)dw_SwizzlingSelA:(SEL)selA selB:(SEL)selB handler:(void(^)(Method * methodA,Method * methodB))handler
{
    __block BOOL success = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method methodA = nil;
        Method methodB = nil;
        if (!handler) {
            return ;
        }
        handler(&methodA,&methodB);
        if (!methodA || !methodB) {
            return ;
        }
        BOOL isAdd = class_addMethod([self class], selA, method_getImplementation(methodB), method_getTypeEncoding(methodB));
        if (isAdd) {
            class_replaceMethod([self class], selB, method_getImplementation(methodA), method_getTypeEncoding(methodA));
        }
        else
        {
            method_exchangeImplementations(methodA, methodB);
        }
        success = YES;
    });
    return success;
}

#pragma mark ---为方法绑定实现---
+(void)dw_SetMethod:(IMP)method forSelector:(SEL)sel type:(NSString *)type
{
    class_replaceMethod([self class], sel, method, type.UTF8String);
}

@end
