//
//  UIBezierPath+DWPathUtils.m
//  DWHUD
//
//  Created by Wicky on 16/10/23.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#import "UIBezierPath+DWPathUtils.h"

@implementation DWPathMaker

-(DWPathMaker *(^)(CGFloat, CGFloat))MoveTo
{
    return ^(CGFloat x,CGFloat y){
        [self.path moveToPoint:CGPointMake(x, y)];
        return self;
    };
}

-(DWPathMaker *(^)(CGFloat, CGFloat))AddLineTo
{
    return ^(CGFloat x,CGFloat y){
        [self.path addLineToPoint:CGPointMake(x, y)];
        return self;
    };
}

-(DWPathMaker *(^)(CGFloat,CGFloat ,CGFloat ,CGFloat ,CGFloat  ,BOOL))AddArcWithAngle
{
    return ^(CGFloat x,CGFloat y,CGFloat radius,CGFloat startAngle,CGFloat endAngle,BOOL clockwise){
        [self.path addArcWithCenter:CGPointMake(x, y) radius:radius startAngle:startAngle endAngle:endAngle clockwise:clockwise];
        return self;
    };
}

-(DWPathMaker *(^)(CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, BOOL,BOOL))AddArcWithPoint
{
    return ^(CGFloat startX,CGFloat startY,CGFloat endX,CGFloat endY,CGFloat radius,BOOL clockwise,BOOL moreThanHalf){
        [self.path addArcWithStartPoint:CGPointMake(startX, startY) endPoint:CGPointMake(endX, endY) radius:radius clockwise:clockwise moreThanHalf:moreThanHalf];
        return self;
    };
}

-(DWPathMaker *(^)(CGFloat, CGFloat, CGFloat, CGFloat))AddQuadCurve
{
    return ^(CGFloat pointX,CGFloat pointY,CGFloat controlX,CGFloat controlY){
        [self.path addQuadCurveToPoint:CGPointMake(pointX, pointY) controlPoint:CGPointMake(controlX, controlY)];
        return self;
    };
}

-(DWPathMaker *(^)(CGFloat, CGFloat, CGFloat, CGFloat, CGFloat, CGFloat))AddCurve
{
    return ^(CGFloat pointX,CGFloat pointY,CGFloat controlX1,CGFloat controlY1,CGFloat controlX2,CGFloat controlY2){
        [self.path addCurveToPoint:CGPointMake(pointX, pointY) controlPoint1:CGPointMake(controlX1, controlY1) controlPoint2:CGPointMake(controlX2, controlY2)];
        return self;
    };
}

-(DWPathMaker *(^)(CGFloat, CGFloat, CGFloat, CGFloat, CGFloat))AddSin
{
    return ^(CGFloat A,CGFloat Omega,CGFloat Phi,CGFloat K,CGFloat deltaX){
        [self.path addSinWithA:A Omega:Omega Phi:Phi K:K deltaX:deltaX];
        return self;
    };
}

-(DWPathMaker *(^)())ClosePath
{
    return ^(){
        [self.path closePath];
        return self;
    };
}

@end
@implementation UIBezierPath (DWPathUtils)

+(instancetype)bezierPathWithPathMaker:(void (^)(DWPathMaker *maker))pathMaker
{
    UIBezierPath * path = [UIBezierPath bezierPath];
    if (pathMaker) {
        DWPathMaker * maker = [[DWPathMaker alloc] init];
        maker.path = path;
        pathMaker(maker);
    }
    return path;
}

+(instancetype)bezierPathWithStartPoint:(CGPoint)startP endPoint:(CGPoint)endP radius:(CGFloat)radius clockwise:(BOOL)clockwise moreThanHalf:(BOOL)moreThanHalf
{
    UIBezierPath * path = [UIBezierPath bezierPath];
    [path moveToPoint:startP];
    [path addArcWithStartPoint:startP endPoint:endP radius:radius clockwise:clockwise moreThanHalf:moreThanHalf];
    return path;
}

+(instancetype)bezierPathWithSinStartPoint:(CGPoint)startP A:(CGFloat)A Omega:(CGFloat)Omega Phi:(CGFloat)Phi K:(CGFloat)K deltaX:(CGFloat)deltaX
{
    UIBezierPath * path = [UIBezierPath bezierPath];
    [path moveToPoint:startP];
    [path addSinWithA:A Omega:Omega Phi:Phi K:K deltaX:deltaX];
    return path;
}

-(void)addArcWithStartPoint:(CGPoint)startP endPoint:(CGPoint)endP radius:(CGFloat)radius clockwise:(BOOL)clockwise moreThanHalf:(BOOL)moreThanHalf
{
    CGPoint center = [self getCenterFromFirstPoint:startP secondPoint:endP radius:radius clockwise:clockwise moreThanhalf:moreThanHalf];
    CGFloat startA = [self getAngleFromFirstPoint:center secondP:startP clockwise:clockwise moreThanHalf:moreThanHalf];
    CGFloat endA = [self getAngleFromFirstPoint:center secondP:endP clockwise:clockwise moreThanHalf:moreThanHalf];
    [self addArcWithCenter:center radius:radius startAngle:startA endAngle:endA clockwise:clockwise];
}

-(void)addSinWithA:(CGFloat)A Omega:(CGFloat)Omega Phi:(CGFloat)Phi K:(CGFloat)K deltaX:(CGFloat)deltaX
{
    CGPoint originPoint = self.currentPoint;
    
    CGPoint currentPoint = self.currentPoint;
    CGFloat currentX = 0;
    CGFloat step = 0.05;
    while (currentX <= deltaX) {
        currentX += step;
        currentPoint = CGPointMake(currentPoint.x + step, currentPoint.y - deltaSinValueWith(currentX, A, Omega, Phi, K, step));
        [self addLineToPoint:currentPoint];
    }
    
    if (currentX != deltaX) {
        step = deltaX;
        [self addLineToPoint:CGPointMake(originPoint.x + step, originPoint.y - deltaSinValueWith(deltaX, A, Omega, Phi, K, step))];
    }
}

CGFloat sinValueWith(CGFloat x,CGFloat A,CGFloat Omega,CGFloat Phi,CGFloat K){
    return A * sinf(Omega * x + Phi) + K;
}

CGFloat deltaSinValueWith(CGFloat x,CGFloat A,CGFloat Omega,CGFloat Phi,CGFloat K ,CGFloat step){
    return sinValueWith(x, A, Omega, Phi, K) - sinValueWith(x - step, A, Omega, Phi, K);
}

///根据两点、半径、顺逆时针获取圆心
-(CGPoint)getCenterFromFirstPoint:(CGPoint)firstP
                      secondPoint:(CGPoint)secondP
                           radius:(CGFloat)radius
                        clockwise:(BOOL)clockwise
                     moreThanhalf:(BOOL)moreThanHalf
{
    CGFloat centerX = 0.5 * secondP.x - 0.5 * firstP.x;
    CGFloat centerY = 0.5 * firstP.y - 0.5 * secondP.y;
    centerX = round6f(centerX);
    centerY = round6f(centerY);
    radius = round6f(radius);
    ///获取相似三角形相似比例
    CGFloat scale = sqrt((pow(radius, 2) - (pow(centerX, 2) + pow(centerY, 2))) / (pow(centerX, 2) + pow(centerY, 2)));
    scale = round6f(scale);
        if (clockwise != moreThanHalf) {
            return CGPointMake(centerX + centerY * scale + firstP.x, - centerY + centerX * scale + firstP.y);
        }
        else
        {
            return CGPointMake(centerX - centerY * scale + firstP.x, - centerY - centerX * scale + firstP.y);
        }
}

///保留6位小数
CGFloat round6f(CGFloat x){
    return roundf(x * 1000000) / 1000000.0;
}

///获取第二点相对第一点的角度
-(CGFloat)getAngleFromFirstPoint:(CGPoint)firstP
                         secondP:(CGPoint)secondP
                       clockwise:(BOOL)clockwise
                    moreThanHalf:(BOOL)moreThanHalf
{
    CGFloat deltaX = secondP.x - firstP.x;
    CGFloat deltaY = secondP.y - firstP.y;
    deltaX = round6f(deltaX);
    deltaY = round6f(deltaY);
    if (deltaY > 0) {
        return atan(deltaY / deltaX);
    }
    if (deltaY == 0) {
        if (deltaX >= 0) {
            return 0;
        }
        else
        {
            return M_PI;
        }
    }
    else
    {
        return atan(deltaY / deltaX) + ((clockwise != moreThanHalf)?M_PI:0);
    }
}

@end
