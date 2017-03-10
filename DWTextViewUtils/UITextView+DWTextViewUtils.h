//
//  UITextView+DWTextViewUtils.h
//  sss
//
//  Created by Wicky on 2017/3/7.
//  Copyright © 2017年 Wicky. All rights reserved.
//

/**
 UITextView工具类
 
 version 1.0.0 
 为textView提供placeholder功能，区分9.0以下及以上api。
 */

#import <UIKit/UIKit.h>

@interface UITextView (DWTextViewUtils)

@property (nonatomic ,copy) NSString * placeholder;

@property (nonatomic ,strong) UIColor * placeholderTextColor;

@property (nonatomic ,strong) UIFont * placeholderFont;

@end
