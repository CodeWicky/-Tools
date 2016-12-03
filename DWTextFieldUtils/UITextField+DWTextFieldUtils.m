//
//  UITextField+DWTextFieldUtils.m
//  DWTextField
//
//  Created by Wicky on 2016/11/21.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#import "UITextField+DWTextFieldUtils.h"
#import <objc/runtime.h>

@interface UITextField ()

///长度限制数组
@property (nonatomic ,strong) NSMutableArray * limitLengthArr;

@end

@implementation UITextField (DWTextFieldUtils)

#pragma mark ---接口方法---
-(BOOL)dw_ShouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSAssert(self.componentsLength.count, @"To use this Method 'dw_ShouldChangeCharactersInRange:replacementString:' you should make sure setting the property of 'componetsLength!'");
    
    ///获取目标字符串
    string = [self.text stringByReplacingCharactersInRange:range withString:string];
    
    ///获取目标字符串对应的无分隔符字符串
    string = [self absoluteNoSeperatorString:string input:!range.length];
    
    ///如果长度超过最大则截取最大长度
    if (string.length > [self.limitLengthArr.lastObject integerValue]) {
        
        string = [string substringWithRange:NSMakeRange(0, [self.limitLengthArr.lastObject integerValue])];
    }
    
    ///处理字符串至带分隔符字符串
    string = [self handleSeperatorStringWithString:string];
    
    ///强行改变textField
    self.text = string;
    
    ///因为已经强行改变，所以此处无需再次改变，必须为NO
    return NO;
}

#pragma mark ---工具方法---
/**
 在指定位置为字符串添加分隔符
 */
-(NSString *)string:(NSString *)string insertSeperatorAtIndex:(NSInteger)index
{
    return [string stringByReplacingCharactersInRange:NSMakeRange(index, 0) withString:self.componentsSeparator];
}

/**
 获取无分隔符的字符串
 */
-(NSString *)absoluteNoSeperatorString:(NSString *)string input:(BOOL)input
{
    ///获取分隔数组并排除最后一位
    NSMutableArray * numArr = self.limitLengthArr.mutableCopy;
    [numArr removeLastObject];
    
    ///求出带分隔符的限制长度
    [numArr enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj = @(obj.integerValue + self.componentsSeparator.length * (idx + 1));
        numArr[idx] = obj;
    }];
    
    ///循环处理
    int count = (int)numArr.count;
    while (count > 0) {
        
        ///如果超过限制长度则处理字符串
        if (string.length > [numArr.lastObject integerValue]) {
            int index = count;
            
            ///获取需要处理的坐标并倒序处理
            while (index) {
                NSInteger location = [numArr[index - 1] integerValue] - self.componentsSeparator.length;
                string = [string stringByReplacingCharactersInRange:NSMakeRange(location, self.componentsSeparator.length) withString:@""];
                index --;
            }
            ///若进入此判断则跳出循环
            break;
        }
        
        ///未进入此循环自减
        count --;
        [numArr removeLastObject];
    }
    
    
    ///若为删除模式且剔除前长度刚好等于带分隔符的某个限制长度时，末尾分隔符不会被剔除，此处判断后剔除，进行修正（此时情况应为删除模式，且剔除后长度为不带分隔符的某个限制长度+分隔符长度）
    NSInteger length = [self.limitLengthArr[numArr.count] integerValue] + self.componentsSeparator.length;
    if (!input && string.length == length) {///若符合条件剔除末尾分隔符
        string = [string substringWithRange:NSMakeRange(0, length - self.componentsSeparator.length)];
    }
    
    return string;
}

/**
 处理纯字符串至以分隔符分隔的字符串
 */
-(NSString *)handleSeperatorStringWithString:(NSString *)string

{
    ///获取分隔数组并排除最后一位
    NSMutableArray * numArr = self.limitLengthArr.mutableCopy;
    [numArr removeLastObject];
    
    ///循环处理
    int count = (int)numArr.count;
    while (count > 0) {
        
        ///如果超过限制长度则处理字符串
        if (string.length > [numArr.lastObject integerValue]) {
            int index = count;
            
            ///获取需要处理的坐标并倒序处理
            while (index) {
                NSInteger location = [numArr[index - 1] integerValue];
                string = [self string:string insertSeperatorAtIndex:location];
                index --;
            }
            ///若进入此判断则跳出循环
            break;
        }
        
        ///未进入此循环自减
        count --;
        [numArr removeLastObject];
    }
    return string;
}

#pragma mark ---setter、getter---
-(NSString *)absoluteString
{
    return [self absoluteNoSeperatorString:self.text input:YES];
}

-(NSMutableArray *)componentsLength
{
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setComponentsLength:(NSMutableArray *)componentsLength
{
    objc_setAssociatedObject(self, @selector(componentsLength), componentsLength, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    ///设置分隔符数组时自动计算长度限制数组
    self.limitLengthArr = [NSMutableArray array];
    NSInteger limitL = 0;
    for (int i = 0; i < componentsLength.count; i++) {
        limitL += [componentsLength[i] integerValue];
        [self.limitLengthArr addObject:@(limitL)];
    }
}

-(NSString *)componentsSeparator
{
    NSString * separator = objc_getAssociatedObject(self, _cmd);
    if (separator == nil) {
        separator = @" ";
        objc_setAssociatedObject(self, _cmd, separator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return separator;
}

-(void)setComponentsSeparator:(NSString *)componentsSeperator
{
    objc_setAssociatedObject(self, @selector(componentsSeparator), componentsSeperator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(void)setLimitLengthArr:(NSMutableArray *)limitLengthArr
{
    objc_setAssociatedObject(self, @selector(limitLengthArr), limitLengthArr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSMutableArray *)limitLengthArr
{
    return objc_getAssociatedObject(self, _cmd);
}

@end
