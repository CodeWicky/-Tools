//
//  NSString+DWStringUtils.m
//  RegExp
//
//  Created by Wicky on 17/1/8.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "NSString+DWStringUtils.h"
#import <objc/runtime.h>

@interface NSString ()

@property (nonatomic ,strong) NSArray * pinyinArray;

@end

@implementation NSString (DWStringUtils)
+(NSString *)stringWithMetaString:(NSString *)metaString count:(NSUInteger)count
{
    return [@"" stringByPaddingToLength:(metaString.length * count) withString:metaString startingAtIndex:0];
}

-(CGSize)stringSizeWithFont:(UIFont *)font widthLimit:(CGFloat)widthLimit heightLimit:(CGFloat)heightLimit
{
    return  [self boundingRectWithSize:CGSizeMake(widthLimit, heightLimit) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
}

+(NSString *)stringWithRandomCharacterWithLength:(NSUInteger)length {
    char data[length];
    for (int i = 0; i < length; i ++) {
        int ran = arc4random() % 62;
        if (ran < 10) {
            ran += 48;
        } else if (ran < 36) {
            ran += 55;
        } else {
            ran += 61;
        }
        data[i] = (char)ran;
    }
    return [[NSString alloc] initWithBytes:data length:length encoding:NSUTF8StringEncoding];
}

-(NSString *)dw_FixFileNameStringWithIndex:(NSUInteger)idx {
    NSString * extention = [self pathExtension];
    NSString * pureStr = [self stringByDeletingPathExtension];
    pureStr = [pureStr stringByAppendingString:[NSString stringWithFormat:@"_%02lu",idx]];
    return [pureStr stringByAppendingPathExtension:extention];
}

-(NSString *)dw_TransferChineseToPinYinWithWhiteSpace:(BOOL)needWhiteSpace {
    NSMutableString * mutableString = nil;
    if (needWhiteSpace) {
        mutableString = [self fixStringToSeperateChineseAndLetter];
    } else {
        mutableString = [[NSMutableString alloc] initWithString:self];
    }
    CFStringTransform((CFMutableStringRef)mutableString, NULL, kCFStringTransformToLatin, false);
    NSString * pinyin = [mutableString stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
    if (!needWhiteSpace) {
        pinyin = [pinyin stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    return pinyin;
}

-(NSArray<NSTextCheckingResult *> *)dw_RangesConfirmToPattern:(NSString *)pattern {
    NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
    return [regex matchesInString:self options:0 range:NSMakeRange(0, self.length)];
}

-(NSArray<NSString *> *)dw_SubStringConfirmToPattern:(NSString *)pattern {
    NSArray * ranges = [self dw_RangesConfirmToPattern:pattern];
    NSMutableArray * strings = [NSMutableArray array];
    for (NSTextCheckingResult * result in ranges) {
        [strings addObject:[self substringWithRange:result.range]];
    }
    return strings;
}

+(NSMutableArray *)dw_SortedStringsInPinyin:(NSArray<NSString *> *)strings {
    NSMutableArray * newStrings = [NSMutableArray arrayWithArray:strings];
    ///按拼音/汉字排序指定范围联系人
    [newStrings sortUsingComparator:^NSComparisonResult(NSString * obj1, NSString * obj2) {
        NSArray <NSString *>* arr1 = obj1.pinyinArray;
        NSArray <NSString *>* arr2 = obj2.pinyinArray;
        NSUInteger minL = MIN(arr1.count, arr2.count);
        for (int i = 0; i < minL; i ++) {
            NSComparisonResult result  = [arr1[i] caseInsensitiveCompare:arr2[i]];
            if (result != NSOrderedSame) {
                return result;
            } else {
                result = [[obj1 substringWithRange:NSMakeRange(i, 1)] compare:[obj2 substringWithRange:NSMakeRange(i, 1)]];
                if (result != NSOrderedSame) {
                    return result;
                }
            }
        }
        if (arr1.count < arr2.count) {
            return NSOrderedAscending;
        } else if (arr1.count > arr2.count) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    return newStrings;
}

#pragma mark --- tool method ---
///将中文与英文以空格分开
-(NSMutableString *)fixStringToSeperateChineseAndLetter{
    NSMutableString * newString = [NSMutableString stringWithString:self];
    NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:@"[\\u4E00-\\u9FA5]+" options:0 error:nil];
    ///获取匹配结果
    NSArray * ranges = [regex matchesInString:newString options:0 range:NSMakeRange(0, newString.length)];
    NSRange first = ((NSTextCheckingResult *)ranges.firstObject).range;
    if (first.length != newString.length) {
        [ranges enumerateObjectsWithOptions:(NSEnumerationReverse) usingBlock:^(NSTextCheckingResult * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange range = obj.range;
            if (range.location + range.length == newString.length) {
                [newString insertString:@" " atIndex:range.location];
            } else
                if (range.location == 0) {
                    [newString insertString:@" " atIndex:range.length];
                } else {
                    [newString insertString:@" " atIndex:(range.location + range.length)];
                    [newString insertString:@" " atIndex:range.location];
                }
        }];
    }
    return newString;
}

#pragma mark --- setter/getter ---
-(void)setPinyinString:(NSString *)pinyinString {
    objc_setAssociatedObject(self, @selector(pinyinString), pinyinString, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSString *)pinyinString {
    NSString * pinyin = objc_getAssociatedObject(self, _cmd);
    if (!pinyin) {
        pinyin = [self dw_TransferChineseToPinYinWithWhiteSpace:YES];
        objc_setAssociatedObject(self, @selector(pinyinString), pinyin, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    return pinyin;
}

-(void)setPinyinArray:(NSArray *)pinyinArray {
    objc_setAssociatedObject(self, @selector(pinyinArray), pinyinArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSArray *)pinyinArray {
    NSArray * array = objc_getAssociatedObject(self, _cmd);
    if (!array) {
        array = [self.pinyinString componentsSeparatedByString:@" "];
        objc_setAssociatedObject(self, @selector(pinyinArray), array, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return array;
}
@end
