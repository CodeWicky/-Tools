//
//  NSString+DWStringUtils.m
//  RegExp
//
//  Created by Wicky on 17/1/8.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "NSString+DWStringUtils.h"

@implementation NSString (DWStringUtils)
+(NSString *)stringWithMetaString:(NSString *)meta count:(NSUInteger)count
{
    NSString * string = [NSString stringWithFormat:@"%.0f",pow(10, count)];
    string = [string substringFromIndex:1];
    string = [string stringByReplacingOccurrencesOfString:@"0" withString:meta];
    return string;
}
@end
