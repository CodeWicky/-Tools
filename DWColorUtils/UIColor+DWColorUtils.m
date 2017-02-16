//
//  UIColor+DWColorUtils.m
//  DWColorUtils
//
//  Created by Wicky on 16/10/29.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#import "UIColor+DWColorUtils.h"
#import <objc/runtime.h>

#define __DW__Value__(x) \
-(CGFloat)x\
{\
    if (!self.colorConfigs) {\
        [self getColorConfigs];\
    }\
    return [self.colorConfigs[NSStringFromSelector(_cmd)] floatValue];\
}\


@interface UIColor ()

@property (nonatomic ,strong) NSDictionary * colorConfigs;

@end

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

-(BOOL)isEqualToColor:(UIColor *)color
{
    return CGColorEqualToColor(self.CGColor, color.CGColor);
}

-(UIColor *(^)(CGFloat))alphaWith
{
    return ^(CGFloat alpha){
        return [self colorWithAlphaComponent:alpha];
    };
}

-(void)getColorConfigs
{
    NSInteger numComponents = CGColorGetNumberOfComponents(self.CGColor);
    if (numComponents == 4)
    {
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        const CGFloat *components = CGColorGetComponents(self.CGColor);
        dic[@"red"] = @(components[0]);
        dic[@"green"] = @(components[1]);
        dic[@"blue"] = @(components[2]);
        dic[@"alpha"] = @(components[3]);
        self.colorConfigs = [dic copy];
    }
}

-(NSDictionary *)colorConfigs
{
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setColorConfigs:(NSDictionary *)colorConfigs
{
    objc_setAssociatedObject(self, @selector(colorConfigs), colorConfigs, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

__DW__Value__(red)
__DW__Value__(green)
__DW__Value__(blue)
__DW__Value__(alpha)
@end
