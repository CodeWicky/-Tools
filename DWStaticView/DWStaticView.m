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

@end

@implementation DWStaticView

-(void)addStaticBackSubview:(UIView *)view
{
    if (!view) {
        return;
    }
    if (self.staticBackLayer) {
        [self.staticBackSubviews addObject:view];
        [self setNeedsRedrawStaticView];
    } else {
        [self addSubview:view];
    }
}

-(void)insertStaticBackSubview:(UIView *)view belowSubview:(UIView *)siblingSubview
{
    if (!view) {
        return;
    }
    if (self.staticBackLayer) {
        if (![self.staticBackSubviews containsObject:siblingSubview]) {
            [self.staticBackSubviews addObject:view];
        } else {
            NSUInteger idx = [self.staticBackSubviews indexOfObject:siblingSubview];
            
            [self.staticBackSubviews insertObject:view atIndex:idx];
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
        if ([self.staticBackSubviews containsObject:view]) {
            [self.staticBackSubviews removeObject:view];
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
        
        [self.staticBackSubviews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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

-(NSMutableArray<UIView *> *)staticBackSubviews
{
    if (!_staticBackSubviews) {
        _staticBackSubviews = [NSMutableArray array];
    }
    return _staticBackSubviews;
}

@end
