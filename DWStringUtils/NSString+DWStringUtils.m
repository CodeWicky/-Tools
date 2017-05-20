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

@property (nonatomic ,strong) NSArray * wordArray;

@property (nonatomic ,copy) NSString * wordPinyin;

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

-(NSString *)dw_TransferChineseToPinYinWithWhiteSpace:(BOOL)needWhiteSpace {
    if (!self.wordArray.count) {
        return nil;
    }
    __block NSString * string = @"";
    NSString * whiteSpace = needWhiteSpace ? @" " : @"";
    [self.wordArray enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * pinyin = [obj transferWordToPinYin];
        if (idx == 0) {
             string = [string stringByAppendingString:[NSString stringWithString:pinyin]];
        } else {
            string = [string stringByAppendingString:[NSString stringWithFormat:@"%@%@",whiteSpace,pinyin]];
        }
    }];
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
        pinyin = [self dw_TransferChineseToPinYinWithWhiteSpace:YES];
        objc_setAssociatedObject(self, @selector(pinyinString), pinyin, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    return pinyin;
}

-(void)setWordPinyin:(NSString *)wordPinyin {
    objc_setAssociatedObject(self, @selector(wordPinyin), wordPinyin, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSString *)wordPinyin {
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setWordArray:(NSArray *)wordArray {
    objc_setAssociatedObject(self, @selector(wordArray), wordArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSArray *)wordArray {
    NSArray * array = objc_getAssociatedObject(self, _cmd);
    if (!array) {
        if (self.length) {
            NSMutableArray * temp = [NSMutableArray array];
            [self enumerateSubstringsInRange:NSMakeRange(0, self.length) options:NSStringEnumerationByWords usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
                [temp addObject:substring];
            }];
            array = [temp copy];
        } else {
            array = @[];
        }
        objc_setAssociatedObject(self, @selector(wordArray), array, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return array;
}

#pragma mark --- tool method ---
-(NSString *)transferWordToPinYin {
    if (self.wordPinyin) {
        return self.wordPinyin;
    }
    NSMutableString * mutableString = [[NSMutableString alloc] initWithString:self];
    CFStringTransform((CFMutableStringRef)mutableString, NULL, kCFStringTransformToLatin, false);
    NSString * pinyin = [mutableString stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
    self.wordPinyin = pinyin;
    return pinyin;
}

@end

@implementation NSString (DWStringSortUtils)

+(NSMutableArray *)dw_SortedStringsInPinyin:(NSArray<NSString *> *)strings {
    NSMutableArray * newStrings = [NSMutableArray arrayWithArray:strings];
    ///按拼音/汉字排序指定范围联系人
    [newStrings sortUsingComparator:^NSComparisonResult(NSString * obj1, NSString * obj2) {
        return [obj1 dw_ComparedInPinyinWithString:obj2];
    }];
    return newStrings;
}

-(NSComparisonResult)dw_ComparedInPinyinWithString:(NSString *)string {
    if ([self isEqualToString:string]) {
        return NSOrderedSame;
    }
    NSArray <NSString *>* arr1 = self.wordArray;
    NSArray <NSString *>* arr2 = string.wordArray;
    NSUInteger minL = MIN(arr1.count, arr2.count);
    for (int i = 0; i < minL; i ++) {
        if ([arr1[i] isEqualToString:arr2[i]]) {
            continue;
        }
        NSComparisonResult result  = [[arr1[i] transferWordToPinYin]caseInsensitiveCompare:[arr2[i] transferWordToPinYin]];
        if (result != NSOrderedSame) {
            return result;
        } else {
            result = [arr1[i] compare:arr2[i]];
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
}

@end

@implementation NSString (DWStringSizeUtils)

-(CGSize)stringSizeWithFont:(UIFont *)font widthLimit:(CGFloat)widthLimit heightLimit:(CGFloat)heightLimit
{
    return  [self boundingRectWithSize:CGSizeMake(widthLimit, heightLimit) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
}

@end

