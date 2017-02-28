//
//  DWRegexUtils.m
//  Regex
//
//  Created by Wicky on 2016/12/27.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#import "DWRegexUtils.h"

@interface DWRegexUtils ()

@property (nonatomic ,strong) NSMutableArray * configs;

@end

@interface DWRegexMaker()

@property (nonatomic ,strong) DWRegexUtils * utils;

@end
static DWRegexUtils * utils = nil;

static NSDictionary * provinceDic = nil;
@implementation DWRegexUtils

+(NSString *)dw_GetRegexStringWithMaker:(void (^)(DWRegexMaker *))stringMaker
{
    DWRegexUtils * utils = [DWRegexUtils new];
    if (stringMaker) {
        DWRegexMaker * maker = [[DWRegexMaker alloc] init];
        maker.utils = utils;
        stringMaker(maker);
    }
    return [utils dw_GetRegexStringWithConfigs:utils.configs];
}

-(NSString *)dw_GetRegexComponentStringWithComponents:(DWRegexComponent)components additionalString:(NSString *)addition
{
    NSString * regExp = @"";
    if (components & DWRegexComponentEntire) {
        return @"\\s\\S";
    }
    if (components & DWRegexComponentEntireExceptLF) {
        return @".";
    }
    if (components & DWRegexComponentNumber) {
        regExp = [regExp stringByAppendingString:@"\\d"];
    }
    if (components & DWRegexComponentLowercaseLetter) {
        regExp = [regExp stringByAppendingString:@"a-z"];
    }
    if (components & DWRegexComponentUppercaseLetter) {
        regExp = [regExp stringByAppendingString:@"A-Z"];
    }
    if (components & DWRegexComponentChinese) {
        regExp = [regExp stringByAppendingString:@"\\u4E00-\\u9FA5"];
    }
    if (components & DWRegexComponentSymbol) {
        regExp = [regExp stringByAppendingString:@"\\W_"];
    }
    if (addition.length) {
        regExp = [regExp stringByAppendingString:addition];
    }
    return regExp;
}

+(BOOL)dw_ValidateString:(NSString *)string withRegexString:(NSString *)regExp
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regExp];
    return [predicate evaluateWithObject:string];
}

-(NSDictionary *)dw_CreateRegexConfigWithComponent:(NSString *)component condition:(DWRegexCondition)condition minCount:(NSUInteger)min maxCount:(NSUInteger)max greedy:(BOOL)greedy
{
    if (component.length == 0) {
        return nil;
    }
    if ([component isEqualToString:@"."]) {
        component = handleRange(component, min, max, greedy, YES);
    }
    else
    {
        switch (condition) {
            case DWRegexConditionPreSearchAllIS:
                component = [NSString stringWithFormat:@"(?=[%@]+$)",component];
                break;
            case DWRegexConditionPreSearchAllNot:
                component = [NSString stringWithFormat:@"(?!.*[%@]",component];
                if (min == DWINTEGERNULL || min == 0) {
                    min = 1;
                }
                component = handleRange(component, min, max,YES,YES);
                component = [NSString stringWithFormat:@"%@.*)",component];
                break;
            case DWRegexConditionPreSearchNotAll:
                component = [NSString stringWithFormat:@"(?![%@]+$)",component];
                break;
            case DWRegexConditionPreSearchContain:
                component = [NSString stringWithFormat:@"(?=.*[%@]",component];
                if (min == DWINTEGERNULL || min == 0) {
                    min = 1;
                }
                component = handleRange(component, min, max,YES,YES);
                component = [NSString stringWithFormat:@"%@)",component];
                break;
            case DWRegexConditionContain:
            {
                component = [NSString stringWithFormat:@"[%@]",component];
                component = handleRange(component, min, max,greedy,NO);
            }
                break;
            case DWRegexConditionWithout:
            {
                component = [NSString stringWithFormat:@"[^%@]",component];
                component = handleRange(component, min, max,YES,NO);
            }
                break;
            default:
                break;
        }
    }
    return [self dw_CreateRegexConfigWithRegexString:component condition:condition];
}

-(NSDictionary *)dw_CreateRegexConfigWithRegexString:(NSString *)regExpString condition:(DWRegexCondition)condition
{
    return @{@"component":regExpString,@"condition":@(condition)};
}

-(NSString *)dw_GetRegexStringWithConfigs:(NSArray *)configs
{
    NSMutableString * preS = [NSMutableString stringWithFormat:@"()"];
    NSMutableString * regS = [NSMutableString stringWithFormat:@""];
    [configs enumerateObjectsUsingBlock:^(NSDictionary * dic, NSUInteger idx, BOOL * _Nonnull stop) {
        DWRegexCondition condition = [dic[@"condition"] integerValue];
        NSString * component = dic[@"component"];
        if (component.length) {
            switch (condition) {
                case DWRegexConditionPreSearchAllIS:
                case DWRegexConditionPreSearchAllNot:
                case DWRegexConditionPreSearchNotAll:
                case DWRegexConditionPreSearchContain:
                {
                    [preS insertString:component atIndex:1];
                }
                    break;
                case DWRegexConditionContain:
                case DWRegexConditionWithout:
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

+(NSArray<DWRegexResult *> *)dw_GetMatchesStringsInString:(NSString *)string withRegex:(NSString *)regex
{
    NSRegularExpression *RegExp = [NSRegularExpression regularExpressionWithPattern:regex options:0 error:nil];
    NSArray * arr = [RegExp matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    NSMutableArray * results = [NSMutableArray array];
    [arr enumerateObjectsUsingBlock:^(NSTextCheckingResult * result, NSUInteger idx, BOOL * _Nonnull stop) {
        if (result.range.length > 0) {
            DWRegexResult * res = [[DWRegexResult alloc] init];
            res.range = result.range;
            res.result = [string substringWithRange:res.range];
            [results addObject:res];
        }
    }];
    return results.copy;
}

+(NSString *)dw_ReplaceMatchesStringsInString:(NSString *)string withRegex:(NSString *)regex replacement:(NSString *)replacement inRange:(NSRange)range
{
    NSRegularExpression *RegExp = [NSRegularExpression regularExpressionWithPattern:regex options:0 error:nil];
    return [RegExp stringByReplacingMatchesInString:string options:0 range:range withTemplate:replacement];
}

+(BOOL)dw_ValidateString:(NSString *)string withComponents:(DWRegexComponent)components minCount:(NSUInteger)min maxCount:(NSUInteger)max
{
    NSString * regExp = [[DWRegexUtils shareRegexUtils] dw_GetRegexComponentStringWithComponents:components additionalString:nil];
    regExp = [NSString stringWithFormat:@"[%@]",regExp];
    regExp = handleRange(regExp, min, max,YES,NO);
    return [DWRegexUtils dw_ValidateString:string withRegexString:regExp];
}

///追加范围
static inline NSString * handleRange(NSString * component,NSUInteger min,NSUInteger max,BOOL greedy,BOOL preSearch){
    if (max != DWINTEGERNULL) {
        if (min == DWINTEGERNULL) {
            min = 0;
        }
        else if (min == max)
        {
            return [NSString stringWithFormat:@"%@{%lu}",component,min];
        }
        component = [NSString stringWithFormat:@"%@{%lu,%lu}",component,min,max];
        if (!greedy) {
            component = [NSString stringWithFormat:@"%@?",component];
        }
    }
    else
    {
        if (min != DWINTEGERNULL) {
            component = [NSString stringWithFormat:@"%@{%lu,}",component,min];
        }
        else
        {
            if (preSearch) {
                component = [NSString stringWithFormat:@"%@*",component];
            }
            else
            {
                component = [NSString stringWithFormat:@"%@+",component];
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
    return [DWRegexUtils dw_ValidateString:string withRegexString:DWRegexNumber];
}

+(BOOL)dw_ValidateLetter:(NSString *)string
{
    return [DWRegexUtils dw_ValidateString:string withRegexString:DWRegexLetter];
}

+(BOOL)dw_ValidateChinese:(NSString *)string
{
    return [DWRegexUtils dw_ValidateString:string withRegexString:DWRegexChinese];
}

+(BOOL)dw_ValidateSymbol:(NSString *)string
{
    return [DWRegexUtils dw_ValidateString:string withRegexString:DWRegexSymbol];
}

+(BOOL)dw_ValidatePassword:(NSString *)string minLength:(NSUInteger)min maxLength:(NSUInteger)max
{
    return [DWRegexUtils dw_ValidateString:string withRegexString:[NSString stringWithFormat:@"((?![_]+$)(?![a-zA-Z]+$)(?![\\d]+$))[\\da-zA-Z_]{%lu,%lu}",min,max]];
}

+(BOOL)dw_ValidateEmail:(NSString *)string
{
    return [DWRegexUtils dw_ValidateString:string withRegexString:DWRegexEmail];
}

+(BOOL)dw_ValidateMobile:(NSString *)string
{
    return [DWRegexUtils dw_ValidateString:string withRegexString:DWRegexMobile];
}

+(BOOL)dw_ValidateTele:(NSString *)string
{
    return [DWRegexUtils dw_ValidateString:string withRegexString:DWRegexTele];
}

+(BOOL)dw_ValidateURL:(NSString *)string
{
    return [DWRegexUtils dw_ValidateString:string withRegexString:DWRegexURL];
}

+(BOOL)dw_ValidateNatureNumber:(NSString *)string
{
    return [DWRegexUtils dw_ValidateString:string withRegexString:DWRegexNatureNumber];
}

#pragma mark ------ 预置计算验证 ------

+(BOOL)dw_ValidateBankNo:(NSString *)string
{
    NSString *tmpStr = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (![DWRegexUtils dw_ValidateString:string withComponents:(DWRegexComponentNumber) minCount:16 maxCount:19]) {
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
    
    [DWRegexUtils shareRegexUtils];
    
    //判断位数及数字
    if (![DWRegexUtils dw_ValidateString:tmpStr withRegexString:@"\\d{17}[X\\d]"] && ![DWRegexUtils dw_ValidateString:tmpStr withRegexString:@"\\d{15}"]) {
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
+(instancetype)shareRegexUtils
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        utils = [[DWRegexUtils alloc] init];
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

@implementation DWRegexMaker

-(DWRegexMaker *(^)(DWRegexComponent, NSString *, DWRegexCondition, NSUInteger, NSUInteger,BOOL))AddConditionWithComponentType
{
    return ^(DWRegexComponent component,NSString * additionalString,DWRegexCondition condition,NSUInteger minCount,NSUInteger maxCount,BOOL greedy){
        NSString * componentStr = [self.utils dw_GetRegexComponentStringWithComponents:component additionalString:additionalString];
        handleConfigWithRange(self, componentStr, condition, minCount, maxCount,greedy);
        return self;
    };
}

-(DWRegexMaker *(^)(NSString *, DWRegexCondition, NSUInteger, NSUInteger,BOOL))AddConditionWithComponentRegexString
{
    return ^(NSString * regExpStr,DWRegexCondition condition,NSUInteger minCount,NSUInteger maxCount,BOOL greedy){
        handleConfigWithRange(self, regExpStr, condition, minCount, maxCount,greedy);
        return self;
    };
}

-(DWRegexMaker *(^)(NSString *, DWRegexCondition))AddConditionWithCompleteRegexString
{
    return ^(NSString * regExpStr,DWRegexCondition condition){
        handleConfig(self, regExpStr, condition);
        return self;
    };
}

static inline void handleConfigWithRange(DWRegexMaker * maker,NSString * regExpStr,DWRegexCondition condition,NSUInteger minCount,NSUInteger maxCount,BOOL greedy)
{
    NSDictionary * config = [maker.utils dw_CreateRegexConfigWithComponent:regExpStr condition:condition minCount:minCount maxCount:maxCount greedy:greedy];
    [maker.utils.configs addObject:config];
}

static inline void handleConfig(DWRegexMaker * maker,NSString * regExpStr,DWRegexCondition condition){
    NSDictionary * config = [maker.utils dw_CreateRegexConfigWithRegexString:regExpStr condition:condition];
    [maker.utils.configs addObject:config];
}

@end

@implementation DWRegexResult

@end

@implementation NSString (DWRegexUtils)

-(NSArray<DWRegexResult *> *)stringMatchesByRegex:(NSString *)regex
{
    return [DWRegexUtils dw_GetMatchesStringsInString:self withRegex:regex];
}

@end

NSString * const DWRegexNumber = @"\\d+";

NSString * const DWRegexLetter = @"[a-zA-Z]+";

NSString * const DWRegexChinese = @"[\\u4E00-\\u9FA5]+";

NSString * const DWRegexSymbol = @"[\\W_]+";

NSString * const DWRegexEmail = @"^[A-Za-z\\d]+([-_.][A-Za-z\\d]+)*@([A-Za-z\\d]+[-.])*([A-Za-z\\d]+[.])+[A-Za-z\\d]{2,5}$";

NSString * const DWRegexMobile = @"1[34578]\\d{9}";

NSString * const DWRegexTele = @"(0[\\d]{2,3}-)?([2-9][\\d]{6,7})(-[\\d]{1,4})?";

NSString * const DWRegexURL = @"((http|ftp|https)://)?((([a-zA-Z0-9]+[a-zA-Z0-9_-]*\\.)+[a-zA-Z]{2,6})|(([0-9]{1,3}\\.){3}[0-9]{1,3}(:[0-9]{1,4})?))((/[a-zA-Z\\d_]+)*(\\?([a-zA-Z\\d_]+=[a-zA-Z\\d\\u4E00-\\u9FA5\\s\\+%#_-]+&)*([a-zA-Z\\d_]+=[a-zA-Z\\d\\u4E00-\\u9FA5\\s\\+%#_-]+))?)?";

NSString * const DWRegexNatureNumber = @"\\d+(\\.\\d+)?";
