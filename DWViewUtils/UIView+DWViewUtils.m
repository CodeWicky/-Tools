//
//  UIView+DWViewUtils.m
//  a
//
//  Created by Wicky on 2017/3/13.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "UIView+DWViewUtils.h"

@implementation UIView (DWViewFrameUtils)

-(void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

-(void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

-(CGFloat)originX
{
    return self.frame.origin.x;
}

-(void)setOriginX:(CGFloat)originX
{
    CGPoint origin = CGPointMake(originX, self.originY);
    [self setOrigin:origin];
}

-(CGFloat)originY
{
    return self.frame.origin.y;
}

-(void)setOriginY:(CGFloat)originY
{
    CGPoint origin = CGPointMake(self.originX, originY);
    [self setOrigin:origin];
}

-(CGFloat)width
{
    return self.frame.size.width;
}

-(void)setWidth:(CGFloat)width
{
    CGSize size = CGSizeMake(width, self.height);
    [self setSize:size];
}

-(CGFloat)height
{
    return self.frame.size.height;
}

-(void)setHeight:(CGFloat)height
{
    CGSize size = CGSizeMake(self.width, height);
    [self setSize:size];
}

-(CGFloat)top
{
    return self.originY;
}

-(CGFloat)bottom
{
    return self.top + self.height;
}

-(CGFloat)left
{
    return self.originX;
}

-(CGFloat)right
{
    return self.left + self.width;
}

-(CGPoint)topRightPoint
{
    return CGPointMake(self.right, self.top);
}

-(void)setTopRightPoint:(CGPoint)topRightPoint
{
    CGPoint origin = CGPointMake(topRightPoint.x - self.width, topRightPoint.y);
    [self setOrigin:origin];
}

-(CGPoint)bottomLeftPoint
{
    return CGPointMake(self.left, self.bottom);
}

-(void)setBottomLeftPoint:(CGPoint)bottomLeftPoint
{
    CGPoint origin = CGPointMake(bottomLeftPoint.x, bottomLeftPoint.y - self.height);
    [self setOrigin:origin];
}

-(CGPoint)bottomRightPoint
{
    return CGPointMake(self.right, self.bottom);
}

-(void)setBottomRightPoint:(CGPoint)bottomRightPoint
{
    CGPoint origin = CGPointMake(bottomRightPoint.x - self.width, bottomRightPoint.y - self.height);
    [self setOrigin:origin];
}

-(CGPoint)centerOfSelf
{
    return CGPointMake(self.width / 2.0,self.height / 2.0);
}

-(CGFloat)viewCornerR
{
    return self.layer.cornerRadius;
}

-(void)setViewCornerR:(CGFloat)viewCornerR
{
    self.layer.cornerRadius = viewCornerR;
}
@end

@implementation UIView (DWViewHierarchyUtils)

-(BOOL)isInScreen {
    SEL selec = NSSelectorFromString(@"_isInVisibleHierarchy");
    NSMethodSignature * sign = [[UIView class] instanceMethodSignatureForSelector:selec];
    NSInvocation * inv = [NSInvocation invocationWithMethodSignature:sign];
    inv.target = self;
    inv.selector = selec;
    
    BOOL visible = NO;
    [inv invoke];
    [inv getReturnValue:&visible];
    return visible;
}

@end

@implementation UIView (DWViewDecorateUtils)

-(void)dw_AddLineWithFrame:(CGRect)frame color:(UIColor *)color {
    CALayer * line = [CALayer layer];
    line.frame = frame;
    line.backgroundColor = color.CGColor;
    [self.layer addSublayer:line];
}

-(void)dw_AddCorner:(UIRectCorner)corners radius:(CGFloat)radius {
    UIBezierPath * maskP = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer * layer = [CAShapeLayer layer];
    layer.frame = self.bounds;
    layer.fillColor = [UIColor blackColor].CGColor;
    layer.path = maskP.CGPath;
    self.layer.mask = layer;
}

@end
