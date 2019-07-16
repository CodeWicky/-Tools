//
//  UINavigationController+DWNavigationTransition.m
//  DWNavigationTransition
//
//  Created by Wicky on 2019/6/24.
//  Copyright © 2019 Wicky. All rights reserved.
//

#import "UINavigationController+DWNavigationTransition.h"
#import "UIViewController+DWNavigationTransition.h"
#import "UINavigationBar+DWNavigationTransition.h"
#import "DWTransitionFunction.h"

@implementation UINavigationController (DWNavigationTransition)
@dynamic dw_backgroundViewHidden;

+(void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DWQuickSwizzleMethod(pushViewController:animated:, dw_navigationTransition_pushViewController:animated:);
        DWQuickSwizzleMethod(popViewControllerAnimated:, dw_navigationTransition_popViewControllerAnimated:);
        DWQuickSwizzleMethod(popToViewController:animated:, dw_navigationTransition_popToViewController:animated:);
        DWQuickSwizzleMethod(popToRootViewControllerAnimated:, dw_navigationTransition_popToRootViewControllerAnimated:);
        DWQuickSwizzleMethod(setViewControllers:animated:, dw_navigationTransition_setViewControllers:animated:);
    });
}

-(void)dw_navigationTransition_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (!self.viewControllers.lastObject || !animated) {
        [self dw_navigationTransition_pushViewController:viewController animated:animated];
        return;
    }
    UIViewController * fromVC = self.viewControllers.lastObject;
    [fromVC.dw_statusStoreBar copyFromBar:self.navigationBar];
    BOOL needTransition = fromVC.dw_userNavigationTransition || viewController.dw_userNavigationTransition;
    if (!needTransition) {
        [self dw_navigationTransition_pushViewController:viewController animated:animated];
        return;
    }
    
    fromVC.navigationController.dw_backgroundViewHidden = YES;
    [fromVC dw_addTransitionBarIfNeeded];
    if (fromVC.dw_transitionBar.superview) {
        viewController.dw_transitioningViewController = fromVC;
    }
    
    if (viewController.dw_userNavigationTransition) {
        viewController.dw_isPushTransition = YES;
    }

    [self dw_navigationTransition_pushViewController:viewController animated:animated];
}

-(UIViewController *)dw_navigationTransition_popViewControllerAnimated:(BOOL)animated {
    if (self.viewControllers.count < 2 || !animated) {
        return [self dw_navigationTransition_popViewControllerAnimated:animated];
    }

    UIViewController * fromVC = self.viewControllers.lastObject;
    UIViewController * toVC = self.viewControllers[self.viewControllers.count - 2];
    BOOL needTransition = fromVC.dw_userNavigationTransition || toVC.dw_userNavigationTransition;
    if (!needTransition) {
        return [self dw_navigationTransition_popViewControllerAnimated:animated];
    }

    fromVC.navigationController.dw_backgroundViewHidden = YES;
    [fromVC dw_addTransitionBarIfNeeded];
    if (fromVC.dw_transitionBar.superview) {
        toVC.dw_transitioningViewController = fromVC;
    }
    
    if (toVC.dw_userNavigationTransition) {
        toVC.dw_isPopTransition = YES;
    }
    
    return [self dw_navigationTransition_popViewControllerAnimated:animated];
}

-(NSArray<UIViewController *> *)dw_navigationTransition_popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count < 2 || !animated || ![self.viewControllers containsObject:viewController]) {
        return [self dw_navigationTransition_popToViewController:viewController animated:animated];
    }
    UIViewController * fromVC = self.viewControllers.lastObject;
    UIViewController * toVC = viewController;
    BOOL needTransition = fromVC.dw_userNavigationTransition || toVC.dw_userNavigationTransition;
    if (!needTransition) {
        return [self dw_navigationTransition_popToViewController:viewController animated:animated];
    }
    
    fromVC.navigationController.dw_backgroundViewHidden = YES;
    [fromVC dw_addTransitionBarIfNeeded];
    if (fromVC.dw_transitionBar.superview) {
        toVC.dw_transitioningViewController = fromVC;
    }
    
    if (toVC.dw_userNavigationTransition) {
        toVC.dw_isPopTransition = YES;
    }
    
    return [self dw_navigationTransition_popToViewController:viewController animated:animated];
}

-(NSArray<UIViewController *> *)dw_navigationTransition_popToRootViewControllerAnimated:(BOOL)animated {
    if (self.viewControllers.count < 2 || !animated) {
        return [self dw_navigationTransition_popToRootViewControllerAnimated:animated];
    }
    UIViewController * fromVC = self.viewControllers.lastObject;
    UIViewController * toVC = self.viewControllers.firstObject;
    BOOL needTransition = fromVC.dw_userNavigationTransition || toVC.dw_userNavigationTransition;
    if (!needTransition) {
        return [self dw_navigationTransition_popToRootViewControllerAnimated:animated];
    }
    
    fromVC.navigationController.dw_backgroundViewHidden = YES;
    [fromVC dw_addTransitionBarIfNeeded];
    if (fromVC.dw_transitionBar.superview) {
        toVC.dw_transitioningViewController = fromVC;
    }
    
    if (toVC.dw_userNavigationTransition) {
        toVC.dw_isPopTransition = YES;
    }
    
    return [self dw_navigationTransition_popToRootViewControllerAnimated:animated];
}

-(void)dw_navigationTransition_setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated {
    UIViewController * fromVC = self.viewControllers.lastObject;
    UIViewController * toVC = viewControllers.lastObject;
    BOOL needTransition = fromVC.dw_userNavigationTransition || toVC.dw_userNavigationTransition;
    if (!needTransition) {
        [self dw_navigationTransition_setViewControllers:viewControllers animated:animated];
        return;
    }
    
    fromVC.navigationController.dw_backgroundViewHidden = YES;
    [fromVC dw_addTransitionBarIfNeeded];
    if (fromVC.dw_transitionBar.superview) {
        toVC.dw_transitioningViewController = fromVC;
    }
    
    if (toVC.dw_userNavigationTransition) {
        toVC.dw_isPopTransition = YES;
    }
    
    [self dw_navigationTransition_setViewControllers:viewControllers animated:animated];
}

-(void)setDw_backgroundViewHidden:(BOOL)dw_backgroundViewHidden {
    DWQuickSetAssociatedValue(@selector(dw_backgroundViewHidden), @(dw_backgroundViewHidden));
    self.navigationBar.dw_backgroundView.hidden = dw_backgroundViewHidden;
}

-(BOOL)dw_backgroundViewHidden {
    return [DWQuickGetAssociatedValue() boolValue];
}

@end
