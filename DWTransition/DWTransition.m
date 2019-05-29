//
//  DWTransition.m
//  DWTransition
//
//  Created by Wicky on 2019/5/20.
//  Copyright © 2019 Wicky. All rights reserved.
//

#import "DWTransition.h"
#import <objc/runtime.h>

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
    [containerView insertSubview:toVC.view atIndex:0];
    
    CGRect fromStart = [transitionContext initialFrameForViewController:fromVC];
    CGRect fromEnd = fromStart;
    CGRect toEnd = [transitionContext finalFrameForViewController:toVC];
    CGRect toStart = toEnd;

    switch (self.transitionType & DWTransitionAnimationTypeMask) {
        case DWTransitionAnimationNoneType:
        {
            ///no animation,nothing to do.
            [transitionContext completeTransition:YES];
        }
            break;
        case DWTransitionAnimationMoveInFromLeftType:
        {
            toStart.origin.x = toStart.size.width * 0.5;
            fromEnd.origin.x = - fromEnd.size.width;
            toView.frame = toStart;
            fromView.frame = fromStart;
            if (fromVC.hidesBottomBarWhenPushed) {
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation( fromEnd.size.width * 2, 0);
            }
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toView.frame = toEnd;
                fromView.frame = fromEnd;
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0,0);
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionAnimationMoveInFromTopType:
        {
            toStart.origin.y = toStart.size.height * 0.5;
            fromEnd.origin.y = - fromEnd.size.height;
            toView.frame = toStart;
            fromView.frame = fromStart;
            if (fromVC.hidesBottomBarWhenPushed) {
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(fromEnd.size.width,fromEnd.size.height);
            }
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toView.frame = toEnd;
                fromView.frame = fromEnd;
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0,0);
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionAnimationMoveInFromBottomType:
        {
            toStart.origin.y = - toStart.size.height * 0.5;
            fromEnd.origin.y = fromEnd.size.height;
            toView.frame = toStart;
            fromView.frame = fromStart;
            if (fromVC.hidesBottomBarWhenPushed) {
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(fromEnd.size.width,-fromEnd.size.height);
            }
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toView.frame = toEnd;
                fromView.frame = fromEnd;
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0,0);
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionAnimationZoomInType:
        {
            toView.frame = toStart;
            fromView.frame = fromStart;
            if (fromVC.hidesBottomBarWhenPushed) {
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(fromEnd.size.width,fromEnd.size.height);
            }
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                fromView.transform = CGAffineTransformMakeScale(1.0 / fromView.bounds.size.width, 1.0 / fromView.bounds.size.height);
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0,0);
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionAnimationFadeInType:
        {
            toView.frame = toStart;
            fromView.frame = fromStart;
            if (fromVC.hidesBottomBarWhenPushed) {
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(fromEnd.size.width,fromEnd.size.height);
            }
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                fromView.alpha = 0;
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0,0);
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
            toStart.origin.x = - toStart.size.width * 0.5;
            fromEnd.origin.x = fromEnd.size.width;
            toView.frame = toStart;
            fromView.frame = fromStart;
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toView.frame = toEnd;
                fromView.frame = fromEnd;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
    }
}


-(void)pushTransParentAnimationWithTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView * toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView * fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIImageView * fromImageView = [[UIImageView alloc] initWithFrame:fromView.frame];
    fromImageView.image = [self snapWithView:fromView];
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:fromImageView];
    [containerView addSubview:toView];
    
    objc_setAssociatedObject(containerView, kDWTransitionTransparentTempView.UTF8String, fromImageView, OBJC_ASSOCIATION_RETAIN);
    
    ///transparent为透明覆盖模式，所以from位置不变，只需要获取toEnd即可
    CGRect toEnd = [transitionContext finalFrameForViewController:toVC];
    ///由于不确定原始控制器回到哪里，所以这里一定取不到值，我们只知道原始控制器的起始位置，结束位置会在其基础上做改变，所以临时赋值为起始位置，根据动画类型再行更改。
    CGRect toStart = toEnd;
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
            toStart.origin.y = - toStart.size.height;
            toView.frame = toStart;
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toView.frame = toEnd;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
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
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
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
            toStart.origin.x = toStart.size.width;
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

-(void)popTransParentAnimationWithTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView * fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    UIView *containerView = [transitionContext containerView];
    [containerView insertSubview:toVC.view atIndex:0];
    
    CGRect fromStart = [transitionContext initialFrameForViewController:fromVC];
    CGRect fromEnd = fromStart;
    
    UIView * transparentTempView = objc_getAssociatedObject(containerView, kDWTransitionTransparentTempView.UTF8String);
    
    switch (self.transitionType & DWTransitionAnimationTypeMask) {
        case DWTransitionAnimationNoneType:
        {
            ///no animation,nothing to do.
            [transparentTempView removeFromSuperview];
            [transitionContext completeTransition:YES];
        }
            break;
        case DWTransitionAnimationMoveInFromLeftType:
        {
            fromEnd.origin.x = - fromEnd.size.width;
            fromView.frame = fromStart;
            if (fromVC.hidesBottomBarWhenPushed) {
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation( fromEnd.size.width, 0);
            }
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                fromView.frame = fromEnd;
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0,0);
            } completion:^(BOOL finished) {
                [transparentTempView removeFromSuperview];
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionAnimationMoveInFromTopType:
        {
            fromEnd.origin.y = - fromEnd.size.height;
            fromView.frame = fromStart;
            if (fromVC.hidesBottomBarWhenPushed) {
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation( fromEnd.size.width, 0);
            }
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                fromView.frame = fromEnd;
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0,0);
            } completion:^(BOOL finished) {
                [transparentTempView removeFromSuperview];
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionAnimationMoveInFromBottomType:
        {
            fromEnd.origin.y = fromEnd.size.height;
            fromView.frame = fromStart;
            if (fromVC.hidesBottomBarWhenPushed) {
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation( fromEnd.size.width, 0);
            }
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                fromView.frame = fromEnd;
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0,0);
            } completion:^(BOOL finished) {
                [transparentTempView removeFromSuperview];
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionAnimationZoomInType:
        {
            fromView.frame = fromStart;
            if (fromVC.hidesBottomBarWhenPushed) {
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation( fromEnd.size.width, 0);
            }
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                fromView.transform = CGAffineTransformMakeScale(1.0 / fromView.bounds.size.width, 1.0 / fromView.bounds.size.height);
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0,0);
            } completion:^(BOOL finished) {
                [transparentTempView removeFromSuperview];
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionAnimationFadeInType:
        {
            fromView.frame = fromStart;
            if (fromVC.hidesBottomBarWhenPushed) {
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation( fromEnd.size.width,0);
            }
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                fromView.alpha = 0;
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0,0);
            } completion:^(BOOL finished) {
                [transparentTempView removeFromSuperview];
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionAnimationCustomType:
        {
            if (self.customTransition) {
                self.customTransition(self,transitionContext);
            } else {
                [transparentTempView removeFromSuperview];
                [transitionContext completeTransition:YES];
            }
        }
            break;
        default:
        {
            fromEnd.origin.x = fromEnd.size.width;
            fromView.frame = fromStart;
            if (fromVC.hidesBottomBarWhenPushed) {
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation( fromEnd.size.width, 0);
            }
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                fromView.frame = fromEnd;
                toVC.tabBarController.tabBar.transform = CGAffineTransformMakeTranslation(0,0);
            } completion:^(BOOL finished) {
                [transparentTempView removeFromSuperview];
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
    }
}

-(void)presentAnimationWithTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:toVC.view];
    CGFloat cW = containerView.bounds.size.width;
    CGFloat cH = containerView.bounds.size.height;
    switch (self.transitionType & DWTransitionAnimationTypeMask) {
        case DWTransitionAnimationNoneType:
        {
            ///no animation,nothing to do.
            [transitionContext completeTransition:YES];
        }
            break;
        case DWTransitionAnimationMoveInFromLeftType:
        {
            toVC.view.frame = CGRectMake(-cW, 0, cW, cH);
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toVC.view.transform = CGAffineTransformMakeTranslation(cW, 0);
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionAnimationMoveInFromRightType:
        {
            toVC.view.frame = CGRectMake(cW, 0, cW, cH);
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toVC.view.transform = CGAffineTransformMakeTranslation(-cW, 0);
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionAnimationMoveInFromTopType:
        {
            toVC.view.frame = CGRectMake(0, -cH, cW, cH);
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toVC.view.transform = CGAffineTransformMakeTranslation(0, cH);
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionAnimationZoomInType:
        {
            toVC.view.transform = CGAffineTransformMakeScale(1.0 / cW, 1.0 / cH);
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toVC.view.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionAnimationFadeInType:
        {
            toVC.view.alpha = 0;
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toVC.view.alpha = 1;
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
            toVC.view.frame = CGRectMake(0, cH, cW, cH);
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toVC.view.transform = CGAffineTransformMakeTranslation(0, -cH);
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
    }
}

-(void)dismissAnimationWithTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    CGFloat cW = fromVC.view.bounds.size.width;
    CGFloat cH = fromVC.view.bounds.size.height;
    switch (self.transitionType & DWTransitionAnimationTypeMask) {
        case DWTransitionAnimationNoneType:
        {
            ///no animation,nothing to do.
            [transitionContext completeTransition:YES];
        }
            break;
        case DWTransitionAnimationMoveInFromLeftType:
        {
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                fromVC.view.transform = CGAffineTransformMakeTranslation(-cW, 0);
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionAnimationMoveInFromRightType:
        {
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                fromVC.view.transform = CGAffineTransformMakeTranslation(cW, 0);
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionAnimationMoveInFromTopType:
        {
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                fromVC.view.transform = CGAffineTransformMakeTranslation(0, -cH);
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionAnimationZoomInType:
        {
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                fromVC.view.transform = CGAffineTransformMakeScale(1.0 / cW, 1.0 / cH);
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionAnimationFadeInType:
        {
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                fromVC.view.alpha = 0;
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
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                fromVC.view.transform = CGAffineTransformMakeTranslation(0, cH);
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
    CGSize size = view.frame.size;
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshot;
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
