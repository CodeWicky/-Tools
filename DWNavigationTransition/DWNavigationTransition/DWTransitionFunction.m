//
//  aViewController.m
//  DWNavigationTransition
//
//  Created by Wicky on 2019/6/24.
//  Copyright © 2019 Wicky. All rights reserved.
//

#import "DWTransitionFunction.h"
#import <objc/runtime.h>

void DWSwizzleMethod(Class originalCls, SEL originalSelector, Class swizzledCls, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(originalCls, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(swizzledCls, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(originalCls,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(originalCls,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

id DWGetAssociatedValue(id target,const void * key) {
    if (NULL == key) {
        return nil;
    }
    return objc_getAssociatedObject(target, key);
}

void  DWSetAssociatedValue(id target,const void * key,id value) {
    if (NULL == key) {
        return;
    }
    objc_setAssociatedObject(target, key, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}



