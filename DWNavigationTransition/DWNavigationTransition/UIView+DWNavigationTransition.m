//
//  UIView+DWNavigationTransition.m
//  DWNavigationTransition
//
//  Created by Wicky on 2019/7/2.
//

#import "UIView+DWNavigationTransition.h"

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
        if ([responder isKindOfClass:[UINavigationController class]]) {
//            [self dw_setHidden:((UINavigationController *)responder).km_backgroundViewHidden];
            return;
        }
        responder = responder.nextResponder;
    }
    [self dw_setHidden:hidden];
}

@end
