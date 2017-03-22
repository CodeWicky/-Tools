//
//  UILabel+DWLabelUtils.m
//  ppp
//
//  Created by Wicky on 2016/12/3.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#import "UILabel+DWLabelUtils.h"
#import <objc/runtime.h>


@implementation UILabel (DWLabelUtils)
+(void)load
{
    Method originRectMethod = class_getInstanceMethod(self, @selector(textRectForBounds:limitedToNumberOfLines:));
    Method destinationRectMethod = class_getInstanceMethod(self, @selector(dw_textRectForBounds:limitedToNumberOfLines:));
    method_exchangeImplementations(originRectMethod, destinationRectMethod);
    Method originDrawMethod = class_getInstanceMethod(self, @selector(drawTextInRect:));
    Method destinationDrawMethod = class_getInstanceMethod(self, @selector(dw_drawTextInRect:));
    method_exchangeImplementations(originDrawMethod, destinationDrawMethod);
}

-(void)dw_drawTextInRect:(CGRect)rect
{
    NSLog(@"---text:%@-----%@",self.text,NSStringFromCGRect(rect));
    if ([NSStringFromClass(self.class) isEqualToString:@"UITextFieldLabel"]) {///解决textField显示冲突
        [self dw_drawTextInRect:rect];
        return;
    }
    CGRect frame = [self textRectForBounds:rect limitedToNumberOfLines:self.numberOfLines];
    NSLog(@"text::::%@---%@",self.text,NSStringFromCGRect(frame));
    [self dw_drawTextInRect:frame];
}

-(CGRect)dw_textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    CGRect rect = [self dw_textRectForBounds:UIEdgeInsetsInsetRect(bounds, self.textInset) limitedToNumberOfLines:numberOfLines];///获取系统计算的rect，不影响水平对齐方式
    CGPoint origin = rect.origin;
    switch (self.textVerticalAlignment) {///调整竖直对齐方式
        case DWTextVerticalAlignmentTop:
            origin.y = self.textInset.top;
            break;
        case DWTextVerticalAlignmentBottom:
            origin.y = bounds.size.height - self.textInset.bottom - rect.size.height;
            break;
        default:
            origin.y = (bounds.size.height - self.textInset.top - self.textInset.bottom) / 2.0 - rect.size.height / 2.0 + self.textInset.top;
            break;
    }
    rect.origin = origin;
    return rect;
}

-(void)setTextVerticalAlignment:(DWTextVerticalAlignment)textVerticalAlignment
{
    objc_setAssociatedObject(self, @selector(textVerticalAlignment), @(textVerticalAlignment), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsDisplay];
}

-(DWTextVerticalAlignment)textVerticalAlignment
{
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

-(void)setTextInset:(UIEdgeInsets)textInset
{
    objc_setAssociatedObject(self, @selector(textInset), [NSValue valueWithUIEdgeInsets:textInset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsDisplay];
}

-(UIEdgeInsets)textInset
{
    return [objc_getAssociatedObject(self, _cmd) UIEdgeInsetsValue];
}
@end
