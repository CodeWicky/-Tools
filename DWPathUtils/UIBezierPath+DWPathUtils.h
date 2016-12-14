//
//  UIBezierPath+DWPathUtils.h
//  DWHUD
//
//  Created by Wicky on 16/10/23.
//  Copyright © 2016年 Wicky. All rights reserved.
//

/*
 UIBezierPath+DWPathUtils
 
 UIBezierPath的扩展类
 
 version 1.0.0
 添加以两点绘制圆弧api
 添加以block形式生成曲线api
 
 version 1.0.1
 引入大于半圆弧概念，修复无法绘制大于半圆弧的问题
 
 version 1.0.2
 添加正弦曲线绘制api，修复计算角度的api错误
 */

#import <UIKit/UIKit.h>

/**
 镜像轴
 */
typedef NS_ENUM(NSUInteger, DWPathUtilsMirrorAxis) {
    DWPathUtilsMirrorAxisX,///x轴镜像
    DWPathUtilsMirrorAxisY///y轴镜像
};

@interface DWPathMaker : NSObject

@property (nonatomic ,strong) UIBezierPath * path;

///移动画笔至点
@property (nonatomic ,copy) DWPathMaker *(^MoveTo)(CGFloat x,CGFloat y);

///添加直线至点
@property (nonatomic ,copy) DWPathMaker *(^AddLineTo)(CGFloat x,CGFloat y);

///以角度添加圆弧
/*
 centerX    圆弧圆心x坐标
 centerY    圆弧圆心y坐标
 radius     圆弧半径
 startAngle 圆弧起始角度
 endAngle   圆弧终止角度
 clockwise  顺逆时针
 
 注：角度均为弧度制
 */
@property (nonatomic ,copy) DWPathMaker *(^AddArcWithAngle)(CGFloat CenterX,CGFloat CenterY,CGFloat radius,CGFloat startAngle,CGFloat endAngle,BOOL clockwise);

///以起始终止坐标添加圆弧
/*
 startX         圆弧起始点x坐标
 startY         圆弧起始点y坐标
 endX           圆弧终止点x坐标
 endY           圆弧终止点y坐标
 radius         圆弧半径
 clockwise      顺逆时针
 moreThanHalf   大于半圆弧
 */
@property (nonatomic ,copy) DWPathMaker *(^AddArcWithPoint)(CGFloat startX,CGFloat startY,CGFloat endX,CGFloat endY,CGFloat radius,BOOL clockwise ,BOOL moreThanHalf);

///添加一次贝塞尔曲线
/*
 pointX     曲线终点x坐标
 pointY     曲线终点y坐标
 controlX   曲线控制点x坐标
 controlY   曲线控制点y坐标
 */
@property (nonatomic ,copy) DWPathMaker *(^AddQuadCurve)(CGFloat pointX,CGFloat pointY,CGFloat controlX,CGFloat controlY);

///添加二次贝塞尔曲线
/*
 pointX     曲线终点x坐标
 pointY     曲线终点y坐标
 controlX1   曲线第一个控制点x坐标
 controlY1   曲线第一个控制点y坐标
 controlX2   曲线第二个控制点x坐标
 controlY2   曲线第二个控制点y坐标
 */
@property (nonatomic ,copy) DWPathMaker *(^AddCurve)(CGFloat pointX,CGFloat pointY,CGFloat controlX1,CGFloat controlY1,CGFloat controlX2,CGFloat controlY2);

///添加正弦曲线
/**
 A      振幅A
 Omega  角速度w
 Phi    相位差
 K      偏移量K
 deltaX 曲线横向长度
 */
@property (nonatomic ,copy) DWPathMaker *(^AddSin)(CGFloat A,CGFloat Omega,CGFloat Phi,CGFloat K,CGFloat deltaX);

///闭合曲线
@property (nonatomic ,copy) DWPathMaker *(^ClosePath)();

///镜像曲线
/**
 path转换为指定bounds的指定中心轴线的镜像路径
 */
@property (nonatomic ,copy) DWPathMaker *(^MirrorPath)(DWPathUtilsMirrorAxis axis,CGRect bounds);

///保证图形区域中心不变以内距形式缩放路径
@property (nonatomic ,copy) DWPathMaker *(^ScalePathWithMargin)(CGFloat margin);

///保证图形区域中心不变以比例形式缩放路径
@property (nonatomic ,copy) DWPathMaker *(^ScalePathWithScale)(CGFloat scale);

///保证图形区域中心不变以角度旋转路径
@property (nonatomic ,copy) DWPathMaker *(^RotatePathWithAngle)(CGFloat angle);

///平移路径
@property (nonatomic ,copy) DWPathMaker *(^TranslatePathWithOffset)(CGFloat offsetX,CGFloat offsetY);

///移动路径至原点
@property (nonatomic ,copy) DWPathMaker *(^PathOriginToZero)();

@end

@interface UIBezierPath (DWPathUtils)

///以block形式生成自定义的贝塞尔曲线（移动点、添加直线、圆弧、贝塞尔曲线、闭合曲线）
+(instancetype)bezierPathWithPathMaker:(void(^)(DWPathMaker * maker))pathMaker;

///以起始终止坐标生成曲线
+(instancetype)bezierPathWithStartPoint:(CGPoint)startP endPoint:(CGPoint)endP radius:(CGFloat)radius clockwise:(BOOL)clockwise moreThanHalf:(BOOL)moreThanHalf;

///生成正弦曲线
+(instancetype)bezierPathWithSinStartPoint:(CGPoint)startP A:(CGFloat)A Omega:(CGFloat)Omega Phi:(CGFloat)Phi K:(CGFloat)K deltaX:(CGFloat)deltaX;

///以起始终止坐标添加圆弧
/**
 startP:        圆弧起点
 endP:          圆弧终点
 radius:        圆弧半径
 clockwise:     顺逆时针
 moreThanHalf:  大于半圆弧
 */
-(void)addArcWithStartPoint:(CGPoint)startP endPoint:(CGPoint)endP radius:(CGFloat)radius clockwise:(BOOL)clockwise moreThanHalf:(BOOL)moreThanHalf;

///绘制正弦曲线
/**
 A      振幅A
 Omega  角速度w
 Phi    相位差
 K      偏移量K
 deltaX 曲线横向长度
 */
-(void)addSinWithA:(CGFloat)A Omega:(CGFloat)Omega Phi:(CGFloat)Phi K:(CGFloat)K deltaX:(CGFloat)deltaX;

///使path以指定bounds的指定轴线做镜像
-(void)dw_MirrorAxis:(DWPathUtilsMirrorAxis)axis inBounds:(CGRect)bounds;

///保证图形区域中心不变以内距形式缩放路径
-(void)dw_ScalePathWithMargin:(CGFloat)margin;

///保证图形区域中心不变以比例形式缩放路径
-(void)dw_ScalePathWithScale:(CGFloat)scale;

///保证图形区域中心不变旋转路径
-(void)dw_RotatePathWithAngle:(CGFloat)angle;

///平移路径
-(void)dw_TranslatePathWithOffsetX:(CGFloat)offsetX offsetY:(CGFloat)offsetY;

///移动path回到原点
-(void)dw_PathOriginToZero;
@end
