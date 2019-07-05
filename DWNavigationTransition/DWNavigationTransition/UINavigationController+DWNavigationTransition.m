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
        DWQuickSwizzleMethod(pushViewController:animated:, dw_pushViewController:animated:);
        DWQuickSwizzleMethod(popViewControllerAnimated:, dw_popViewControllerAnimated:);
    });
}

-(void)dw_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (!self.viewControllers.lastObject || !animated) {
        [self dw_pushViewController:viewController animated:animated];
        return;
    }
    UIViewController * fromVC = self.viewControllers.lastObject;
    [fromVC.dw_statusStoreBar copyFromBar:self.navigationBar];
    BOOL needTransition = fromVC.dw_userNavigationTransition || viewController.dw_userNavigationTransition;
    if (!needTransition) {
        [self dw_pushViewController:viewController animated:animated];
        return;
    }
    
    [fromVC dw_addTransitionBarIfNeeded];
    [fromVC dw_configTransitionBarHiddenIfNeeded:YES];
    if (fromVC.dw_transitionBar.superview) {
        fromVC.navigationController.dw_backgroundViewHidden = YES;
        viewController.dw_transitioningViewController = fromVC;
        viewController.dw_isPushTransition = YES;
    }
    
    [self dw_pushViewController:viewController animated:animated];
}

-(UIViewController *)dw_popViewControllerAnimated:(BOOL)animated {
    if (self.viewControllers.count < 2 || !animated) {
        return [self dw_popViewControllerAnimated:animated];
    }

    UIViewController * fromVC = self.viewControllers.lastObject;
    UIViewController * toVC = self.viewControllers[self.viewControllers.count - 2];
    BOOL needTransition = fromVC.dw_userNavigationTransition || toVC.dw_userNavigationTransition;
    if (!needTransition) {
        return [self dw_popViewControllerAnimated:animated];
    }

    [fromVC dw_addTransitionBarIfNeeded];
    [fromVC dw_configTransitionBarHiddenIfNeeded:NO];
    if (fromVC.dw_transitionBar.superview) {
        fromVC.navigationController.dw_backgroundViewHidden = YES;
        toVC.dw_transitioningViewController = fromVC;
        toVC.dw_isPopTransition = YES;
    }
    
    return [self dw_popViewControllerAnimated:animated];
}

-(void)setDw_backgroundViewHidden:(BOOL)dw_backgroundViewHidden {
    DWQuickSetAssociatedValue(@selector(dw_backgroundViewHidden), @(dw_backgroundViewHidden));
    self.navigationBar.dw_backgroundView.hidden = dw_backgroundViewHidden;
}

-(BOOL)dw_backgroundViewHidden {
    return [DWQuickGetAssociatedValue() boolValue];
}

@end
