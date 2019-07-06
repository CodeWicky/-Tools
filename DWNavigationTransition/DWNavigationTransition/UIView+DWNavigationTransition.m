//
//  UIView+DWNavigationTransition.m
//  DWNavigationTransition
//
//  Created by Wicky on 2019/7/2.
//

#import "UIView+DWNavigationTransition.h"
#import "UINavigationController+DWNavigationTransition.h"
#import "UINavigationBar+DWNavigationTransition.h"
#import "DWTransitionFunction.h"

@implementation UIView (DWNavigationTransition)

+(void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DWSwizzleMethod(NSClassFromString(@"_UIBarBackground"), @selector(setHidden:), [self class], @selector(dw_setHidden:));
    });
}

-(void)dw_setHidden:(BOOL)hidden {
    UIResponder *responder = (UIResponder *)self;
    while (responder) {
        ///这里如果判断到是占位的bar则不做响应，减少运算量
        if ([responder isKindOfClass:[UINavigationBar class]] && ((UINavigationBar *)responder).dw_isFakeBar) {
            return;
        }
        ///这里如果判断到是Navigation上的navigationBar的话，则按照导航显隐进行展示
        if ([responder isKindOfClass:[UINavigationController class]]) {
            [self dw_setHidden:((UINavigationController *)responder).dw_backgroundViewHidden];
            return;
        }
        responder = responder.nextResponder;
    }
    [self dw_setHidden:hidden];
}

@end
