//
//  UIColor+DWColorUtils.m
//  DWColorUtils
//
//  Created by Wicky on 16/10/29.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#import "UIColor+DWColorUtils.h"

@implementation UIColor (DWColorUtils)
+(instancetype)colorWithRGBString:(NSString *)string alpha:(CGFloat)alpha
{
    string = [string stringByReplacingOccurrencesOfString:@"#" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"0X" withString:@""];
    NSString * red = [string substringToIndex:2];
    NSString * green = [string substringWithRange:NSMakeRange(2, 2)];
    NSString * blue = [string substringFromIndex:4];
    unsigned int r,g,b;
    [[NSScanner scannerWithString:red] scanHexInt:&r];
    [[NSScanner scannerWithString:green] scanHexInt:&g];
    [[NSScanner scannerWithString:blue] scanHexInt:&b];
    return [UIColor colorWithRed:r / 255.0 green:g /255.0 blue:b / 255.0 alpha:alpha];
}

+(instancetype)colorWithRGBString:(NSString *)string
{
    return [UIColor colorWithRGBString:string alpha:1];
}

-(UIColor *(^)(CGFloat))alphaWith
{
    return ^(CGFloat alpha){
        return [self colorWithAlphaComponent:alpha];
    };
}
@end
