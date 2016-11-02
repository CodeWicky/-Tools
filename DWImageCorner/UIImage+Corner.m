//
//  UIImage+Corner.m
//  CornerImage
//
//  Created by Wicky on 16/5/8.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#import "UIImage+Corner.h"

@implementation UIImage (Corner)
-(UIImage *)DWCornerRadius:(CGFloat)radius withWidth:(CGFloat)width contentMode:(DWContentMode)mode
{
    CGFloat originScale = self.size.width / self.size.height;
    CGFloat height = width / originScale;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat maxV = MAX(width, height);
    if (radius < 0) {
        radius = 0;
    }
    UIImage * image = nil;
    CGRect imageFrame;
    if (mode == DWContentModeScaleAspectFit) {//根据图片填充模式制定绘制frame
        if (originScale > 1) {//适应模式
            imageFrame = CGRectMake(0, (width - height) / 2, width,height);
        }
        else
        {
            imageFrame = CGRectMake((height - width) / 2, 0, width, height);
        }
    }
    else if (mode == DWContentModeScaleAspectFill)//填充模式
    {
        CGFloat newHeight;
        CGFloat newWidth;
        if (originScale > 1) {
            newHeight = width;
            newWidth = newHeight * originScale;
            imageFrame = CGRectMake( -(newWidth - newHeight) / 2, 0, newWidth, newHeight);
        }
        else
        {
            newWidth = height;
            newHeight = newWidth / originScale;
            imageFrame = CGRectMake(0, - (newHeight - newWidth) / 2, newWidth, newHeight);
        }
    }
    else//拉伸模式
    {
        imageFrame = CGRectMake(0, 0, maxV, maxV);
    }
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(maxV, maxV), NO, scale);//以最大长度开启图片上下文
    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, maxV, maxV) cornerRadius:radius] addClip];//绘制一个圆形的贝塞尔曲线，并做遮罩
    [self drawInRect:imageFrame];//在指定的frame中绘制图片
    image = UIGraphicsGetImageFromCurrentImageContext();//从当前上下文中获取图片
    UIGraphicsEndImageContext();//关闭上下文
    return image;
}
@end
