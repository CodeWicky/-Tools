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

+(void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DWQuickSwizzleMethod(pushViewController:animated:, dw_pushViewController:animated:);
    });
}

-(void)dw_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (!self.viewControllers.lastObject) {
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
    
    if (animated) {
        [lastVC dw_addTransitionBarIfNeeded];
        [self setNavigationBarHidden:YES];
        return;
    }
    
    [self dw_pushViewController:viewController animated:animated];
}

@end
