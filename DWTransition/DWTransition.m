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
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:toVC.view];
    CGFloat cW = containerView.bounds.size.width;
    CGFloat cH = containerView.bounds.size.height;
    switch (self.transitionType & DWTransitionAnimationTypeMask) {
        case DWTransitionPushAnimationNoneType:
        {
            ///no animation,nothing to do.
            [transitionContext completeTransition:YES];
        }
            break;
        case DWTransitionPushAnimationMoveInFromLeftType:
        {
            toVC.view.frame = CGRectMake(-cW, 0, cW, cH);
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toVC.view.transform = CGAffineTransformMakeTranslation(cW, 0);
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionPushAnimationMoveInFromTopType:
        {
            toVC.view.frame = CGRectMake(0, -cH, cW, cH);
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toVC.view.transform = CGAffineTransformMakeTranslation(0, cH);
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionPushAnimationMoveInFromBottomType:
        {
            toVC.view.frame = CGRectMake(0, cH, cW, cH);
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toVC.view.transform = CGAffineTransformMakeTranslation(0, -cH);
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionPushAnimationZoomInType:
        {
            toVC.view.transform = CGAffineTransformMakeScale(1.0 / cW, 1.0 / cH);
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toVC.view.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionPushAniamtionFadeInType:
        {
            toVC.view.alpha = 0;
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toVC.view.alpha = 1;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionPushAnimationCustomType:
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
            toVC.view.frame = CGRectMake(cW, 0, cW, cH);
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                toVC.view.transform = CGAffineTransformMakeTranslation(-cW, 0);
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
    }
}

-(void)popAnimationWithTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    [containerView insertSubview:toVC.view atIndex:0];
    CGFloat cW = containerView.bounds.size.width;
    CGFloat cH = containerView.bounds.size.height;
    switch (self.transitionType & DWTransitionAnimationTypeMask) {
        case DWTransitionPushAnimationNoneType:
        {
            ///no animation,nothing to do.
            [transitionContext completeTransition:YES];
        }
            break;
        case DWTransitionPushAnimationMoveInFromLeftType:
        {
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                fromVC.view.transform = CGAffineTransformMakeTranslation(-cW, 0);
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionPushAnimationMoveInFromTopType:
        {
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                fromVC.view.transform = CGAffineTransformMakeTranslation(0, -cH);
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionPushAnimationMoveInFromBottomType:
        {
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                fromVC.view.transform = CGAffineTransformMakeTranslation(0, cH);
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionPushAnimationZoomInType:
        {
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                fromVC.view.transform = CGAffineTransformMakeScale(1.0 / cW, 1.0 / cH);
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionPushAniamtionFadeInType:
        {
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                fromVC.view.alpha = 0;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
        case DWTransitionPushAnimationCustomType:
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
                fromVC.view.transform = CGAffineTransformMakeTranslation(cW, 0);
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
            }];
        }
            break;
    }
}

#pragma mark --- transition delegate ---
-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return self.transitionDuration;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    switch (self.transitionType & DWTransitionPushTypeMask) {
        case DWTransitionPopType:
            [self popAnimationWithTransition:transitionContext];
            break;
        default:
            [self pushAnimationWithTransition:transitionContext];
            break;
    }
}

@end
