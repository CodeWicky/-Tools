//
//  NSDictionary+DWDictionaryUtils.m
//  Contact
//
//  Created by Wicky on 2017/5/25.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "NSDictionary+DWDictionaryUtils.h"

@implementation NSDictionary (DWDictionaryLogUtils)

- (NSString *)descriptionWithLocale:(id)locale
{
    NSArray *allKeys = [self allKeys];
    NSMutableString *str = [[NSMutableString alloc] initWithFormat:@"{\t\n "];
    for (NSString *key in allKeys) {
        id value= self[key];
        [str appendFormat:@"\t \"%@\" = %@,\n",key, value];
    }
    [str appendString:@"}"];
    return str;
}

@end
