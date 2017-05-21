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

@end

@implementation NSString (DWStringTransferUtils)
+(NSString *)stringWithMetaString:(NSString *)metaString count:(NSUInteger)count
{
    return [@"" stringByPaddingToLength:(metaString.length * count) withString:metaString startingAtIndex:0];
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

-(NSString *)dw_TransferChineseToPinYinWithWhiteSpace:(BOOL)needWhiteSpace tone:(BOOL)tone {
    if (!self.length) {
        return nil;
    }
    __block NSString * string = @"";
    NSString * tempString = [NSString stringWithFormat:@"啊%@",self];//别问我为什么，我也不知道为什么第一个字是汉字第二个是单词遍历的时候不会分开，前面有两个字就没关系
    NSString * whiteSpace = needWhiteSpace ? @" " : @"";
    [tempString enumerateSubstringsInRange:NSMakeRange(0, tempString.length) options:(NSStringEnumerationByWords|NSStringEnumerationLocalized) usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        NSString * pinyin = [substring transferWordToPinYinWithTone:tone];
        if (!string.length) {
            string = [string stringByAppendingString:[NSString stringWithString:pinyin]];
        } else {
            string = [string stringByAppendingString:[NSString stringWithFormat:@"%@%@",whiteSpace,pinyin]];
        }
    }];
    if ([string hasPrefix:@"a "]) {
        string = [string substringFromIndex:2];
    }
    return string;
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

#pragma mark --- setter/getter ---
-(void)setPinyinString:(NSString *)pinyinString {
    objc_setAssociatedObject(self, @selector(pinyinString), pinyinString, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSString *)pinyinString {
    NSString * pinyin = objc_getAssociatedObject(self, _cmd);
    if (!pinyin) {
        pinyin = [self dw_TransferChineseToPinYinWithWhiteSpace:YES tone:YES];
        objc_setAssociatedObject(self, @selector(pinyinString), pinyin, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    return pinyin;
}

#pragma mark --- tool method ---
-(NSString *)transferWordToPinYinWithTone:(BOOL)tone {
    NSMutableString * mutableString = [[NSMutableString alloc] initWithString:self];
    CFStringTransform((CFMutableStringRef)mutableString, NULL, kCFStringTransformToLatin, false);
    NSStringCompareOptions toneOption = tone ?NSCaseInsensitiveSearch:NSDiacriticInsensitiveSearch;
    NSString * pinyin = [mutableString stringByFoldingWithOptions:toneOption locale:[NSLocale currentLocale]];
    return pinyin;
}

@end

@implementation NSString (DWStringSortUtils)

+(NSMutableArray *)dw_SortedStringsInPinyin:(NSArray<NSString *> *)strings {
    NSMutableArray * newStrings = [NSMutableArray arrayWithArray:strings];
    ///按拼音/汉字排序指定范围联系人
    [newStrings sortUsingComparator:^NSComparisonResult(NSString * obj1, NSString * obj2) {
        return [obj1 dw_ComparedInPinyinWithString:obj2 considerTone:YES];
    }];
    return newStrings;
}

-(NSComparisonResult)dw_ComparedInPinyinWithString:(NSString *)string considerTone:(BOOL)tone {
    return [self localizedCompare:string];
}

@end

@implementation NSString (DWStringSizeUtils)

-(CGSize)stringSizeWithFont:(UIFont *)font widthLimit:(CGFloat)widthLimit heightLimit:(CGFloat)heightLimit
{
    return  [self boundingRectWithSize:CGSizeMake(widthLimit, heightLimit) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
}

@end

