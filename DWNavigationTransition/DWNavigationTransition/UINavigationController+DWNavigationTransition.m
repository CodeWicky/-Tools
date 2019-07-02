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
    });
}

-(void)dw_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (!self.viewControllers.lastObject || !animated) {
        [self dw_pushViewController:viewController animated:animated];
        return;
    }
    UIViewController * lastVC = self.viewControllers.lastObject;
    [lastVC.dw_statusStoreBar copyFromBar:self.navigationBar];
    BOOL needTransition = lastVC.dw_userNavigationTransition || viewController.dw_userNavigationTransition;
    if (!needTransition) {
        [self dw_pushViewController:viewController animated:animated];
        return;
    }
    
    [lastVC dw_addTransitionBarIfNeeded];
    if (lastVC.dw_transitionBar.superview) {
        lastVC.navigationController.navigationBar.dw_backgroundView.hidden = YES;
    }
    
    [self dw_pushViewController:viewController animated:animated];
}

-(void)setDw_backgroundViewHidden:(BOOL)dw_backgroundViewHidden {
    
}

@end
