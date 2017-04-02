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

-(void)dw_swizzled_presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    if (self.conditionedNav && self.conditionedVCToPush) {
        viewControllerToPresent.conditionedNav = self.conditionedNav;
        viewControllerToPresent.conditionedVCToPush = self.conditionedVCToPush;
    }
    [self dw_swizzled_presentViewController:viewControllerToPresent animated:flag completion:completion];
}

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
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

-(void)setNavigationBarAlpha:(CGFloat)navigationBarAlpha {
    objc_setAssociatedObject(self, @selector(navigationBarAlpha), @(navigationBarAlpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.navigationController handleNavigationBarAlphaTo:navigationBarAlpha];
}

@end

@implementation UINavigationController (DWNavigationUtils)

+(void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL originSel = NSSelectorFromString(@"_updateInteractiveTransition:");
        SEL destinationSel = @selector(dw_swizzled_updateInteractiveTransition:);
        Method originMethod = class_getInstanceMethod(self, originSel);
        Method destinationMethod = class_getInstanceMethod(self, destinationSel);
        method_exchangeImplementations(originMethod, destinationMethod);
    });
}

-(void)dw_swizzled_updateInteractiveTransition:(CGFloat)percentComplete {
    [self dw_swizzled_updateInteractiveTransition:percentComplete];
    id coordinator = self.topViewController.transitionCoordinator;
    if (!coordinator) {
        return;
    }
//    UIViewController * fromVC = coordinator.
    if (self.useAlphaNavBarHandler) {
        ///TODO:处理透明度
        NSLog(@"you need something to do here");
    }
}

-(void)handleNavigationBarAlphaTo:(CGFloat)alpha {
    //    navigationBar.value(forKey: "_barBackgroundView") as AnyObject
    UIView * barBackgroundView = [self.navigationBar valueForKey:@"_barBackgroundView"];
//    let backgroundImageView = barBackgroundView.value(forKey: "_backgroundImageView") as? UIImageView
    UIImageView * backgroundImageView = [barBackgroundView valueForKey:@"_backgroundImageView"];
//    if navigationBar.isTranslucent {
    if (self.navigationBar.isTranslucent) {
//        if backgroundImageView != nil && backgroundImageView!.image != nil {
        if (backgroundImageView && backgroundImageView.image) {
//            (barBackgroundView as! UIView).alpha = alpha
            backgroundImageView.alpha = alpha;
//        }else{
        } else {
            UIView * backgroundEffectView = [barBackgroundView valueForKey:@"_backgroundEffectView"];
//            if let backgroundEffectView = barBackgroundView.value(forKey: "_backgroundEffectView") as? UIView {
            if (backgroundEffectView) {
//                backgroundEffectView.alpha = alpha
                backgroundEffectView.alpha = alpha;
            }
        }
    }else{
//        (barBackgroundView as! UIView).alpha = alpha
        barBackgroundView.alpha = alpha;
    }
    UIView * shadowView = [barBackgroundView valueForKey:@"_shadowView"];
//    if let shadowView = barBackgroundView.value(forKey: "_shadowView") as? UIView {
    if (shadowView) {
//        shadowView.alpha = alpha
        shadowView.alpha = alpha;
    }
}

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

-(BOOL)useAlphaNavBarHandler {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

-(void)setUseAlphaNavBarHandler:(BOOL)useAlphaNavBarHandler {
    objc_setAssociatedObject(self, @selector(useAlphaNavBarHandler), @(useAlphaNavBarHandler), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
