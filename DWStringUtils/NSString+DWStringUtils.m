//
//  NSString+DWStringUtils.m
//  RegExp
//
//  Created by Wicky on 17/1/8.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "NSString+DWStringUtils.h"

@implementation NSString (DWStringUtils)
+(NSString *)stringWithMetaString:(NSString *)metaString count:(NSUInteger)count
{
    NSString * string = [NSString stringWithFormat:@"%.0f",pow(10, count)];
    string = [string substringFromIndex:1];
    string = [string stringByReplacingOccurrencesOfString:@"0" withString:metaString];
    return string;
}

-(CGSize)stringSizeWithFont:(UIFont *)font widthLimit:(CGFloat)widthLimit heightLimit:(CGFloat)heightLimit
{
    return  [self boundingRectWithSize:CGSizeMake(widthLimit, heightLimit) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
}
@end
