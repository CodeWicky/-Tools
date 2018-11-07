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

#pragma mark --- interface method ---
-(void)addStaticBackSubview:(UIView *)view {
    
    if (!view) {
        return;
    }
    
    ///保证内部维护一份所有子视图的数组，以便切换staticBackLayer是使用
    NSInteger index = [self.inner_staticBackSubviews indexOfObject:view];
    if (index == NSNotFound) {
        ///如果没有直接添加
        [self.inner_staticBackSubviews addObject:view];
    } else {
        if (index != self.inner_staticBackSubviews.count - 1) {
            ///如果有，移至数组末尾
            [self.inner_staticBackSubviews removeObjectAtIndex:index];
            [self.inner_staticBackSubviews addObject:view];
        }
    }
    
    if (self.staticBackLayer) {
        ///如果存在父视图移除后重绘
        if (view.superview) {
            [view removeFromSuperview];
        }
        [self setNeedsRedrawStaticView];
    } else {
        ///直接添加视图
        [self addSubview:view];
    }
}

-(void)insertStaticBackSubview:(UIView *)view atIndex:(NSInteger)targetIdx {
    if (!view || index < 0) {
        return;
    }
    ///保证内部维护一份所有子视图的数组，以便切换staticBackLayer是使用
    NSInteger index = [self.inner_staticBackSubviews indexOfObject:view];
    if (index == NSNotFound) {
        ///不在层级中，直接插入即可
        [self.inner_staticBackSubviews insertObject:view atIndex:index];
    } else {
        ///在层级中考虑移动
        if (index == targetIdx) {
            ///与当前层级相同，直接返回
            return;
        }
        ///移除
        [self.inner_staticBackSubviews removeObjectAtIndex:index];
        ///移除后要计算targetIdx是否改变
        if (targetIdx > index) {
            --targetIdx;
        }
        ///插入数组
        [self.inner_staticBackSubviews insertObject:view atIndex:targetIdx];
    }
    
    if (self.staticBackLayer) {
        if (view.superview) {
            [view removeFromSuperview];
        }
        [self setNeedsRedrawStaticView];
    } else {
        [self insertSubview:view atIndex:index];
    }
}

-(void)insertStaticBackSubview:(UIView *)view aboveSubview:(UIView *)siblingSubview {
    
    if (!view) {
        return;
    }
    
    ///如果传入空视图，直接添加视图
    if (!siblingSubview) {
        [self addStaticBackSubview:view];
        return;
    }
    
    ///保证内部维护一份所有子视图的数组，以便切换staticBackLayer是使用
    NSInteger index = [self.inner_staticBackSubviews indexOfObject:view];
    NSInteger targetIdx = [self.inner_staticBackSubviews indexOfObject:siblingSubview];
    
    if (targetIdx == NSNotFound) {
        ///如果未找到目标视图则直接添加至顶部
        [self addStaticBackSubview:view];
        return;
    } else {
        ///应走插入逻辑
        ++targetIdx;
        if (index == NSNotFound) {
            ///如果原来不在视图层级中直接插入
            if (targetIdx <= self.inner_staticBackSubviews.count) {
                [self.inner_staticBackSubviews insertObject:view atIndex:targetIdx];
            } else {
                return;
            }
        } else {
            ///在视图层级中，应移除原位在插入对应位
            if ([view isEqual:siblingSubview]) {
                ///如果是一个视图，则不需移位
                return;
            }
            
            ///如果目标index与当前index相等则说明无需移动
            if (targetIdx == index) {
                return;
            }
            
            ///移除
            [self.inner_staticBackSubviews removeObjectAtIndex:index];
            ///移除后要计算targetIdx是否改变
            if (targetIdx > index) {
                --targetIdx;
            }
            ///插入数组
            [self.inner_staticBackSubviews insertObject:view atIndex:targetIdx];
        }
    }
    
    if (self.staticBackLayer) {
        if (view.superview) {
            [view removeFromSuperview];
        }
        [self setNeedsRedrawStaticView];
    } else {
        [self insertSubview:view aboveSubview:siblingSubview];
    }
}

-(void)insertStaticBackSubview:(UIView *)view belowSubview:(UIView *)siblingSubview {
    
    if (!view) {
        return;
    }
    
    ///如果传入空视图，直接添加视图
    if (!siblingSubview) {
        [self addStaticBackSubview:view];
        return;
    }
    
    NSInteger targetIdx = [self.inner_staticBackSubviews indexOfObject:siblingSubview];
    NSInteger index = [self.inner_staticBackSubviews indexOfObject:view];
    
    if (targetIdx == NSNotFound) {
        ///如果未找到目标视图则直接添加至顶部
        [self addStaticBackSubview:view];
        return;
    } else {
        if (index == NSNotFound) {
            ///如果原来不在视图层级中直接插入
            if (targetIdx <= self.inner_staticBackSubviews.count) {
                [self.inner_staticBackSubviews insertObject:view atIndex:targetIdx];
            } else {
                ///这个分支根本走不到，为了避免多线程加的判断，实际应该保证UI操作在主线程中
                return;
            }
        } else {
            ///在视图层级中，应移除原位在插入对应位
            if ([view isEqual:siblingSubview]) {
                ///如果是一个视图，则不需移位
                return;
            }
            
            ///如果目标区域恰好比当前区域大一代表动作是移到自身之上一个图层，即无动作
            if (targetIdx == index + 1) {
                return;
            }
            
            ///移除
            [self.inner_staticBackSubviews removeObjectAtIndex:index];
            ///移除后要计算targetIdx是否改变
            if (targetIdx > index) {
                --targetIdx;
            }
            ///插入数组
            [self.inner_staticBackSubviews insertObject:view atIndex:targetIdx];
        }
    }
    
    if (self.staticBackLayer) {
        if (view.superview) {
            [view removeFromSuperview];
        }
        [self setNeedsRedrawStaticView];
    } else {
        [self insertSubview:view belowSubview:siblingSubview];
    }
}

-(void)removeStaticBackSubview:(UIView *)view {
    
    if (!view) {
        return;
    }
    
    NSInteger index = [self.inner_staticBackSubviews indexOfObject:view];
    
    ///当内部数组中没有找到时，视为该视图不在视图层级中
    if (index == NSNotFound) {
        return;
    }
    
    ///从数组中移除
    [self.inner_staticBackSubviews removeObjectAtIndex:index];
    
    if (self.staticBackLayer) {
        [self setNeedsRedrawStaticView];
    } else {
        if ([view.superview isEqual:self]) {
            [view removeFromSuperview];
        }
    }
}

#pragma mark --- tool method ---
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
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [tempView.layer renderInContext:context];
        self.staticBackImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
}

#pragma mark --- override ---
-(void)layoutSubviews
{
    [super layoutSubviews];
    if (self.staticBackLayer) {
        ///背景模式绘制背景
        [self drawStaticBackView];
        self.layer.contents = (__bridge id)(self.staticBackImage.CGImage);
    } else {
        ///否则移除寄宿图
        self.layer.contents = nil;
    }
}

#pragma mark --- setter/getter ---
-(void)setStaticBackLayer:(BOOL)staticBackLayer {
    if (staticBackLayer != self.staticBackLayer) {
        _staticBackLayer = staticBackLayer;
        [self setNeedsRedrawStaticView];
        if (!staticBackLayer) {
            [self.inner_staticBackSubviews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [self addSubview:obj];
            }];
        }
    }
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
