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
    objc_setAssociatedObject(self, @selector(conditionedVCToPush), conditionedVCToPush, OBJC_ASSOCIATION_RETAIN);
}

@end

@implementation UINavigationController (DWNavigationUtils)

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

@end
