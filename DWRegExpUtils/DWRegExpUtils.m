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

-(NSString *)dw_GetRegExpComponentStringWithComponents:(DWRegExpComponent)components
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

///追加范围
static inline NSString * handleRange(NSString * component,NSUInteger min,NSUInteger max,BOOL preSearch){
    if (max != DWINTEGERNULL) {
        if (min == DWINTEGERNULL) {
            min = 0;
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

@end

@implementation DWRegExpMaker

-(DWRegExpMaker *(^)(DWRegExpComponent, DWRegExpCondition, NSUInteger, NSUInteger))AddConditionWithComponentType
{
    return ^(DWRegExpComponent component,DWRegExpCondition condition,NSUInteger minCount,NSUInteger maxCount){
        NSString * componentStr = [self.utils dw_GetRegExpComponentStringWithComponents:component];
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
