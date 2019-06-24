//
//  DWTransitionFunction.h
//  DWNavigationTransition
//
//  Created by Wicky on 2019/6/24.
//  Copyright © 2019 Wicky. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DWQuickSwizzleMethod(A,B) DWSwizzleMethod([self class],@selector(A),[self class],@selector(B))

extern void DWSwizzleMethod(Class originalCls, SEL originalSelector, Class swizzledCls, SEL swizzledSelector);
