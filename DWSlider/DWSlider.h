//
//  DWSlider.h
//  a
//
//  Created by Wicky on 2017/3/21.
//  Copyright © 2017年 Wicky. All rights reserved.
//

/**
 DWSlider
 UISlider替换类
 继承自UIControl重新实现UISlider效果，旨在让开发者更加方便的定制slider参数。同时提供子类化布局接口，扩展性更强。
 
 version 1.0.0
 DWSlider基本功能添加完成
 
 */

#import <UIKit/UIKit.h>

@interface DWSlider : UIControl

///最小有效值
@property (nonatomic ,assign) CGFloat minimumValue;

///最大有效值
@property (nonatomic ,assign) CGFloat maximumValue;

///当前值
@property (nonatomic ,assign) CGFloat value;

///滑块尺寸
@property (nonatomic ,assign) CGSize thumbSize;

///滑块圆角，默认为滑块宽高最小值的0.5倍
@property (nonatomic ,assign) CGFloat thumbCornerRadius;

///滑块滑动范围缩进
@property (nonatomic ,assign) CGFloat thumbMargin;

///滑竿高度
@property (nonatomic ,assign) CGFloat trackHeight;

///滑竿圆角，默认为滑竿高度的0.5倍
@property (nonatomic ,assign) CGFloat trackCornerRadius;

///滑块图片
@property (nonatomic ,strong) UIImage * thumbImage;

///滑竿有效值左侧图片
@property (nonatomic ,strong) UIImage * minTrackImage;

///滑竿有效值右侧图片
@property (nonatomic ,strong) UIImage * maxTrackImage;

///滑竿背景图片
@property (nonatomic ,strong) UIImage * trackBgImage;

///滑竿有效值左侧背景颜色
@property (nonatomic ,strong) UIColor * minTrackColor;

///滑竿有效值右侧背景颜色
@property (nonatomic ,strong) UIColor * maxTrackColor;

///赋值同时是否改变滑块位置
-(void)setValue:(CGFloat)value updateThumb:(BOOL)update;

///更新滑块位置是否需要动画
-(void)updateValueAnimated:(BOOL)animated;

/**
 以下四个方法用于自定义DWSlider子类时改变布局关系时使用
*/
///滑竿尺寸计算方法
-(CGRect)trackRectForBounds:(CGRect)bounds;

///滑块尺寸计算方法
-(CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value;

///滑竿有效值尺寸计算方法
-(CGRect)valueTrackForBounds:(CGRect)bounds;

///滑块缩进值计算方法
-(CGFloat)thumbMarginForBounds:(CGRect)bounds;

@end
