//
//  DWRegExpUtils.m
//  RegExp
//
//  Created by Wicky on 2016/12/27.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#import "DWRegExpUtils.h"

@interface DWRegExpUtils ()

@property (nonatomic ,strong) NSMutableArray * configs;

@end

@interface DWRegExpMaker()

@property (nonatomic ,strong) DWRegExpUtils * utils;

@end
static DWRegExpUtils * utils = nil;

static NSDictionary * provinceDic = nil;
@implementation DWRegExpUtils

+(NSString *)dw_GetRegExpStringWithMaker:(void (^)(DWRegExpMaker *))stringMaker
{
    DWRegExpUtils * utils = [DWRegExpUtils new];
    if (stringMaker) {
        DWRegExpMaker * maker = [[DWRegExpMaker alloc] init];
        maker.utils = utils;
        stringMaker(maker);
    }
    return [utils dw_GetRegExpStringWithConfigs:utils.configs];
}

-(NSString *)dw_GetRegExpComponentStringWithComponents:(DWRegExpComponent)components additionalString:(NSString *)addition
{
    NSString * regExp = @"";
    if (components & DWRegExpComponentEntire) {
        return @"\\s\\S";
    }
    if (components & DWRegExpComponentEntireExceptLF) {
        return @".";
    }
    if (components & DWRegExpComponentNumber) {
        regExp = [regExp stringByAppendingString:@"\\d"];
    }
    if (components & DWRegExpComponentLowercaseLetter) {
        regExp = [regExp stringByAppendingString:@"a-z"];
    }
    if (components & DWRegExpComponentUppercaseLetter) {
        regExp = [regExp stringByAppendingString:@"A-Z"];
    }
    if (components & DWRegExpComponentChinese) {
        regExp = [regExp stringByAppendingString:@"\\u4E00-\\u9FA5"];
    }
    if (components & DWRegExpComponentSymbol) {
        regExp = [regExp stringByAppendingString:@"\\W_"];
    }
    if (addition.length) {
        regExp = [regExp stringByAppendingString:addition];
    }
    return regExp;
}

+(BOOL)dw_ValidateString:(NSString *)string withRegExpString:(NSString *)regExp
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regExp];
    return [predicate evaluateWithObject:string];
}

-(NSDictionary *)dw_CreateRegExpConfigWithComponent:(NSString *)component condition:(DWRegExpCondition)condition minCount:(NSUInteger)min maxCount:(NSUInteger)max
{
    if (component.length == 0) {
        return nil;
    }
    if ([component isEqualToString:@"."]) {
        component = handleRange(component, min, max, NO);
    }
    else
    {
        switch (condition) {
            case DWRegExpConditionPreSearchAllIS:
                component = [NSString stringWithFormat:@"(?=[%@]+$)",component];
                break;
            case DWRegExpConditionPreSearchAllNot:
                component = [NSString stringWithFormat:@"(?!.*[%@]",component];
                component = handleRange(component, min, max,NO);
                component = [NSString stringWithFormat:@"%@.*)",component];
                break;
            case DWRegExpConditionPreSearchNotAll:
                component = [NSString stringWithFormat:@"(?![%@]+$)",component];
                break;
            case DWRegExpConditionPreSearchContain:
                component = [NSString stringWithFormat:@"(?=.*[%@]",component];
                component = handleRange(component, min, max,NO);
                component = [NSString stringWithFormat:@"%@)",component];
                break;
            case DWRegExpConditionContain:
            {
                component = [NSString stringWithFormat:@"[%@]",component];
                component = handleRange(component, min, max,YES);
            }
                break;
            case DWRegExpConditionWithout:
            {
                component = [NSString stringWithFormat:@"[^%@]",component];
                component = handleRange(component, min, max,YES);
            }
                break;
            default:
                break;
        }
    }
    return [self dw_CreateRegExpConfigWithRegExpString:component condition:condition];
}

-(NSDictionary *)dw_CreateRegExpConfigWithRegExpString:(NSString *)regExpString condition:(DWRegExpCondition)condition
{
    return @{@"component":regExpString,@"condition":@(condition)};
}

-(NSString *)dw_GetRegExpStringWithConfigs:(NSArray *)configs
{
    NSMutableString * preS = [NSMutableString stringWithFormat:@"()"];
    NSMutableString * regS = [NSMutableString stringWithFormat:@""];
    [configs enumerateObjectsUsingBlock:^(NSDictionary * dic, NSUInteger idx, BOOL * _Nonnull stop) {
        DWRegExpCondition condition = [dic[@"condition"] integerValue];
        NSString * component = dic[@"component"];
        if (component.length) {
            switch (condition) {
                case DWRegExpConditionPreSearchAllIS:
                case DWRegExpConditionPreSearchAllNot:
                case DWRegExpConditionPreSearchNotAll:
                case DWRegExpConditionPreSearchContain:
                {
                    [preS insertString:component atIndex:1];
                }
                    break;
                case DWRegExpConditionContain:
                case DWRegExpConditionWithout:
                {
                   [regS appendString:component];
                }
                    break;
                default:
                    break;
            }
        }
    }];
    if (preS.length > 2) {
        regS = [preS stringByAppendingString:regS].copy;
    }
    return regS;
}

+(BOOL)dw_ValidateString:(NSString *)string withComponents:(DWRegExpComponent)components minCount:(NSUInteger)min maxCount:(NSUInteger)max
{
    NSString * regExp = [[DWRegExpUtils shareRegExpUtils] dw_GetRegExpComponentStringWithComponents:components additionalString:nil];
    regExp = handleRange(regExp, min, max, NO);
    return [DWRegExpUtils dw_ValidateString:string withRegExpString:regExp];
}

///追加范围
static inline NSString * handleRange(NSString * component,NSUInteger min,NSUInteger max,BOOL preSearch){
    if (max != DWINTEGERNULL) {
        if (min == DWINTEGERNULL) {
            min = 0;
        }
        else if (min == max)
        {
            return [NSString stringWithFormat:@"%@{%lu}",component,min];
        }
        component = [NSString stringWithFormat:@"%@{%lu,%lu}",component,min,max];
    }
    else
    {
        if (min != DWINTEGERNULL) {
            component = [NSString stringWithFormat:@"%@{%lu,}",component,min];
        }
        else
        {
            if (preSearch) {
                component = [NSString stringWithFormat:@"%@+",component];
            }
            else
            {
                component = [NSString stringWithFormat:@"%@*",component];
            }
        }
    }
    return component;
}

-(NSMutableArray *)configs
{
    if (!_configs) {
        _configs = [NSMutableArray array];
    }
    return _configs;
}

#pragma mark --- 预置基础验证方法---

#pragma mark ------ 预置正则匹配 ------

+(BOOL)dw_ValidateNumber:(NSString *)string
{
    return [DWRegExpUtils dw_ValidateString:string withComponents:DWRegExpComponentNumber minCount:DWINTEGERNULL maxCount:DWINTEGERNULL];
}

+(BOOL)dw_ValidateLetter:(NSString *)string
{
    return [DWRegExpUtils dw_ValidateString:string withComponents:DWRegExpComponentLetter minCount:DWINTEGERNULL maxCount:DWINTEGERNULL];
}

+(BOOL)dw_ValidateChinese:(NSString *)string
{
    return [DWRegExpUtils dw_ValidateString:string withComponents:DWRegExpComponentChinese minCount:DWINTEGERNULL maxCount:DWINTEGERNULL];
}

+(BOOL)dw_ValidateSymbol:(NSString *)string
{
    return [DWRegExpUtils dw_ValidateString:string withComponents:DWRegExpComponentSymbol minCount:DWINTEGERNULL maxCount:DWINTEGERNULL];
}

+(BOOL)dw_ValidatePassword:(NSString *)string minLength:(NSUInteger)min maxLength:(NSUInteger)max
{
    return [DWRegExpUtils dw_ValidateString:string withRegExpString:[NSString stringWithFormat:@"((?![_]+$)(?![a-zA-Z]+$)(?![\\d]+$))[\\da-zA-Z_]{%lu,%lu}",min,max]];
}

+(BOOL)dw_ValidateEmail:(NSString *)string
{
    return [DWRegExpUtils dw_ValidateString:string withRegExpString:@"^[A-Za-z\\d]+([-_.][A-Za-z\\d]+)*@([A-Za-z\\d]+[-.])*([A-Za-z\\d]+[.])+[A-Za-z\\d]{2,5}$"];
}

+(BOOL)dw_ValidateMobile:(NSString *)string
{
    return [DWRegExpUtils dw_ValidateString:string withRegExpString:@"1[34578]\\d{9}"];
}

+(BOOL)dw_ValidateTele:(NSString *)string
{
    return [DWRegExpUtils dw_ValidateString:string withRegExpString:@"(0[\\d]{2,3}-)?([2-9][\\d]{6,7})(-[\\d]{1,4})?"];
}

+(BOOL)dw_ValidateURL:(NSString *)string
{
    return [DWRegExpUtils dw_ValidateString:string withRegExpString:@"((http|ftp|https)://)?((([a-zA-Z0-9]+[a-zA-Z0-9_-]*\\.)+[a-zA-Z]{2,6})|(([0-9]{1,3}\\.){3}[0-9]{1,3}(:[0-9]{1,4})?))((/[a-zA-Z\\d]+)*(\\?([a-zA-Z\\d_]+=[a-zA-Z\\d\\u4E00-\\u9FA5\\s\\+%#_-]+&)*([a-zA-Z\\d_]+=[a-zA-Z\\d\\u4E00-\\u9FA5\\s\\+%#_-]+))?)?"];
}

+(BOOL)dw_ValidateNatureNumber:(NSString *)string
{
    return [DWRegExpUtils dw_ValidateString:string withRegExpString:@"\\d+(\\.\\d+)?"];
}

#pragma mark ------ 预置计算验证 ------

+(BOOL)dw_ValidateBankNo:(NSString *)string
{
    NSString *tmpStr = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (![DWRegExpUtils dw_ValidateString:string withComponents:(DWRegExpComponentNumber) minCount:16 maxCount:19]) {
        return NO;
    }
    
    int sum = 0;
    int len = (int)[tmpStr length];
    int i = 0;
    
    while (i < len) {
        NSString *tmpString = [tmpStr substringWithRange:NSMakeRange(len - 1 - i, 1)];
        int tmpVal = [tmpString intValue];
        if (i % 2 != 0) {
            tmpVal *= 2;
            if(tmpVal>=10) {
                tmpVal -= 9;
            }
        }
        sum += tmpVal;
        i++;
    }
    
    if((sum % 10) == 0)
        return YES;
    else
        return NO;
}

+(BOOL)dw_ValidateIDCardNo:(NSString *)string
{
    NSString *tmpStr = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [DWRegExpUtils shareRegExpUtils];
    
    //判断位数及数字
    if (![DWRegExpUtils dw_ValidateString:tmpStr withRegExpString:@"\\d{17}[X\\d]"] && ![DWRegExpUtils dw_ValidateString:tmpStr withRegExpString:@"\\d{15}"]) {
        return NO;
    }
    
    long lSumQT =0;
    
    //加权因子
    int R[] = {7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2 };
    
    //校验码
    unsigned char sChecker[11] = {'1','0','X', '9', '8', '7', '6', '5', '4', '3', '2'};
    
    //将15位身份证号转换成18位
    NSMutableString *mString = [NSMutableString stringWithString:tmpStr];
    if ([mString length] == 15) {
        
        [mString insertString:@"19" atIndex:6];
        
        long p = 0;
        
        const char *pid = [mString UTF8String];
        
        for (int i = 0; i <= 16; i++)
        {
            p += (pid[i] - 48) * R[i];
        }
        
        int o = p % 11;
        
        NSString *string_content = [NSString stringWithFormat:@"%c",sChecker[o]];
        
        [mString insertString:string_content atIndex:[mString length]];
    }
    
    //判断地区码
    NSString *sProvince = [mString substringToIndex:2];
    
    if (![provinceDic valueForKey:sProvince]) {
        
        return NO;
        
    }
    
    //年份
    int strYear = [[self getStringWithRange:mString Value1:6 Value2:4] intValue];
    
    //月份
    int strMonth = [[self getStringWithRange:mString Value1:10 Value2:2] intValue];
    
    //日
    int strDay = [[self getStringWithRange:mString Value1:12 Value2:2] intValue];
    
    
    NSTimeZone *localZone = [NSTimeZone localTimeZone];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    [dateFormatter setTimeZone:localZone];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *date = [dateFormatter dateFromString:[NSString stringWithFormat:@"%d-%d-%d 12:01:01",strYear,strMonth,strDay]];
    
    if (date == nil) {
        return NO;
    }
    
    const char *PaperId  = [mString UTF8String];
    
    //验证最末的校验码
    for (int i = 0; i <= 16; i++)
    {
        lSumQT += (PaperId[i] - 48) * R[i];
    }
    
    if (sChecker[lSumQT % 11] != PaperId[17] )
    {
        return NO;
    }
    
    return YES;
}


+ (NSString *)getStringWithRange:(NSString *)str Value1:(NSInteger)value1 Value2:(NSInteger)value2;
{
    return [str substringWithRange:NSMakeRange(value1,value2)];
}
#pragma mark --- 单例 ---
+(instancetype)shareRegExpUtils
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        utils = [[DWRegExpUtils alloc] init];
        provinceDic = @{@"11":@"北京",@"12":@"天津",@"13":@"河北",@"14":@"山西",@"15":@"内蒙古",@"21":@"辽宁",@"22":@"吉林",@"23":@"黑龙江",@"31":@"上海",@"32":@"江苏",@"33":@"浙江",@"34":@"安徽",@"35":@"福建",@"36":@"江西",@"37":@"山东",@"41":@"河南",@"42":@"湖北",@"43":@"湖南",@"44":@"广东",@"45":@"广西",@"46":@"海南",@"50":@"重庆",@"51":@"四川",@"52":@"贵州",@"53":@"云南",@"54":@"西藏",@"61":@"陕西",@"62":@"甘肃",@"63":@"青海",@"64":@"宁夏",@"65":@"新疆",@"71":@"台湾",@"81":@"香港",@"82":@"澳门",@"91":@"国外"};
    });
    return utils;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        utils = [super allocWithZone:zone];
        provinceDic = @{@"11":@"北京",@"12":@"天津",@"13":@"河北",@"14":@"山西",@"15":@"内蒙古",@"21":@"辽宁",@"22":@"吉林",@"23":@"黑龙江",@"31":@"上海",@"32":@"江苏",@"33":@"浙江",@"34":@"安徽",@"35":@"福建",@"36":@"江西",@"37":@"山东",@"41":@"河南",@"42":@"湖北",@"43":@"湖南",@"44":@"广东",@"45":@"广西",@"46":@"海南",@"50":@"重庆",@"51":@"四川",@"52":@"贵州",@"53":@"云南",@"54":@"西藏",@"61":@"陕西",@"62":@"甘肃",@"63":@"青海",@"64":@"宁夏",@"65":@"新疆",@"71":@"台湾",@"81":@"香港",@"82":@"澳门",@"91":@"国外"};
    });
    return utils;
}

@end

@implementation DWRegExpMaker

-(DWRegExpMaker *(^)(DWRegExpComponent, NSString *, DWRegExpCondition, NSUInteger, NSUInteger))AddConditionWithComponentType
{
    return ^(DWRegExpComponent component,NSString * additionalString,DWRegExpCondition condition,NSUInteger minCount,NSUInteger maxCount){
        NSString * componentStr = [self.utils dw_GetRegExpComponentStringWithComponents:component additionalString:additionalString];
        handleConfigWithRange(self, componentStr, condition, minCount, maxCount);
        return self;
    };
}

-(DWRegExpMaker *(^)(NSString *, DWRegExpCondition, NSUInteger, NSUInteger))AddConditionWithComponentRegExpString
{
    return ^(NSString * regExpStr,DWRegExpCondition condition,NSUInteger minCount,NSUInteger maxCount){
        handleConfigWithRange(self, regExpStr, condition, minCount, maxCount);
        return self;
    };
}

-(DWRegExpMaker *(^)(NSString *, DWRegExpCondition))AddConditionWithCompleteRegExpString
{
    return ^(NSString * regExpStr,DWRegExpCondition condition){
        handleConfig(self, regExpStr, condition);
        return self;
    };
}

static inline void handleConfigWithRange(DWRegExpMaker * maker,NSString * regExpStr,DWRegExpCondition condition,NSUInteger minCount,NSUInteger maxCount)
{
    NSDictionary * config = [maker.utils dw_CreateRegExpConfigWithComponent:regExpStr condition:condition minCount:minCount maxCount:maxCount];
    [maker.utils.configs addObject:config];
}

static inline void handleConfig(DWRegExpMaker * maker,NSString * regExpStr,DWRegExpCondition condition){
    NSDictionary * config = [maker.utils dw_CreateRegExpConfigWithRegExpString:regExpStr condition:condition];
    [maker.utils.configs addObject:config];
}

@end
