//
//  UINavigationController+DWNavigationUtils.m
//  DWNavigationUtils
//
//  Created by Wicky on 2017/2/20.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import <objc/runtime.h>
#import "DWViewControllerUtils.h"

@interface UIViewController ()

@property (nonatomic ,strong) UINavigationController * conditionedNav;

@property (nonatomic ,strong) UIViewController * conditionedVCToPush;

@end

@implementation UIViewController (DWNavigationUtils)

+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originSel = @selector(presentViewController:animated:completion:);
        SEL destinationSel = @selector(dw_swizzled_presentViewController:animated:completion:);
        Method originMethod = class_getInstanceMethod(self, originSel);
        Method destinationMethod = class_getInstanceMethod(self, destinationSel);
        method_exchangeImplementations(originMethod, destinationMethod);
    });
}

///交换模态方法，以记录条件导航及条件推进控制器
-(void)dw_swizzled_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    if (self.conditionedNav && self.conditionedVCToPush) {
        viewControllerToPresent.conditionedNav = self.conditionedNav;
        viewControllerToPresent.conditionedVCToPush = self.conditionedVCToPush;
    }
    [self dw_swizzled_presentViewController:viewControllerToPresent animated:flag completion:completion];
}

///模态回至至条件控制器
-(void)dismissToConditionVCToPushAnimated:(BOOL)animated completion:(void (^)())completion
{
    //FIXME:多层级dismiss闪烁
    if (self.conditionedNav && self.conditionedVCToPush) {
        [self.conditionedNav pushViewController:self.conditionedVCToPush animated:NO];
    }
    UIViewController * presenting = self.presentingViewController;
    UIViewController * firstPresented = self;
    while (presenting.presentingViewController) {
        firstPresented = presenting;
        presenting = presenting.presentingViewController;
    }
    [firstPresented.presentingViewController dismissViewControllerAnimated:animated completion:completion];
}

#pragma mark --- setter/getter ---
-(UINavigationController *)conditionedNav
{
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setConditionedNav:(UINavigationController *)conditionedNav
{
    objc_setAssociatedObject(self, @selector(conditionedNav), conditionedNav, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIViewController *)conditionedVCToPush
{
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setConditionedVCToPush:(UIViewController *)conditionedVCToPush
{
    objc_setAssociatedObject(self, @selector(conditionedVCToPush), conditionedVCToPush, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(CGFloat)navigationBarAlpha {
    NSNumber * alpha = objc_getAssociatedObject(self, _cmd);
    return alpha ? [alpha floatValue] : 1;
}

-(void)setNavigationBarAlpha:(CGFloat)navigationBarAlpha {
    if (navigationBarAlpha != self.navigationBarAlpha) {
        objc_setAssociatedObject(self, @selector(navigationBarAlpha), @(navigationBarAlpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

@end

@implementation UINavigationController (DWNavigationUtils)

#pragma mark --- interface Method ---
///改变当前导航栏透明度
-(void)handleNavigationBarAlphaTo:(CGFloat)alpha animated:(BOOL)animated animationDuration:(CGFloat)duration {
    UIView * tempView = nil;
    UIView * barBackgroundView = [self.navigationBar valueForKey:@"_barBackgroundView"];
    UIImageView * backgroundImageView = [barBackgroundView valueForKey:@"_backgroundImageView"];
    if (self.navigationBar.isTranslucent) {
        if (backgroundImageView && backgroundImageView.image) {
            tempView = backgroundImageView;
        } else {
            UIView * backgroundEffectView = [barBackgroundView valueForKey:@"_backgroundEffectView"];
            if (backgroundEffectView) {
                tempView = backgroundEffectView;
            }
        }
    }else{
        tempView = barBackgroundView;
    }
    UIView * shadowView = [barBackgroundView valueForKey:@"_shadowView"];
    [UIView beginAnimations:nil context:nil];
    if (animated) {
        [UIView setAnimationsEnabled:YES];
        if (duration > 0) {
            [UIView setAnimationDuration:duration];
        }
    }
    if (tempView) {
        tempView.alpha = alpha;
    }
    if (shadowView) {
        shadowView.alpha = alpha;
    }
    [UIView commitAnimations];
    if (shadowView) {
        shadowView.alpha = alpha;
    }
}

///推进条件控制器
-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated conditionBlock:(BOOL(^)())condition conditionHandler:(void(^)())handler {
    if (!condition || !handler) {
        [self pushViewController:viewController animated:animated];
        return;
    }
    if (!condition()) {
        handler();
    } else {
        [self pushViewController:viewController animated:YES];
    }
}

///推进条件控制器
-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated conditionPresentVC:(UIViewController *)presentVC conditionBlock:(BOOL (^)())condition
{
    [self pushViewController:viewController animated:animated conditionBlock:condition conditionHandler:^{
        if ([presentVC isKindOfClass:[UINavigationController class]]) {
            UIViewController * rootVC = ((UINavigationController *)presentVC).viewControllers.firstObject;
            rootVC.conditionedNav = self;
            rootVC.conditionedVCToPush = viewController;
        } else {
            presentVC.conditionedNav = self;
            presentVC.conditionedVCToPush = viewController;
        }
        [self presentViewController:presentVC animated:YES completion:nil];
    }];
}

#pragma mark --- tool Method ---
+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originSel = NSSelectorFromString(@"_updateInteractiveTransition:");
        SEL destinationSel = @selector(dw_swizzled_updateInteractiveTransition:);
        [self dw_to_swizzled_ImplementationsWithSelA:originSel selB:destinationSel];
        originSel = @selector(popToViewController:animated:);
        destinationSel = @selector(dw_swizzled_popToViewController:animated:);
        [self dw_to_swizzled_ImplementationsWithSelA:originSel selB:destinationSel];
        originSel = @selector(popToRootViewControllerAnimated:);
        destinationSel = @selector(dw_swizzled_popToRootViewControllerAnimated:);
        [self dw_to_swizzled_ImplementationsWithSelA:originSel selB:destinationSel];
    });
}

///交换方法
+(void)dw_to_swizzled_ImplementationsWithSelA:(SEL)selA selB:(SEL)selB {
    Method originMethod = class_getInstanceMethod(self, selA);
    Method destinationMethod = class_getInstanceMethod(self, selB);
    method_exchangeImplementations(originMethod, destinationMethod);
}

///交换侧滑返回方法，以实时更改导航栏透明度
-(void)dw_swizzled_updateInteractiveTransition:(CGFloat)percentComplete {
    [self dw_swizzled_updateInteractiveTransition:percentComplete];
    id coordinator = self.topViewController.transitionCoordinator;
    if (!coordinator) {
        return;
    }
    if (self.dw_AutomaticallyHandleNavBarAlpha) {
        
        ///Handle the navBar alpha
        id<UIViewControllerTransitionCoordinatorContext> context = [coordinator valueForKey:@"__mainContext"];
        UIViewController * fromVC = [context viewControllerForKey:UITransitionContextFromViewControllerKey];
        UIViewController * toVC = [context viewControllerForKey:UITransitionContextToViewControllerKey];
        CGFloat fromAlpha = fromVC.navigationBarAlpha;
        CGFloat toAlpha = toVC.navigationBarAlpha;
        CGFloat newAlpha = fromAlpha + (toAlpha - fromAlpha) * percentComplete;
        [self handleNavigationBarAlphaTo:newAlpha animated:NO animationDuration:0];
        
        ///To handle the navBar tintColor
        
    }
}

///交换pop至指定控制器方法，以实时更改导航栏透明度
-(NSArray<UIViewController *> *)dw_swizzled_popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.dw_AutomaticallyHandleNavBarAlpha) {
        [self handleNavigationBarAlphaTo:viewController.navigationBarAlpha animated:YES animationDuration:0];
    }
    return [self dw_swizzled_popToViewController:viewController animated:YES];
}

///交换pop至根控制器方法，以实时更改导航栏透明度
-(NSArray<UIViewController *> *)dw_swizzled_popToRootViewControllerAnimated:(BOOL)animated {
    if (self.dw_AutomaticallyHandleNavBarAlpha) {
        [self handleNavigationBarAlphaTo:self.viewControllers.firstObject.navigationBarAlpha animated:YES animationDuration:0];
    }
    return [self dw_swizzled_popToRootViewControllerAnimated:animated];
}

///根据上下文状态判断手势取消后是push还是pop
-(void)handleInteractionEndWithContext:(id<UIViewControllerTransitionCoordinatorContext>)context {
    if ([context isCancelled]) {// 自动取消了返回手势
        NSTimeInterval cancelDuration = [context transitionDuration] * (double)[context percentComplete];
        CGFloat nowAlpha = [context viewControllerForKey:UITransitionContextFromViewControllerKey].navigationBarAlpha;
        [self handleNavigationBarAlphaTo:nowAlpha animated:YES animationDuration:cancelDuration];
    } else {// 自动完成了返回手势
        NSTimeInterval finishDuration = [context transitionDuration] * (double)(1 - [context percentComplete]);
        CGFloat nowAlpha = [context viewControllerForKey:
                            UITransitionContextToViewControllerKey].navigationBarAlpha;
        [self handleNavigationBarAlphaTo:nowAlpha animated:YES animationDuration:finishDuration];
    }
}

#pragma mark --- navigationBar Delegate ---
///实现代理方法，以实现push时实时改变导航栏透明度
-(BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPushItem:(UINavigationItem *)item {
    if (!self.dw_AutomaticallyHandleNavBarAlpha) {
        return YES;
    }
    [self handleNavigationBarAlphaTo:self.topViewController.navigationBarAlpha animated:YES animationDuration:0];
    return YES;
}

///实现代理方法，以实现pop时或侧滑手势取消时实时改变导航栏透明度（此代理仅当调用-popViewControllerAnimated:时会调用，仍故需hook-popToRootViewControllerAnimated:及-popToViewController:animated方法）
-(BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    BOOL notHandleInteraction = NO;
    if (!self.dw_AutomaticallyHandleNavBarAlpha) {
        notHandleInteraction = YES;
    }
    id coordinator = self.topViewController.transitionCoordinator;
    if (!coordinator) {
        notHandleInteraction = YES;
    }
    id<UIViewControllerTransitionCoordinatorContext> context = [coordinator valueForKey:@"__mainContext"];
    if (!context || !context.initiallyInteractive) {
        notHandleInteraction = YES;
    }
    if (notHandleInteraction) {
        NSInteger itemCount = navigationBar.items.count;
        NSInteger count = self.viewControllers.count;
        NSInteger delta = (count >= itemCount) ? 2 : 1;
        UIViewController * popToVC = self.viewControllers[count - delta];
        [self popToViewController:popToVC animated:YES];
        return YES;
    }
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 10.0) {
        [coordinator notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            [self handleInteractionEndWithContext:context];
        }];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [coordinator notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            [self handleInteractionEndWithContext:context];
        }];
#pragma clang diagnostic pop
    }
    return YES;
}

#pragma mark --- setter/getter ---
-(BOOL)dw_AutomaticallyHandleNavBarAlpha {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

-(void)setDw_AutomaticallyHandleNavBarAlpha:(BOOL)dw_AutomaticallyHandleNavBarAlpha {
    objc_setAssociatedObject(self, @selector(dw_AutomaticallyHandleNavBarAlpha), @(dw_AutomaticallyHandleNavBarAlpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
