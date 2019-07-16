//
//  UITabBarController+DWNavigationTransition.m
//  DWNavigationTransition
//
//  Created by Wicky on 2019/7/16.
//

#import "UITabBarController+DWNavigationTransition.h"
#import "UIViewController+DWNavigationTransition.h"

@implementation UITabBarController (DWNavigationTransition)
@dynamic dw_useNavigationTransition;

-(BOOL)dw_useNavigationTransition {
    return self.selectedViewController.dw_useNavigationTransition;
}

@end
