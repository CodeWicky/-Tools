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
 */

#import <UIKit/UIKit.h>

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
 startX     圆弧起始点x坐标
 startY     圆弧起始点y坐标
 endX       圆弧终止点x坐标
 endY       圆弧终止点y坐标
 radius     圆弧半径
 clockwise  顺逆时针
 */
@property (nonatomic ,copy) DWPathMaker *(^AddArcWithPoint)(CGFloat startX,CGFloat startY,CGFloat endX,CGFloat endY,CGFloat radius,BOOL clockwise);

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

///闭合曲线
@property (nonatomic ,copy) DWPathMaker *(^ClosePath)();
@end
@interface UIBezierPath (DWPathUtils)

///以block形式生成自定义的贝塞尔曲线（移动点、添加直线、圆弧、贝塞尔曲线、闭合曲线）
+(instancetype)bezierPathWithPathMaker:(void(^)(DWPathMaker * maker))pathMaker;

///以起始终止坐标添加圆弧
-(void)addArcWithStartPoint:(CGPoint)startP endPoint:(CGPoint)endP radius:(CGFloat)radius clockwise:(BOOL)clockwise;

@end
