//
//  UITextField+DWTextFieldUtils.h
//  DWTextField
//
//  Created by Wicky on 2016/11/21.
//  Copyright © 2016年 Wicky. All rights reserved.
//


/**
 DWTextFieldUtils
 
 TextField的扩展
 
 version 1.0.0
 添加按位分隔api
 */
#import <UIKit/UIKit.h>

@interface UITextField (DWTextFieldUtils)

///分割长度数组
/**
 形如
 @[@3,@4,@4]
 则以3、4、4形式分隔，且限制长度3+4+4为11
 */
@property (nonatomic ,strong) NSArray<NSNumber *> * componentsLength;

///分隔符
/**
 默认为空格
 */
@property (nonatomic ,copy) NSString * componentsSeperator;

///若需要限制长度并分割，请在需要限制的条件下在shouldChange代理中返回此方法
/**
 形如
 -(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
 {
 return [textField dw_ShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string];
 }
 */
-(BOOL)dw_ShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
@end
