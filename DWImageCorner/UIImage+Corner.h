//
//  UIImage+Corner.h
//  CornerImage
//
//  Created by Wicky on 16/5/8.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,DWContentMode)//图片填充模式
{
    DWContentModeScaleAspectFit,//适应模式
    DWContentModeScaleAspectFill,//填充模式
    DWContentModeScaleToFill//拉伸模式
};
@interface UIImage (Corner)
///获取带圆角的图片
/*
 radius:返回图片的圆角半径
 圆角半径不可超过图片尺寸的1/2,否则按1/2处理
 
 width:返回图片的宽度
 返回的图片为一个宽高相等的矩形区域，但图片且居中显示
 
 mode:返回图片的填充模式
 适应模式:以原图片比例，能显示全部图片的最大尺寸进行填充
 填充模式:以原图片比例，图片能充满容器的最小尺寸进行填充
 拉伸模式:以拉伸图片能够使图片充满容器的尺寸进行填充
 */
-(UIImage *)DWCornerRadius:(CGFloat)radius withWidth:(CGFloat)width contentMode:(DWContentMode)mode;
@end
