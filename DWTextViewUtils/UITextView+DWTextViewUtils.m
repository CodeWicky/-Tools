//
//  UITextView+DWTextViewUtils.m
//  sss
//
//  Created by Wicky on 2017/3/7.
//  Copyright © 2017年 Wicky. All rights reserved.
//



#define SYSTEM_VERSION_AT_LEAST(v) ([[[UIDevice currentDevice] systemVersion] compare:[NSString stringWithFormat:@"%f",v] options:NSNumericSearch] != NSOrderedAscending)

#import "UITextView+DWTextViewUtils.h"
#import "UILabel+DWLabelUtils.h"
#import <objc/runtime.h>

@interface UITextView ()

@property (nonatomic ,strong) UILabel * dw_placeholderLabel;

@end

@implementation UITextView (DWTextViewUtils)

#pragma mark --- placeholder ---
-(void)setPlaceholder:(NSString *)placeholder {
    objc_setAssociatedObject(self, @selector(placeholder), placeholder, OBJC_ASSOCIATION_COPY_NONATOMIC);
    if (SYSTEM_VERSION_AT_LEAST(9.0)) {
        UILabel * pl = [self valueForKeyPath:@"_placeholderLabel"];
        if (!pl) {
            pl = [[UILabel alloc] initWithFrame:self.bounds];
            [self setValue:pl forKeyPath:@"_placeholderLabel"];
            [self addSubview:pl];
            pl.numberOfLines = 0;
            self.placeholderTextColor = self.placeholderTextColor?:[UIColor lightGrayColor];
            self.placeholderFont = self.placeholderFont?:self.font;
            pl.textColor = self.placeholderTextColor;
            pl.font = self.placeholderFont;
            self.dw_placeholderLabel = pl;
        }
    } else {
        if (!self.dw_placeholderLabel) {
            self.dw_placeholderLabel = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds, 5, 8)];
            [self addSubview:self.dw_placeholderLabel];
            self.dw_placeholderLabel.numberOfLines = 0;
            self.placeholderTextColor = self.placeholderTextColor?:[UIColor lightGrayColor];
            self.placeholderFont = self.placeholderFont?:self.font;
            self.dw_placeholderLabel.textColor = self.placeholderTextColor;
            self.dw_placeholderLabel.font = self.placeholderFont;
            self.dw_placeholderLabel.textVerticalAlignment = DWTextVerticalAlignmentTop;
            self.dw_placeholderLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_dw_textHasChangedCallBack) name:UITextViewTextDidChangeNotification object:nil];
        }
    }
    self.dw_placeholderLabel.text = placeholder;
}

-(void)_dw_textHasChangedCallBack {
    if (self.text.length) {
        self.dw_placeholderLabel.hidden = YES;
    } else {
        self.dw_placeholderLabel.hidden = NO;
    }
}

-(void)dealloc {
    if (!SYSTEM_VERSION_AT_LEAST(9.0)) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
    }
}

-(NSString *)placeholder {
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setPlaceholderTextColor:(UIColor *)placeholderTextColor {
    objc_setAssociatedObject(self, @selector(placeholderTextColor), placeholderTextColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.dw_placeholderLabel) {
        self.dw_placeholderLabel.textColor = placeholderTextColor;
    }
}

-(UIColor *)placeholderTextColor {
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setPlaceholderFont:(UIFont *)placeholderFont {
    objc_setAssociatedObject(self, @selector(placeholderFont), placeholderFont, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.dw_placeholderLabel) {
        self.dw_placeholderLabel.font = placeholderFont;
    }
}

-(UIFont *)placeholderFont {
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setDw_placeholderLabel:(UILabel *)dw_placeholderLabel {
    objc_setAssociatedObject(self, @selector(dw_placeholderLabel), dw_placeholderLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UILabel *)dw_placeholderLabel {
    return objc_getAssociatedObject(self, _cmd);
}



@end
