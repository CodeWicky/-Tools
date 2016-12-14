//
//  UIImage+DWImageUtils.h
//  Image
//
//  Created by Wicky on 2016/12/6.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,DWContentMode)//图片填充模式
{
    DWContentModeScaleAspectFit,//适应模式
    DWContentModeScaleAspectFill,//填充模式
    DWContentModeScaleToFill//拉伸模式
};
@interface UIImage (DWImageUtils)
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
-(UIImage *)dw_CornerRadius:(CGFloat)radius withWidth:(CGFloat)width contentMode:(DWContentMode)mode;

///按给定path剪裁图片
/**
 path:路径，剪裁区域。
 mode:填充模式
 
 注:
 1.路径中心对应图片中心
 2.路径只决定剪裁图形，不影响剪裁位置
 */
-(UIImage *)dw_ClipImageWithPath:(UIBezierPath *)path mode:(DWContentMode)mode;

///按给定颜色生层图片
+(UIImage *)dw_ImageWithColor:(UIColor *)color;

///获取旋转角度的图片
/**
 注:角度计数单位为弧度制
 */
-(UIImage *)dw_RotateImageWithAngle:(CGFloat)angle;


///以灰色空间生成图片
-(UIImage *)dw_ConvertToGrayImage;

///取图片某点颜色
/**
 point:取色点
 
 注:以图片自身宽高作为坐标系
 */
-(UIColor *)dw_ColorAtPoint:(CGPoint)point;

///转换图片为Base64字符串
-(NSString *)dw_ImageToBase64String;

///Base64转换为图片
+ (UIImage *)dw_ImageWithBase64String:(NSString *)base64String;
#pragma mark ---以下代码来自网络---
///纠正图片方向
-(UIImage *)dw_FixOrientation;

///按给定的方向旋转图片
-(UIImage*)dw_RotateWithOrient:(UIImageOrientation)orient;

///垂直翻转
-(UIImage *)dw_FlipVertical;

///水平翻转
-(UIImage *)dw_FlipHorizontal;

///截取当前image对象rect区域内的图像
-(UIImage *)dw_SubImageWithRect:(CGRect)rect;

///压缩图片至指定尺寸
-(UIImage *)dw_RescaleImageToSize:(CGSize)size;

///压缩图片至指定像素
-(UIImage *)dw_RescaleImageToPX:(CGFloat )toPX;

///在指定的size里面生成一个平铺的图片
-(UIImage *)dw_GetTiledImageWithSize:(CGSize)size;

///UIView转化为UIImage
+(UIImage *)dw_ImageFromView:(UIView *)view;

///将两个图片生成一张图片
+(UIImage*)dw_MergeImage:(UIImage*)firstImage withImage:(UIImage*)secondImage;
@end
