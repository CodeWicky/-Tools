//
//  NSDictionary+DWDictionaryUtils.m
//  Contact
//
//  Created by Wicky on 2017/5/25.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "NSDictionary+DWDictionaryUtils.h"

@implementation NSDictionary (DWDictionaryLogUtils)

-(NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level {
    NSArray *allKeys = [self allKeys];
    NSString * footerBlank = @"";
    for (int i = 0; i < level; i++) {
        footerBlank = [footerBlank stringByAppendingString:@"\t"];
    }
    NSMutableString *str = [[NSMutableString alloc] initWithFormat:@"{"];
    NSString * contentBlank = [footerBlank stringByAppendingString:@"\t"];
    for (NSString *key in allKeys) {
        id value= self[key];
        if ([value respondsToSelector:@selector(descriptionWithLocale:indent:)]) {
            value = [value descriptionWithLocale:locale indent:level + 1];
        }
        [str appendFormat:@"\n%@\"%@\" = %@,",contentBlank,key,value];
    }
    if (allKeys.count) {
        [str deleteCharactersInRange:NSMakeRange(str.length - 1, 1)];
    }
    [str appendString:[NSString stringWithFormat:@"\n%@}",footerBlank]];
    return str;
}

@end
