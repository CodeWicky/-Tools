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

@property (nonatomic ,copy) void (^actionBlock)(UIButton *);

@end

@implementation UIButton (DWButtonUtils)

+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originSel = @selector(sendAction:to:forEvent:);
        SEL destinationSel = @selector(dw_sendAction:to:forEvent:);
        Method originMethod = class_getInstanceMethod(self, originSel);
        Method destinationMethod = class_getInstanceMethod(self, destinationSel);
        class_addMethod(self, originSel, method_getImplementation(destinationMethod), method_getTypeEncoding(destinationMethod));
        class_replaceMethod(self, destinationSel, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
    });
}

-(void)dw_addActionBlock:(void (^)(UIButton *))action
{
    self.actionBlock = action;
    [self addTarget:self action:@selector(dw_blockBtnAction:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)dw_blockBtnAction:(UIButton *)sender
{
    if (self.actionBlock) {
        self.actionBlock(self);
    }
}

-(void)dw_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    if (![self isKindOfClass:[UIButton class]]) {
        [self dw_sendAction:action to:target forEvent:event];
    }
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

-(void)setActionBlock:(void (^)(UIButton *))actionBlock
{
    objc_setAssociatedObject(self, @selector(actionBlock), actionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(void (^)(UIButton *))actionBlock
{
    return objc_getAssociatedObject(self, _cmd);
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

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect rect = UIEdgeInsetsInsetRect(self.bounds, self.dw_EnlargeRect);
    if (CGRectEqualToRect(rect, self.bounds))
    {
        return [super pointInside:point withEvent:event];
    }
    return CGRectContainsPoint(rect, point) ? YES : NO;
}
@end
