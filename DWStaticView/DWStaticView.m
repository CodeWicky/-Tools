//
//  DWStaticView.m
//  Protocol
//
//  Created by Wicky on 2017/2/16.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "DWStaticView.h"

@interface DWStaticView ()

@property (nonatomic ,strong) UIImage * staticBackImage;

@property (nonatomic ,strong) NSMutableArray <UIView *>* inner_staticBackSubviews;

@end

@implementation DWStaticView

-(void)addStaticBackSubview:(UIView *)view
{
    if (!view) {
        return;
    }
    if (self.staticBackLayer) {
        if (view.superview) {
            [view removeFromSuperview];
        }
        NSInteger index = [self.inner_staticBackSubviews indexOfObject:view];
        if (index == NSNotFound) {
            [self.inner_staticBackSubviews addObject:view];
        } else {
            [self.inner_staticBackSubviews removeObjectAtIndex:index];
            [self.inner_staticBackSubviews addObject:view];
        }
        [self setNeedsRedrawStaticView];
    } else {
        [self addSubview:view];
    }
}

-(void)insertStaticBackSubview:(UIView *)view aboveSubview:(UIView *)siblingSubview {
    if (!view) {
        return;
    }
    if (self.staticBackLayer) {
        if (view.superview) {
            [view removeFromSuperview];
        }
        if (![self.inner_staticBackSubviews containsObject:siblingSubview]) {
            [self.inner_staticBackSubviews addObject:view];
        } else {
            if ([view isEqual:siblingSubview]) {
                return;
            }
            NSUInteger idx = [self.inner_staticBackSubviews indexOfObject:siblingSubview] + 1;
            [self.inner_staticBackSubviews insertObject:view atIndex:idx];
        }
        [self setNeedsRedrawStaticView];
    } else {
        [self insertSubview:view aboveSubview:siblingSubview];
    }
}

-(void)insertStaticBackSubview:(UIView *)view belowSubview:(UIView *)siblingSubview
{
    if (!view) {
        return;
    }
    if (self.staticBackLayer) {
        if (view.superview) {
            [view removeFromSuperview];
        }
        if (![self.inner_staticBackSubviews containsObject:siblingSubview]) {
            [self.inner_staticBackSubviews addObject:view];
        } else {
            if ([view isEqual:siblingSubview]) {
                return;
            }
            NSUInteger idx = [self.inner_staticBackSubviews indexOfObject:siblingSubview];
            [self.inner_staticBackSubviews insertObject:view atIndex:idx];
        }
        [self setNeedsRedrawStaticView];
    } else {
        [self insertSubview:view belowSubview:siblingSubview];
    }
}

-(void)removeStaticBackSubview:(UIView *)view
{
    if (!view) {
        return;
    }
    if (self.staticBackLayer) {
        if ([self.inner_staticBackSubviews containsObject:view]) {
            [self.inner_staticBackSubviews removeObject:view];
            [self setNeedsRedrawStaticView];
        }
    } else {
        if ([view.superview isEqual:self]) {
            [view removeFromSuperview];
        }
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    if (self.staticBackLayer) {
        [self drawStaticBackView];
    }
}

-(void)setNeedsRedrawStaticView {
    self.staticBackImage = nil;
    [self setNeedsLayout];
}

-(void)drawStaticBackView
{
    if (!self.staticBackImage) {
        UIView * tempView = [[UIView alloc] initWithFrame:self.bounds];
        
        [self.inner_staticBackSubviews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [tempView addSubview:obj];
        }];
        
        UIGraphicsBeginImageContextWithOptions(tempView.bounds.size, NO, [UIScreen mainScreen].scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [tempView.layer renderInContext:context];
        self.staticBackImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    self.layer.contents = (__bridge id)(self.staticBackImage.CGImage);
}

-(NSMutableArray<UIView *> *)inner_staticBackSubviews
{
    if (!_inner_staticBackSubviews) {
        _inner_staticBackSubviews = [NSMutableArray array];
    }
    return _inner_staticBackSubviews;
}

-(NSArray<UIView *> *)staticBackSubviews {
    return [self.inner_staticBackSubviews copy];
}

@end
