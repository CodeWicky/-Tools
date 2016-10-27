//
//  DecimalExtension.h
//  DWHUD
//
//  Created by Wicky on 16/10/25.
//  Copyright © 2016年 Wicky. All rights reserved.
//

/*
 DecimalExtension
 
 补充一些数学运算
 */
#import <UIKit/UIKit.h>
@interface DecimalExtension : NSObject
/*
 x按四舍五入保留y位小数
 */
CGFloat roundX(CGFloat x,int y);
/*
 x按五入保留y位小数
 */
CGFloat ceilX(CGFloat x,int y);
/*
 x按四舍保留y位小数
 */
CGFloat floorX(CGFloat x,int y);
/*
 返回10的x次方
 */
int pow10x(int x);
/**
 返回x的平方
 */
CGFloat powX2(CGFloat x);
/**
 返回x的立方
 */
CGFloat powX3(CGFloat x);
/**
 返回平均数
 */
CGFloat avr(CGFloat x,CGFloat y);
/**
 角度转弧度
 */
CGFloat radianFromDegree(CGFloat degree);
/**
 弧度转角度
 */
CGFloat degreeFromRadian(CGFloat radian);
/**
 余弦定理计算角度
 a、b:夹边
 c:对边
 
 若返回-1则说明当前参数无法构成三角形
 */
CGFloat angleFromCosinesLaw(CGFloat a,CGFloat b,CGFloat c);
/**
 余弦定理计算对边
 a、b:夹边
 alpha:夹角
 
 若返回-1则说明夹角数值不合法
 */
CGFloat lengthFromCosinesLaw(CGFloat a,CGFloat b,CGFloat alpha);
/**
 返回点2到点1连线与x轴正方向夹角
 */
CGFloat angleFromTwoPoint(CGFloat x1,CGFloat y1,CGFloat x2,CGFloat y2);
@end
