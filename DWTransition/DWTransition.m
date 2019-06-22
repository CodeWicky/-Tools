//
//  DWTransition.m
//  DWTransition
//
//  Created by Wicky on 2019/5/20.
//  Copyright © 2019 Wicky. All rights reserved.
//

#import "DWTransition.h"

@interface DWTransition ()

@property (nonatomic ,assign) DWTransitionType transitionType;

@end

@implementation DWTransition

static NSString * const kDWTransitionTransparentTempView = @"DWTransitionTransparentTempView";

#pragma mark --- interface method ---
+(instancetype)transitionWithType:(DWTransitionType)type {
    return [self transitionWithType:type duration:0.4 customTransition:nil];
}

+(instancetype)transitionWithType:(DWTransitionType)type customTransition:(DWCustomTransitionHandler)customTransition {
    return [self transitionWithType:type duration:0.4 customTransition:customTransition];
}

+(instancetype)transitionWithType:(DWTransitionType)type duration:(CGFloat)duration customTransition:(DWCustomTransitionHandler)customTransition {
    DWTransition * tran = [DWTransition new];
    tran.transitionType = type;
    tran.transitionDuration = duration;
    tran.customTransition = customTransition;
    return tran;
}

#pragma mark --- tool method ---
-(void)pushAnimationWithTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController * fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView * toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIImageView * fromView = [[UIImageView alloc] init];
    fromView.image = [self snapWithViewController:fromVC.navigationController.view.window.rootViewController];
    
    UIView *containerView = [transitionContext containerView];
    ///此处移除所有原有子视图，因为Push本身的行为就是Push完成之后context层只有一个toView
    [containerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [containerView addSubview:fromView];
    [containerView addSubview:toView];
    
    CGRect fromStart = [transitionContext initialFrameForViewController:fromVC];
    ///由于不确定原始控制器回到哪里，所以这里一定取不到值，我们只知道原始控制器的起始位置，结束位置会在其基础上做改变，所以临时赋值为起始位置，根据动画类型再行更改。
    CGRect fromEnd = fromStart;
    CGRect toEnd = [transitionContext finalFrameForViewController:toVC];
    ///同上
    CGRect toStart = toEnd;
    
    ///直接隐藏tabBar，tabBar动画交给截图去做，另外如果是Push时隐藏的，Pop时会自动回复，十分惊喜
    if (toVC.hidesBottomBarWhenPushed) {
        toVC.tabBarController.tabBar.hidden = YES;
    }
    
    switch (self.transitionType & DWTransitionAnimationTypeMask) {
        case DWTransitionAnimationNoneType:
        {
            ///no animation,nothing to do.
            [transitionContext completeTransition:YES];
        }
            break;
        case DWTransitionAnimationMoveInFromLeftType:
        {
            toStart.origin.x = - toStart.size.width;
            fromEnd.origin.x = fromEnd.size.width * 0.5;
            toView.frame = toStart;
            fromView.frame = fromStart;
            toVC.navigationController.navigationBar.transform = CGAffineTransformMakeTranslation(- toEnd.size.width, 0);
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toView.frame = toEnd;
                fromView.frame = fromEnd;
                toVC.navigationController.navigationBar.transform = CGAffineTransformMakeTranslation(0, 0);
            } completion:^(BOOL finished) {
                [fromView removeFromSuperview];
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionAnimationMoveInFromTopType:
        {
            toStart.origin.y = - toStart.size.height;
            fromEnd.origin.y = fromEnd.size.height * 0.5;
            toView.frame = toStart;
            fromView.frame = fromStart;
            toVC.navigationController.navigationBar.transform = CGAffineTransformMakeTranslation(0, - toEnd.size.height);
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toView.frame = toEnd;
                fromView.frame = fromEnd;
                toVC.navigationController.navigationBar.transform = CGAffineTransformMakeTranslation(0, 0);
            } completion:^(BOOL finished) {
                [fromView removeFromSuperview];
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionAnimationMoveInFromBottomType:
        {
            toStart.origin.y = toStart.size.height;
            fromEnd.origin.y = - fromEnd.size.height * 0.5;
            toView.frame = toStart;
            fromView.frame = fromStart;
            toVC.navigationController.navigationBar.transform = CGAffineTransformMakeTranslation(0, toEnd.size.height);
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toView.frame = toEnd;
                fromView.frame = fromEnd;
                toVC.navigationController.navigationBar.transform = CGAffineTransformMakeTranslation(0, 0);
            } completion:^(BOOL finished) {
                [fromView removeFromSuperview];
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionAnimationZoomInType:
        {
            toView.frame = toStart;
            fromView.frame = fromStart;
            toView.transform = CGAffineTransformMakeScale(1.0 / toView.bounds.size.width, 1.0 / toView.bounds.size.height);
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                [fromView removeFromSuperview];
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionAnimationFadeInType:
        {
            toView.frame = toStart;
            fromView.frame = fromStart;
            toView.alpha = 0;
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toView.alpha = 1;
            } completion:^(BOOL finished) {
                [fromView removeFromSuperview];
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionAnimationCustomType:
        {
            if (self.customTransition) {
                self.customTransition(self,transitionContext);
            } else {
                [transitionContext completeTransition:YES];
            }
        }
            break;
        default:
        {
            toStart.origin.x = toStart.size.width;
            fromEnd.origin.x = - fromEnd.size.width * 0.5;
            toView.frame = toStart;
            fromView.frame = fromStart;
            ///给navigationBar做transform，模拟系统push时navigationBar效果
            toVC.navigationController.navigationBar.transform = CGAffineTransformMakeTranslation(toEnd.size.width, 0);
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toView.frame = toEnd;
                fromView.frame = fromEnd;
                toVC.navigationController.navigationBar.transform = CGAffineTransformMakeTranslation(0, 0);
            } completion:^(BOOL finished) {
                [fromView removeFromSuperview];
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
    }
}

-(void)popAnimationWithTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView * toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView * fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    UIView *containerView = [transitionContext containerView];
    [containerView insertSubview:toView belowSubview:fromView];
    
    
    CGRect fromStart = [transitionContext initialFrameForViewController:fromVC];
    CGRect fromEnd = fromStart;
    CGRect toEnd = [transitionContext finalFrameForViewController:toVC];
    CGRect toStart = toEnd;
    
    ///这里由于Pop回去是要展示之前的控制器的，若之前的是transParentPush进来的，转场图层中存在transparentPush进来时手动添加的fromView，他们位于toView之下。这里应该一起做动画，由于可能会有很多个图层，所以我们添加临时中间图层显示截图做动画即可。动画完成后要移除临时视图。（用这种看堆栈而不用直接找container.subviews的方式是应为如果是transparentPush->Push->transparentPush这样的形式，在pop回到第一层的时候，container中并没有先前的视图。）
    NSInteger index = [toVC.navigationController.viewControllers indexOfObject:toVC];
    UIImageView * middleImageView = nil;
    
    if (index > 0 && index != NSNotFound) {
        ///添加临时图层，用来盛放即将移除的视图，然后对此时图做截图
        UIView * middleCtn = [[UIView alloc] initWithFrame:containerView.bounds];
        middleCtn.backgroundColor = [UIColor clearColor];
        while (index > 0) {
            UIViewController * tmp = toVC.navigationController.viewControllers[index];
            if ([tmp conformsToProtocol:@protocol(DWTransitionProtocol)] && [tmp respondsToSelector:@selector(pushAnimationType)] && (((id<DWTransitionProtocol>)tmp).pushAnimationType & DWTransitionTypeMask) == DWTransitionTransparentPushType) {
                ///如果当前是transparentPush进来的，要将上一个视图补进来
                -- index;
                [middleCtn insertSubview:toVC.navigationController.viewControllers[index].view atIndex:0];
            } else {
                break;
            }
        }
        
        if (middleCtn.subviews.count > 0) {
            ///将截图添加到临时imageView中，并插入在fromView和toView之间
            middleImageView = [[UIImageView alloc] initWithFrame:containerView.bounds];
            middleImageView.image = [self snapWithView:middleCtn];
            [containerView insertSubview:middleImageView belowSubview:toView];
            
            [middleCtn.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.frame = toEnd;
                [containerView insertSubview:obj belowSubview:middleImageView];
            }];
        }
    }
    
    switch (self.transitionType & DWTransitionAnimationTypeMask) {
        case DWTransitionAnimationNoneType:
        {
            ///no animation,nothing to do.
            [transitionContext completeTransition:YES];
            [middleImageView removeFromSuperview];
        }
            break;
        case DWTransitionAnimationMoveInFromLeftType:
        {
            toStart.origin.x = toStart.size.width * 0.5;
            fromEnd.origin.x = - fromEnd.size.width;
            toView.frame = toStart;
            middleImageView.frame = toStart;
            fromView.frame = fromStart;
            ///这里内部使用toVC获取tabBar是因为，若A->B->C,B和C均为hidesBottomBarWhenPushed为YES，当C执行PopToRoot时，C作为FromVC是没有tabBarVC的。
            if (fromVC.hidesBottomBarWhenPushed) {
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation( fromEnd.size.width * 2, 0);
            }
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toView.frame = toEnd;
                middleImageView.frame = toEnd;
                fromView.frame = fromEnd;
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0,0);
            } completion:^(BOOL finished) {
                BOOL cancelled = [transitionContext transitionWasCancelled];
                [transitionContext completeTransition:!cancelled];
                if (!cancelled) {
                    [middleImageView removeFromSuperview];
                }
            }];
        }
            break;
        case DWTransitionAnimationMoveInFromTopType:
        {
            toStart.origin.y = toStart.size.height * 0.5;
            fromEnd.origin.y = - fromEnd.size.height;
            toView.frame = toStart;
            middleImageView.frame = toStart;
            fromView.frame = fromStart;
            if (fromVC.hidesBottomBarWhenPushed) {
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(fromEnd.size.width,fromEnd.size.height);
            }
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toView.frame = toEnd;
                middleImageView.frame = toEnd;
                fromView.frame = fromEnd;
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0,0);
            } completion:^(BOOL finished) {
                BOOL cancelled = [transitionContext transitionWasCancelled];
                [transitionContext completeTransition:!cancelled];
                if (!cancelled) {
                    [middleImageView removeFromSuperview];
                }
            }];
        }
            break;
        case DWTransitionAnimationMoveInFromBottomType:
        {
            toStart.origin.y = - toStart.size.height * 0.5;
            fromEnd.origin.y = fromEnd.size.height;
            toView.frame = toStart;
            middleImageView.frame = toStart;
            fromView.frame = fromStart;
            if (fromVC.hidesBottomBarWhenPushed) {
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(fromEnd.size.width,-fromEnd.size.height);
            }
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toView.frame = toEnd;
                middleImageView.frame = toEnd;
                fromView.frame = fromEnd;
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0,0);
            } completion:^(BOOL finished) {
                BOOL cancelled = [transitionContext transitionWasCancelled];
                [transitionContext completeTransition:!cancelled];
                if (!cancelled) {
                    [middleImageView removeFromSuperview];
                }
            }];
        }
            break;
        case DWTransitionAnimationZoomInType:
        {
            toView.frame = toStart;
            middleImageView.frame = toStart;
            fromView.frame = fromStart;
            if (fromVC.hidesBottomBarWhenPushed) {
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(fromEnd.size.width,fromEnd.size.height);
            }
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                fromView.transform = CGAffineTransformMakeScale(1.0 / fromView.bounds.size.width, 1.0 / fromView.bounds.size.height);
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0,0);
            } completion:^(BOOL finished) {
                BOOL cancelled = [transitionContext transitionWasCancelled];
                [transitionContext completeTransition:!cancelled];
                if (!cancelled) {
                    [middleImageView removeFromSuperview];
                }
            }];
        }
            break;
        case DWTransitionAnimationFadeInType:
        {
            toView.frame = toStart;
            middleImageView.frame = toStart;
            fromView.frame = fromStart;
            if (fromVC.hidesBottomBarWhenPushed) {
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(fromEnd.size.width,fromEnd.size.height);
            }
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                fromView.alpha = 0;
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0,0);
            } completion:^(BOOL finished) {
                BOOL cancelled = [transitionContext transitionWasCancelled];
                [transitionContext completeTransition:!cancelled];
                if (!cancelled) {
                    [middleImageView removeFromSuperview];
                }
            }];
        }
            break;
        case DWTransitionAnimationCustomType:
        {
            if (self.customTransition) {
                self.customTransition(self,transitionContext);
            } else {
                [transitionContext completeTransition:YES];
            }
        }
            break;
        default:
        {
            toStart.origin.x = - toStart.size.width * 0.5;
            fromEnd.origin.x = fromEnd.size.width;
            toView.frame = toStart;
            middleImageView.frame = toStart;
            fromView.frame = fromStart;
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toView.frame = toEnd;
                middleImageView.frame = toEnd;
                fromView.frame = fromEnd;
            } completion:^(BOOL finished) {
                BOOL cancelled = [transitionContext transitionWasCancelled];
                [transitionContext completeTransition:!cancelled];
                if (!cancelled) {
                    [middleImageView removeFromSuperview];
                }
            }];
        }
            break;
    }
}


-(void)pushTransParentAnimationWithTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView * toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView * fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:toView];
    
    ///transparent为透明覆盖模式，所以from位置不变，只需要获取toEnd即可。由于Push结束后会自动移除fromView，所以再我们标记完成后要重新添加在toView底部，这样才能覆盖
    CGRect toEnd = [transitionContext finalFrameForViewController:toVC];
    ///由于不确定原始控制器回到哪里，所以这里一定取不到值，我们只知道原始控制器的起始位置，结束位置会在其基础上做改变，所以临时赋值为起始位置，根据动画类型再行更改。
    CGRect toStart = toEnd;
    switch (self.transitionType & DWTransitionAnimationTypeMask) {
        case DWTransitionAnimationNoneType:
        {
            ///no animation,nothing to do.
            [transitionContext completeTransition:YES];
            [containerView insertSubview:fromView belowSubview:toView];
        }
            break;
        case DWTransitionAnimationMoveInFromLeftType:
        {
            toStart.origin.x = - toStart.size.width;
            toView.frame = toStart;
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toView.frame = toEnd;
            } completion:^(BOOL finished) {
                BOOL cancelled = [transitionContext transitionWasCancelled];
                [transitionContext completeTransition:!cancelled];
                if (!cancelled) {
                    [containerView insertSubview:fromView belowSubview:toView];
                }
            }];
        }
            break;
        case DWTransitionAnimationMoveInFromTopType:
        {
            toStart.origin.y = - toStart.size.height;
            toView.frame = toStart;
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toView.frame = toEnd;
            } completion:^(BOOL finished) {
                BOOL cancelled = [transitionContext transitionWasCancelled];
                [transitionContext completeTransition:!cancelled];
                if (!cancelled) {
                    [containerView insertSubview:fromView belowSubview:toView];
                }
            }];
        }
            break;
        case DWTransitionAnimationMoveInFromBottomType:
        {
            toStart.origin.y = toStart.size.height;
            toView.frame = toStart;
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toView.frame = toEnd;
            } completion:^(BOOL finished) {
                BOOL cancelled = [transitionContext transitionWasCancelled];
                [transitionContext completeTransition:!cancelled];
                if (!cancelled) {
                    [containerView insertSubview:fromView belowSubview:toView];
                }
            }];
        }
            break;
        case DWTransitionAnimationZoomInType:
        {
            toView.frame = toStart;
            toView.transform = CGAffineTransformMakeScale(1.0 / toView.bounds.size.width, 1.0 / toView.bounds.size.height);
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                BOOL cancelled = [transitionContext transitionWasCancelled];
                [transitionContext completeTransition:!cancelled];
                if (!cancelled) {
                    [containerView insertSubview:fromView belowSubview:toView];
                }
            }];
        }
            break;
        case DWTransitionAnimationFadeInType:
        {
            toView.frame = toStart;
            toView.alpha = 0;
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toView.alpha = 1;
            } completion:^(BOOL finished) {
                BOOL cancelled = [transitionContext transitionWasCancelled];
                [transitionContext completeTransition:!cancelled];
                if (!cancelled) {
                    [containerView insertSubview:fromView belowSubview:toView];
                }
            }];
        }
            break;
        case DWTransitionAnimationCustomType:
        {
            if (self.customTransition) {
                self.customTransition(self,transitionContext);
            } else {
                [transitionContext completeTransition:YES];
                [containerView insertSubview:fromView belowSubview:toView];
            }
        }
            break;
        default:
        {
            toStart.origin.x = toStart.size.width;
            toView.frame = toStart;
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toView.frame = toEnd;
            } completion:^(BOOL finished) {
                BOOL cancelled = [transitionContext transitionWasCancelled];
                [transitionContext completeTransition:!cancelled];
                if (!cancelled) {
                    [containerView insertSubview:fromView belowSubview:toView];
                }
            }];
        }
            break;
    }
}

-(void)popTransParentAnimationWithTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView * fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView * toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView * containerView = [transitionContext containerView];
    CGRect fromStart = [transitionContext initialFrameForViewController:fromVC];
    CGRect fromEnd = fromStart;
    
    ///这里如果是transparentPop，有可能因为transparentPush的时候手动insert的Push的fromView而导致containerView中初始状态就多了很多其他的view。且Pop具有以此Pop多个控制器的方法，如PopToRoot。故先查找toView在container中的层级，然后把toView之后fromView之前的view全部从container中移除，并将他们绘制成一个图片，加载在一个在toView与fromView之间临时的imageView上。然后imageView跟随fromView一起做动画。并且在pop完成时，手动移除临时imageView即可。
    NSInteger index = [containerView.subviews indexOfObject:toView];
    if (index == NSNotFound) {
        ///如果视图层级中没有，则添加在底部，并且之上所有视图均为需要移除视图
        [containerView insertSubview:toView atIndex:0];
        index = 1;
    } else {
        ///如果有，则其角标之后一个即为需要移除视图
        ++ index;
    }
    
    ///添加临时图层，用来盛放即将移除的视图，然后对此时图做截图
    UIView * middleCtn = [[UIView alloc] initWithFrame:containerView.bounds];
    middleCtn.backgroundColor = [UIColor clearColor];
    UIView * tmp = containerView.subviews[index];
    while (![tmp isEqual:fromView]) {
        [middleCtn addSubview:tmp];
        tmp = containerView.subviews[index];
    }
    
    ///将截图添加到临时imageView中，并插入在fromView和toView之间
    UIImageView * middleImageView = [[UIImageView alloc] initWithFrame:containerView.bounds];
    middleImageView.image = [self snapWithView:middleCtn];
    [containerView insertSubview:middleImageView belowSubview:fromView];
    
    switch (self.transitionType & DWTransitionAnimationTypeMask) {
        case DWTransitionAnimationNoneType:
        {
            ///no animation,nothing to do.
            [transitionContext completeTransition:YES];
            [middleImageView removeFromSuperview];
        }
            break;
        case DWTransitionAnimationMoveInFromLeftType:
        {
            ///临时图层与fromView同步做动画
            fromEnd.origin.x = - fromEnd.size.width;
            fromView.frame = fromStart;
            middleImageView.frame = fromStart;
            if (fromVC.hidesBottomBarWhenPushed) {
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation( fromEnd.size.width, 0);
            }
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                fromView.frame = fromEnd;
                middleImageView.frame = fromEnd;
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0,0);
            } completion:^(BOOL finished) {
                BOOL cancelled = [transitionContext transitionWasCancelled];
                [transitionContext completeTransition:!cancelled];
                if (!cancelled) {
                    ///并在动画完成时，移除临时图层
                    [middleImageView removeFromSuperview];
                }
            }];
        }
            break;
        case DWTransitionAnimationMoveInFromTopType:
        {
            fromEnd.origin.y = - fromEnd.size.height;
            fromView.frame = fromStart;
            middleImageView.frame = fromStart;
            if (fromVC.hidesBottomBarWhenPushed) {
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation( fromEnd.size.width, 0);
            }
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                fromView.frame = fromEnd;
                middleImageView.frame = fromEnd;
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0,0);
            } completion:^(BOOL finished) {
                BOOL cancelled = [transitionContext transitionWasCancelled];
                [transitionContext completeTransition:!cancelled];
                if (!cancelled) {
                    [middleImageView removeFromSuperview];
                }
            }];
        }
            break;
        case DWTransitionAnimationMoveInFromBottomType:
        {
            fromEnd.origin.y = fromEnd.size.height;
            fromView.frame = fromStart;
            middleImageView.frame = fromStart;
            if (fromVC.hidesBottomBarWhenPushed) {
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation( fromEnd.size.width, 0);
            }
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                fromView.frame = fromEnd;
                middleImageView.frame = fromEnd;
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0,0);
            } completion:^(BOOL finished) {
                BOOL cancelled = [transitionContext transitionWasCancelled];
                [transitionContext completeTransition:!cancelled];
                if (!cancelled) {
                    [middleImageView removeFromSuperview];
                }
            }];
        }
            break;
        case DWTransitionAnimationZoomInType:
        {
            fromView.frame = fromStart;
            middleImageView.frame = fromEnd;
            if (fromVC.hidesBottomBarWhenPushed) {
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation( fromEnd.size.width, 0);
            }
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                fromView.transform = CGAffineTransformMakeScale(1.0 / fromView.bounds.size.width, 1.0 / fromView.bounds.size.height);
                middleImageView.transform = CGAffineTransformMakeScale(1.0 / middleImageView.bounds.size.width, 1.0 / middleImageView.bounds.size.height);
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0,0);
            } completion:^(BOOL finished) {
                BOOL cancelled = [transitionContext transitionWasCancelled];
                [transitionContext completeTransition:!cancelled];
                if (!cancelled) {
                    [middleImageView removeFromSuperview];
                }
            }];
        }
            break;
        case DWTransitionAnimationFadeInType:
        {
            fromView.frame = fromStart;
            middleImageView.frame = fromStart;
            if (fromVC.hidesBottomBarWhenPushed) {
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation( fromEnd.size.width,0);
            }
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                fromView.alpha = 0;
                middleImageView.alpha = 0;
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0,0);
            } completion:^(BOOL finished) {
                BOOL cancelled = [transitionContext transitionWasCancelled];
                [transitionContext completeTransition:!cancelled];
                if (!cancelled) {
                    [middleImageView removeFromSuperview];
                }
            }];
        }
            break;
        case DWTransitionAnimationCustomType:
        {
            if (self.customTransition) {
                self.customTransition(self,transitionContext);
            } else {
                [transitionContext completeTransition:YES];
                [middleImageView removeFromSuperview];
            }
        }
            break;
        default:
        {
            fromEnd.origin.x = fromEnd.size.width;
            fromView.frame = fromStart;
            middleImageView.frame = fromStart;
            if (fromVC.hidesBottomBarWhenPushed) {
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation( fromEnd.size.width, 0);
            }
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                fromView.frame = fromEnd;
                middleImageView.frame = fromEnd;
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0,0);
            } completion:^(BOOL finished) {
                BOOL cancelled = [transitionContext transitionWasCancelled];
                [transitionContext completeTransition:!cancelled];
                if (!cancelled) {
                    [middleImageView removeFromSuperview];
                }
            }];
        }
            break;
    }
}

-(void)presentAnimationWithTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController * toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView * toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    CGRect toEnd = [transitionContext finalFrameForViewController:toVC];
    CGRect toStart = toEnd;
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:toView];
    switch (self.transitionType & DWTransitionAnimationTypeMask) {
        case DWTransitionAnimationNoneType:
        {
            ///no animation,nothing to do.
            [transitionContext completeTransition:YES];
        }
            break;
        case DWTransitionAnimationMoveInFromLeftType:
        {
            toStart.origin.x = - toEnd.size.width;
            toView.frame = toStart;
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toView.frame = toEnd;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionAnimationMoveInFromRightType:
        {
            toStart.origin.x = toEnd.size.width;
            toView.frame = toStart;
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toView.frame = toEnd;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionAnimationMoveInFromTopType:
        {
            toStart.origin.y = -toEnd.size.height;
            toView.frame = toStart;
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toView.frame = toEnd;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionAnimationZoomInType:
        {
            toView.frame = toStart;
            toView.transform = CGAffineTransformMakeScale(1.0 / toEnd.size.width, 1.0 / toEnd.size.height);
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionAnimationFadeInType:
        {
            toView.frame = toStart;
            toView.alpha = 0;
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toView.alpha = 1;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionAnimationCustomType:
        {
            if (self.customTransition) {
                self.customTransition(self,transitionContext);
            } else {
                [transitionContext completeTransition:YES];
            }
        }
            break;
        default:
        {
            toStart.origin.y = toEnd.size.height;
            toView.frame = toStart;
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toView.frame = toEnd;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
    }
}

-(void)dismissAnimationWithTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController * fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView * fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    CGRect fromStart = [transitionContext initialFrameForViewController:fromVC];
    CGRect fromEnd = fromStart;
    switch (self.transitionType & DWTransitionAnimationTypeMask) {
        case DWTransitionAnimationNoneType:
        {
            ///no animation,nothing to do.
            [transitionContext completeTransition:YES];
        }
            break;
        case DWTransitionAnimationMoveInFromLeftType:
        {
            fromEnd.origin.x = - fromStart.size.width;
            fromView.frame = fromStart;
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                fromView.frame = fromEnd;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionAnimationMoveInFromRightType:
        {
            fromEnd.origin.x = fromStart.size.width;
            fromView.frame = fromStart;
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                fromView.frame = fromEnd;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionAnimationMoveInFromTopType:
        {
            fromEnd.origin.y = - fromStart.size.height;
            fromView.frame = fromStart;
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                fromView.frame = fromEnd;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionAnimationZoomInType:
        {
            fromView.frame = fromStart;
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                fromView.transform = CGAffineTransformMakeScale(1.0 / fromStart.size.width, 1.0 / fromStart.size.height);
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionAnimationFadeInType:
        {
            fromView.frame = fromStart;
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                fromView.alpha = 0;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionAnimationCustomType:
        {
            if (self.customTransition) {
                self.customTransition(self,transitionContext);
            } else {
                [transitionContext completeTransition:YES];
            }
        }
            break;
        default:
        {
            fromEnd.origin.y = fromStart.size.height;
            fromView.frame = fromStart;
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                fromView.frame = fromEnd;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
    }
}

-(UIImage *)snapWithViewController:(UIViewController *)vc {
    return [self snapWithView:vc.view];
}

-(UIImage *)snapWithView:(UIView *)view {
    CGFloat scale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    [view.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark --- transition delegate ---
-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return self.transitionDuration;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    switch (self.transitionType & DWTransitionTypeMask) {
        case DWTransitionPopType:
        {
            [self popAnimationWithTransition:transitionContext];
        }
            break;
        case DWTransitionDismissType:
        {
            [self dismissAnimationWithTransition:transitionContext];
        }
            break;
        case DWTransitionPresentType:
        {
            [self presentAnimationWithTransition:transitionContext];
        }
            break;
        case DWTransitionTransparentPushType:
        {
            [self pushTransParentAnimationWithTransition:transitionContext];
        }
            break;
        case DWTransitionTransparentPopType:
        {
            [self popTransParentAnimationWithTransition:transitionContext];
        }
            break;
        default:
        {
            [self pushAnimationWithTransition:transitionContext];
        }
            break;
    }
}

@end
