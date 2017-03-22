//
//  UILabel+DWLabelUtils.h
//  ppp
//
//  Created by Wicky on 2016/12/3.
//  Copyright © 2016年 Wicky. All rights reserved.
//

/**
 DWLabelUtils
 
 提供Label扩展的工具类
 
 version 1.0.0
 提供垂直对齐方式
 
 version 1.0.1
 提供文本显示内距
 
 version 1.0.2
 解决与TextField英文显示的冲突
 */

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DWTextVerticalAlignment) {///垂直对齐方式
    DWTextVerticalAlignmentCenter,///垂直居中
    DWTextVerticalAlignmentTop,///垂直顶部对齐
    DWTextVerticalAlignmentBottom///垂直底部对齐
};
@interface UILabel (DWLabelUtils)

/**
 垂直对齐方式
 */
@property (nonatomic ,assign) DWTextVerticalAlignment textVerticalAlignment;

@property (nonatomic ,assign) UIEdgeInsets textInset;

@end
