//
//  DWRegexUtils.h
//  Regex
//
//  Created by Wicky on 2016/12/27.
//  Copyright © 2016年 Wicky. All rights reserved.
//

/**
 DWRegexUtils
 
 正则语句快速生成工具类
 
 以链式语法帮你优雅的按照组件自动生成正则
 
 使用方法：
 按照检测目标规则顺序添加检测条件即可
 
 使用说明：
 非预查模式以组件添加顺序组成检测条件，预查模式位置不影响检测条件，均为前置。
 
 概念解释：
 预查：即全局作用域，目标字符串整串符合要求
 非预查：即顺序匹配。将非预查条件按顺序添加即可组成目标检测条件
 正则组件：组成正则语句元素的目标字符集，可为组件添加范围、添加即可组成正则语句
 正则条件：提取出的六种条件模式，用来为组件添加约束
 贪婪：尽可能多的匹配结果
 
 version 1.0.0
 提供链式语法以组件化生成正则语句
 
 version 1.0.1
 提供基础验证类方法
 
 version 1.0.2
 修改组件类型api，添加附加串接口
 
 version 1.0.3
 提供其他验证类方法
 
 version 1.0.4
 添加贪婪模式
 添加返回文本中返回正则的所有结果api
 添加返回替换字符串中所有符合正则的子串的结果的api
 修复组件模式验证bug
 提供正则常量，并优化部分基本预置正则验证算法
 
 version 1.0.5
 修改URL正则：path段添加_支持
 
 version 1.0.6
 修复预查中包含模式和不包含模式范围自动补全
 */

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, DWRegexComponent) {///正则组件
    DWRegexComponentNumber = 1 << 0,///数字
    DWRegexComponentUppercaseLetter = 1 << 1,///大写字母
    DWRegexComponentLowercaseLetter = 1 << 2,///小写字母
    DWRegexComponentChinese = 1 << 3,///汉字
    DWRegexComponentSymbol = 1 << 4,///符号
    DWRegexComponentEntireExceptLF = 1 << 5,///除换行符外所有字符
    DWRegexComponentEntire = 1<< 6,///任意字符（包括\n\r）
    DWRegexComponentLetter = DWRegexComponentUppercaseLetter | DWRegexComponentLowercaseLetter,///任意字母
    DWRegexComponentPassword = DWRegexComponentNumber | DWRegexComponentLetter,///字母数字组合
    DWRegexComponentCharacter = DWRegexComponentChinese | DWRegexComponentLetter | DWRegexComponentNumber | DWRegexComponentSymbol,///中英文符号组合
};

typedef NS_ENUM(NSUInteger, DWRegexCondition) {///组件条件模式
    DWRegexConditionPreSearchAllIS,///预查、全部是
    DWRegexConditionPreSearchAllNot,///预查、全不是
    DWRegexConditionPreSearchContain,///预查、是，不全
    DWRegexConditionPreSearchNotAll,///预查、不全是
    DWRegexConditionContain,///包含
    DWRegexConditionWithout///不包含
};

#define DWINTEGERNULL ULONG_MAX

@class DWRegexUtils;
@interface DWRegexMaker : NSObject;

/**
 以组件类别及附加串添加条件
 
 即以组件类别和附加串共同组成正则组件并添加条件
 
 注：
 1.若指定位数则min、max传相同数值
 2.若min、max均为DWINTEGERNULL根据不同模式会自动补全范围
 若为预查模式中contain或allNot则范围为最小值1，allIs和notAll无限制，若为包含模式则范围为最小值1
 */
@property (nonatomic ,copy) DWRegexMaker * (^AddConditionWithComponentType)(DWRegexComponent component,NSString * additionalStr,DWRegexCondition condition,NSUInteger minCount,NSUInteger maxCount,BOOL greedy);

/**
 以正则组件、条件模式、范围添加条件
 
 即以正则组件添加条件、范围
 
 注：
 1.若指定位数则min、max传相同数值
 2.若min、max均为DWINTEGERNULL根据不同模式会自动补全范围
 若为预查模式中contain或allNot则范围为最小值1，allIs和notAll无限制，若为包含模式则范围为最小值1
 */
@property (nonatomic ,copy) DWRegexMaker * (^AddConditionWithComponentRegexString)(NSString * regExpStr,DWRegexCondition condition,NSUInteger minCount,NSUInteger maxCount,BOOL greedy);

/**
 以完整正则表达式添加条件
 
 即为完整的正则表达式作为子串添加条件，构建更加复杂的正则表达式
 */
@property (nonatomic ,copy) DWRegexMaker * (^AddConditionWithCompleteRegexString)(NSString * regExpStr,DWRegexCondition condition);

@end

@interface DWRegexResult : NSObject

@property (nonatomic ,copy) NSString * result;

@property (nonatomic ,assign) NSRange range;

@end

@interface DWRegexUtils : NSObject

/**
 单例模式
 */
+(instancetype)shareRegexUtils;

/**
 以链式语句生成正则
 */
+(NSString *)dw_GetRegexStringWithMaker:(void(^)(DWRegexMaker * maker))stringMaker;

/**
 根据组件类型返回正则组件
 
 components         组件类型
 additionalString   组件附加串，可为nil，则无附加串
 
 用法：
 比如想要数字与下划线组件可以如下传参
 DWRegexComponentNumber、@"_"
 
 返回的字符串即可作为元素（即正则组件），可为其添加范围，可为其添加条件
 */
-(NSString *)dw_GetRegexComponentStringWithComponents:(DWRegexComponent)components additionalString:(NSString *)addition;

/**
 以正则组件、条件模式、范围生成配置文件
 
 注：
 1.若指定位数则min、max传相同数值
 2.若min、max均为DWINTEGERNULL根据不同模式会自动补全范围
 若为预查模式则范围为最小值0，若为包含模式则范围为最小值1
 3.是否为贪婪模式
 */
-(NSDictionary *)dw_CreateRegexConfigWithComponent:(NSString *)component condition:(DWRegexCondition)condition minCount:(NSUInteger)min maxCount:(NSUInteger)max greedy:(BOOL)greedy;

/**
 以正则文本、条件模式生成配置文件
 */
-(NSDictionary *)dw_CreateRegexConfigWithRegexString:(NSString *)regExpString condition:(DWRegexCondition)condition;

/**
 以配置文件生成正则文本
 */
-(NSString *)dw_GetRegexStringWithConfigs:(NSArray *)configs;

/**
 返回字符串中所有符合正则的结果
 */
+(NSArray<DWRegexResult *> *)dw_GetMatchesStringsInString:(NSString *)string withRegex:(NSString *)regex;


/**
 替换指定范围内符合正则的字符串
 */
+(NSString *)dw_ReplaceMatchesStringsInString:(NSString *)string withRegex:(NSString *)regex replacement:(NSString *)replacement inRange:(NSRange)range;

/**
 验证正则文本
 */
+(BOOL)dw_ValidateString:(NSString *)string withRegexString:(NSString *)regExp;

/**
 以组件验证文本
 */
+(BOOL)dw_ValidateString:(NSString *)string withComponents:(DWRegexComponent)components minCount:(NSUInteger)min maxCount:(NSUInteger)max;

#pragma mark --- 预置正则匹配 ---

/**
 验证数字
 */
+(BOOL)dw_ValidateNumber:(NSString *)string;

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

/**
 验证自然数
 */
+(BOOL)dw_ValidateNatureNumber:(NSString *)string;

/**
 验证银行卡有效性
 */
+(BOOL)dw_ValidateBankNo:(NSString *)string;

/**
 验证身份证号
 */
+(BOOL)dw_ValidateIDCardNo:(NSString *)string;

@end

@interface NSString (DWRegexUtils)

-(NSArray<DWRegexResult *> *)stringMatchesByRegex:(NSString *)regex;

@end

extern NSString * const DWRegexNumber;//数字

extern NSString * const DWRegexLetter;//字母

extern NSString * const DWRegexChinese;//汉字

extern NSString * const DWRegexSymbol;//符号

extern NSString * const DWRegexEmail;//邮件地址

extern NSString * const DWRegexMobile;//手机号码

extern NSString * const DWRegexTele;//电话号码

extern NSString * const DWRegexURL;//URL

extern NSString * const DWRegexNatureNumber;//自然数
