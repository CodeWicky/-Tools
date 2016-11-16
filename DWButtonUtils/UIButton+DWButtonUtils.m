//
//  UIButton+DWButtonUtils.m
//  test
//
//  Created by Wicky on 2016/11/16.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#import "UIButton+DWButtonUtils.h"
#import <objc/runtime.h>

@interface UIButton ()

@property (nonatomic ,assign) BOOL ignoreClick;

@end

@implementation UIButton (DWButtonUtils)

+(void)load
{
    Method origin = class_getInstanceMethod(self, @selector(sendAction:to:forEvent:));
    Method destination = class_getInstanceMethod(self, @selector(dw_sendAction:to:forEvent:));
    method_exchangeImplementations(origin, destination);
}

-(void)dw_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    if (self.ignoreClick) {
        return;
    }
    if (self.dw_IgnoreClickInterval > 0) {
        self.ignoreClick = YES;
        [self performSelector:@selector(setIgnoreClick:) withObject:@(NO) afterDelay:self.dw_IgnoreClickInterval];
    }
    [self dw_sendAction:action to:target forEvent:event];
}

#pragma mark ---setter、getter---
-(void)setDw_IgnoreClickInterval:(NSTimeInterval)dw_IgnoreClickInterval
{
    objc_setAssociatedObject(self, @selector(dw_IgnoreClickInterval), @(dw_IgnoreClickInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSTimeInterval)dw_IgnoreClickInterval
{
    return [objc_getAssociatedObject(self, _cmd) doubleValue];
}

-(void)setIgnoreClick:(BOOL)ignoreClick
{
    objc_setAssociatedObject(self, @selector(ignoreClick), @(ignoreClick), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)ignoreClick
{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

-(void)setDw_EnlargeRect:(UIEdgeInsets)dw_EnlargeRect
{
    objc_setAssociatedObject(self, @selector(dw_EnlargeRect), [NSValue valueWithUIEdgeInsets:dw_EnlargeRect], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIEdgeInsets)dw_EnlargeRect
{
    return [objc_getAssociatedObject(self, _cmd) UIEdgeInsetsValue];
}

-(CGRect)enlargedRect
{
    CGFloat topEdge = self.dw_EnlargeRect.top;
    CGFloat leftEdge = self.dw_EnlargeRect.left;
    CGFloat bottomEdge = self.dw_EnlargeRect.bottom;
    CGFloat rightEdge = self.dw_EnlargeRect.right;
    
    if (topEdge || rightEdge || bottomEdge || leftEdge)
    {
        return CGRectMake(self.bounds.origin.x - leftEdge,
                          self.bounds.origin.y - topEdge,
                          self.bounds.size.width + leftEdge + rightEdge,
                          self.bounds.size.height + topEdge + bottomEdge);
    }
    else
    {
        return self.bounds;
    }
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect rect = [self enlargedRect];
    if (CGRectEqualToRect(rect, self.bounds))
    {
        return [super pointInside:point withEvent:event];
    }
    return CGRectContainsPoint(rect, point) ? YES : NO;
}
@end
