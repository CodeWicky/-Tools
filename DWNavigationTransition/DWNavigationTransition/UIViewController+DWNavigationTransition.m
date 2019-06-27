//
//  UIViewController+DWNavigationTransition.m
//  DWNavigationTransition
//
//  Created by Wicky on 2019/6/27.
//

#import "UIViewController+DWNavigationTransition.h"
#import "UINavigationBar+DWNavigationTransition.h"
#import "DWTransitionFunction.h"

@implementation UIViewController (DWNavigationTransition)
@dynamic dw_userNavigationTransition,dw_transitionBar,dw_statusStoreBar;

#pragma mark --- interface method ---
-(void)dw_addTransitionBarIfNeeded {
    if (!self.isViewLoaded || !self.view.window || !self.dw_userNavigationTransition || !self.navigationController.navigationBar || self.navigationController.navigationBar.isHidden) {
        [self.dw_transitionBar removeFromSuperview];
        return;
    }
    [self.dw_transitionBar copyFromBar:self.navigationController.navigationBar];
}

#pragma mark --- setter/getter ---
-(BOOL)dw_userNavigationTransition {
    return [DWQuickGetAssociatedValue() boolValue];
}

-(void)setDw_userNavigationTransition:(BOOL)dw_userNavigationTransition {
    DWQuickSetAssignAssociatedValue(@selector(dw_userNavigationTransition), [NSNumber numberWithBool:dw_userNavigationTransition]);
}

-(UINavigationBar *)dw_transitionBar {
    UINavigationBar * bar = DWQuickGetAssociatedValue();
    if (!bar) {
        bar = [[UINavigationBar alloc] init];
        DWQuickSetStrongAssociatedValue(_cmd, bar);
    }
    return bar;
}

-(void)setDw_transitionBar:(UINavigationBar *)dw_transitionBar {
    DWQuickSetStrongAssociatedValue(@selector(dw_transitionBar), dw_transitionBar);
}

-(UINavigationBar *)dw_statusStoreBar {
    UINavigationBar * bar = DWQuickGetAssociatedValue();
    if (!bar) {
        bar = [[UINavigationBar alloc] init];
        DWQuickSetStrongAssociatedValue(_cmd, bar);
    }
    return bar;
}

-(void)setDw_statusStoreBar:(UINavigationBar *)dw_statusStoreBar {
    DWQuickSetStrongAssociatedValue(@selector(dw_transitionBar), dw_statusStoreBar);
}

@end
