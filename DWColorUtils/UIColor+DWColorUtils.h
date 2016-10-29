//
//  UIColor+DWColorUtils.h
//  DWColorUtils
//
//  Created by Wicky on 16/10/29.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (DWColorUtils)
/**
 返回添加alpha通道的颜色
 */
@property (readonly ,nonatomic ,assign) UIColor *(^alphaWith)(CGFloat alpha);

/**
 以16进制字符串及透明度生成颜色
 */
+(instancetype)colorWithRGBString:(NSString *)string alpha:(CGFloat)alpha;
/**
 以16进制字符串生成颜色
 */
+(instancetype)colorWithRGBString:(NSString *)string;
@end
