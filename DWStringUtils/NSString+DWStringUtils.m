//
//  NSString+DWStringUtils.m
//  RegExp
//
//  Created by Wicky on 17/1/8.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "NSString+DWStringUtils.h"
#import <objc/runtime.h>

#define replaceIfContains(string,target,replacement,tone) \
do {\
if ([string containsString:target]) {\
string = [string stringByReplacingOccurrencesOfString:target withString:replacement];\
string = [NSString stringWithFormat:@"%@%d",string,tone];\
}\
} while(0)

@interface NSString ()

@property (nonatomic ,strong) NSArray * wordArray;

@property (nonatomic ,copy) NSString * wordPinyinWithTone;

@property (nonatomic ,copy) NSString * wordPinyinWithoutTone;

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
    if (!self.wordArray.count) {
        return nil;
    }
    __block NSString * string = @"";
    NSString * whiteSpace = needWhiteSpace ? @" " : @"";
    [self.wordArray enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * pinyin = [obj transferWordToPinYinWithTone:tone];
        if (!string.length) {
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

-(NSArray *)dw_TrimStringToWord {
    if (self.length) {
        NSMutableArray * temp = [NSMutableArray array];
        [self enumerateSubstringsInRange:NSMakeRange(0, self.length) options:NSStringEnumerationByWords usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
            if (substring.length > 1 && temp.count == 0 && ![substring dw_StringIsChinese] && [substring dw_SubStringConfirmToPattern:@"[\\u4E00-\\u9FA5]+"].count > 0) {///为防止第一个字与英文连在一起
                [temp addObject:[substring substringToIndex:1]];
                [temp addObject:[substring substringFromIndex:1]];
            } else {
                if (substring.length > 1 && [substring dw_StringIsChinese]) {
                    [substring enumerateSubstringsInRange:NSMakeRange(0, substring.length) options:(NSStringEnumerationByComposedCharacterSequences) usingBlock:^(NSString * _Nullable substring2, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
                        [temp addObject:substring2];
                    }];
                } else {
                    if (substring.length) {
                        [temp addObject:substring];
                    }
                }
            }
        }];
        return [temp copy];
    }
    return nil;
}

-(BOOL)dw_StringIsChinese {
    if (self.length == 0) {
        return NO;
    }
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"[\\u4E00-\\u9FA5]+"];
    return [predicate evaluateWithObject:self];
}

-(NSString *)dw_StringByReplacingCharactersInArray:(NSArray *)characters withString:(NSString *)temp {
    if (characters.count == 0) {
        return nil;
    }
    NSString * pattern = [characters componentsJoinedByString:@","];
    pattern = [@"[" stringByAppendingString:pattern];
    pattern = [pattern stringByAppendingString:@"]"];
    NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:pattern options:(NSRegularExpressionCaseInsensitive) error:nil];
    return [regex stringByReplacingMatchesInString:self options:(NSMatchingReportProgress) range:NSMakeRange(0, self.length) withTemplate:temp];
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
    if (tone && self.wordPinyinWithTone) {
        return self.wordPinyinWithTone;
    } else if (!tone && self.wordPinyinWithoutTone) {
        return self.wordPinyinWithoutTone;
    }
    NSMutableString * mutableString = [[NSMutableString alloc] initWithString:self];
    CFStringTransform((CFMutableStringRef)mutableString, NULL, kCFStringTransformToLatin, false);
    NSStringCompareOptions toneOption = tone ?NSCaseInsensitiveSearch:NSDiacriticInsensitiveSearch;
    NSString * pinyin = [mutableString stringByFoldingWithOptions:toneOption locale:[NSLocale currentLocale]];
    if (tone) {
        self.wordPinyinWithTone = pinyin;
    } else {
        self.wordPinyinWithoutTone = pinyin;
    }
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
        NSString * pinyin1 = [arr1[i] transferWordToPinYinWithTone:tone];
        NSString * pinyin2 = [arr2[i] transferWordToPinYinWithTone:tone];
        if (tone) {
            pinyin1 = transformPinyinTone(pinyin1);
            pinyin2 = transformPinyinTone(pinyin2);
        }
        NSComparisonResult result = [pinyin1 caseInsensitiveCompare:pinyin2];
        if (result != NSOrderedSame) {
            return result;
        } else {
            result = [arr1[i] localizedCompare:arr2[i]];
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

-(NSComparisonResult)dw_ComparedInPinyinWithString:(NSString *)string {
    return [self dw_ComparedInPinyinWithString:string considerTone:YES];
}

-(void)setWordPinyinWithTone:(NSString *)wordPinyinWithTone {
    objc_setAssociatedObject(self, @selector(wordPinyinWithTone), wordPinyinWithTone, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSString *)wordPinyinWithTone {
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setWordPinyinWithoutTone:(NSString *)wordPinyinWithoutTone {
    objc_setAssociatedObject(self, @selector(wordPinyinWithoutTone), wordPinyinWithoutTone, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSString *)wordPinyinWithoutTone {
    return objc_getAssociatedObject(self, _cmd);
}

-(void)setWordArray:(NSArray *)wordArray {
    objc_setAssociatedObject(self, @selector(wordArray), wordArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSArray *)wordArray {
    NSArray * array = objc_getAssociatedObject(self, _cmd);
    if (!array) {
        array = [self dw_TrimStringToWord];
        objc_setAssociatedObject(self, @selector(wordArray), array, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return array;
}

#pragma mark --- inline method ---
static NSString * transformPinyinTone(NSString * pinyin) {
    replaceIfContains(pinyin, @"ā", @"a",1);
    replaceIfContains(pinyin, @"á", @"a",2);
    replaceIfContains(pinyin, @"ǎ", @"a",3);
    replaceIfContains(pinyin, @"à", @"a",4);
    replaceIfContains(pinyin, @"ō", @"o",1);
    replaceIfContains(pinyin, @"ó", @"o",2);
    replaceIfContains(pinyin, @"ǒ", @"o",3);
    replaceIfContains(pinyin, @"ò", @"o",4);
    replaceIfContains(pinyin, @"ē", @"e",1);
    replaceIfContains(pinyin, @"é", @"e",2);
    replaceIfContains(pinyin, @"ě", @"e",3);
    replaceIfContains(pinyin, @"è", @"e",4);
    replaceIfContains(pinyin, @"ī", @"i",1);
    replaceIfContains(pinyin, @"í", @"i",2);
    replaceIfContains(pinyin, @"ǐ", @"i",3);
    replaceIfContains(pinyin, @"ì", @"i",4);
    replaceIfContains(pinyin, @"ū", @"u",1);
    replaceIfContains(pinyin, @"ú", @"u",2);
    replaceIfContains(pinyin, @"ǔ", @"u",3);
    replaceIfContains(pinyin, @"ù", @"u",4);
    return pinyin;
}

@end

@implementation NSString (DWStringSizeUtils)

-(CGSize)stringSizeWithFont:(UIFont *)font widthLimit:(CGFloat)widthLimit heightLimit:(CGFloat)heightLimit
{
    return  [self boundingRectWithSize:CGSizeMake(widthLimit, heightLimit) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
}

@end

