//
//  DWRegExpUtils.h
//  RegExp
//
//  Created by Wicky on 2016/12/27.
//  Copyright © 2016年 Wicky. All rights reserved.
//

/**
 DWRegExpUtils
 
 正则语句快速生成工具类
 
 以链式语法帮你优雅的按照组件自动生成正则
 
 使用方法：
 按照检测目标规则顺序添加检测条件即可
 
 使用说明：
 非预查模式以组件添加顺序组成检测条件，预查模式位置不影响检测条件，均为前置。
 
 概念解释：
 预查：即全局作用域，目标字符串整串符合要求
 非预查：即顺序匹配。将非预查条件按顺序添加即可组成目标检测条件
 
 version 1.0.0
 提供链式语法以组件化生成正则语句
 */

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, DWRegExpComponent) {///正则组件
    DWRegExpComponentNumber = 1 << 0,///数字
    DWRegExpComponentUppercaseLetter = 1 << 1,///大写字母
    DWRegExpComponentLowercaseLetter = 1 << 2,///小写字母
    DWRegExpComponentChinese = 1 << 3,///汉字
    DWRegExpComponentSymbol = 1 << 4,///符号
    DWRegExpComponentEntireExceptLF = 1 << 5,///除换行符外所有字符
    DWRegExpComponentEntire = 1<< 6,///任意字符（包括\n\r）
    DWRegExpComponentLetter = DWRegExpComponentUppercaseLetter | DWRegExpComponentLowercaseLetter,///任意字母
    DWRegExpComponentPassword = DWRegExpComponentNumber | DWRegExpComponentLetter,///字母数字组合
    DWRegExpComponentCharacter = DWRegExpComponentChinese | DWRegExpComponentLetter | DWRegExpComponentNumber | DWRegExpComponentSymbol,///中英文符号组合
};

typedef NS_ENUM(NSUInteger, DWRegExpCondition) {///组件条件模式
    DWRegExpConditionPreSearchAllIS,///预查、全部是
    DWRegExpConditionPreSearchAllNot,///预查、全不是
    DWRegExpConditionPreSearchContain,///预查、是，不全
    DWRegExpConditionPreSearchNotAll,///预查、不全是
    DWRegExpConditionContain,///包含
    DWRegExpConditionWithout///不包含
};

#define DWINTEGERNULL ULONG_MAX

@class DWRegExpUtils;
@interface DWRegExpMaker : NSObject;

/**
 以组件类别生成正则
 
 注：
 1.若指定位数则min、max传相同数值
 2.若min、max均为DWINTEGERNULL根据不同模式会自动补全范围
 若为预查模式则范围为最小值0，若为包含模式则范围为最小值1
 */
@property (nonatomic ,copy) DWRegExpMaker * (^AddConditionWithComponentType)(DWRegExpComponent component,DWRegExpCondition condition,NSUInteger minCount,NSUInteger maxCount);

/**
 以正则组件、条件模式、范围生成配置文件
 
 注：
 1.若指定位数则min、max传相同数值
 2.若min、max均为DWINTEGERNULL根据不同模式会自动补全范围
 若为预查模式则范围为最小值0，若为包含模式则范围为最小值1
 */
@property (nonatomic ,copy) DWRegExpMaker * (^AddConditionWithComponentRegExpString)(NSString * regExpStr,DWRegExpCondition condition,NSUInteger minCount,NSUInteger maxCount);

/**
 以完整正则表达式添加条件
 */
@property (nonatomic ,copy) DWRegExpMaker * (^AddConditionWithCompleteRegExpString)(NSString * regExpStr,DWRegExpCondition condition);

@end

@interface DWRegExpUtils : NSObject

/**
 单例模式
 */
+(instancetype)shareRegExpUtils;

/**
 以链式语句生成正则
 */
+(NSString *)dw_GetRegExpStringWithMaker:(void(^)(DWRegExpMaker * maker))stringMaker;

/**
 根据组件类型返回正则组件
 */
-(NSString *)dw_GetRegExpComponentStringWithComponents:(DWRegExpComponent)components;

/**
 以正则组件、条件模式、范围生成配置文件
 
 注：
 1.若指定位数则min、max传相同数值
 2.若min、max均为DWINTEGERNULL根据不同模式会自动补全范围
 若为预查模式则范围为最小值0，若为包含模式则范围为最小值1
 */
-(NSDictionary *)dw_CreateRegExpConfigWithComponent:(NSString *)component condition:(DWRegExpCondition)condition minCount:(NSUInteger)min maxCount:(NSUInteger)max;

/**
 以正则文本、条件模式生成配置文件
 */
-(NSDictionary *)dw_CreateRegExpConfigWithRegExpString:(NSString *)regExpString condition:(DWRegExpCondition)condition;

/**
 以配置文件生成正则文本
 */
-(NSString *)dw_GetRegExpStringWithConfigs:(NSArray *)configs;

/**
 验证正则文本
 */
+(BOOL)dw_ValidateString:(NSString *)string withRegExpString:(NSString *)regExp;

/**
 以组件验证文本
 */
+(BOOL)dw_ValidateString:(NSString *)string withComponents:(DWRegExpComponent)components;

#pragma mark --- 预置正则匹配 ---

/**
 验证数字
 */
+(BOOL)dw_validateNumber:(NSString *)string;

/**
 验证英文字母
 */
+(BOOL)dw_ValidateLetter:(NSString *)string;

/**
 验证中文
 */
+(BOOL)dw_ValidateChinese:(NSString *)string;

/**
 验证符号
 */
+(BOOL)dw_ValidateSymbol:(NSString *)string;

/**
 验证密码
 
 注：数字、字母、下划线、至少包含两种
 */
+(BOOL)dw_ValidatePassword:(NSString *)string minLength:(NSUInteger)min maxLength:(NSUInteger)max;

/**
 验证邮箱
 */
+(BOOL)dw_ValidateEmail:(NSString *)string;

/**
 验证手机
 */
+(BOOL)dw_ValidateMobile:(NSString *)string;

/**
 验证电话
 */
+(BOOL)dw_ValidateTele:(NSString *)string;

/**
 验证URL
 */
+(BOOL)dw_ValidateURL:(NSString *)string;

@end
