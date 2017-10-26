//
//  DWContactManager.m
//  sd
//
//  Created by Wicky on 2017/4/18.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "DWContactManager.h"
#import <AddressBook/AddressBook.h>
#import "NSString+DWStringUtils.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"

@interface DWContactManager ()

@property (nonatomic ,strong) NSMutableArray<DWContactModel *> * allContacts;

@property (nonatomic ,strong) NSMutableDictionary * sortedContacts;

@property (nonatomic ,strong) NSArray * sortedKeys;

@property (nonatomic ,strong) NSMutableDictionary * correctPinYin;

@property (nonatomic ,assign) ABAddressBookRef addressBook;

@property (nonatomic ,assign) BOOL isChangingAB;

@end


static DWContactManager * manager = nil;
@implementation DWContactManager

#pragma mark --- interface method ---
+(void)checkAuthorize:(void (^)(BOOL))authorized {
    if (!authorized) {
        return;
    }
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    // 2.判断授权状态,如果是未决定状态,才需要请求
    if (status == kABAuthorizationStatusNotDetermined) {
        // 3.创建通讯录进行授权
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if (error) {
                NSLog(@"Something wrong, you may check this error :%@",(__bridge_transfer NSError *)error);
            }
            authorized(granted);
        });
    } else if (status == kABAuthorizationStatusAuthorized) {
        authorized(YES);
    } else {
        authorized(NO);
    }
}

-(void)fetchAllContactsWithCompletion:(void (^)(NSMutableArray *))completion {
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        if (self.allContacts) {
            if (completion) {
                completion(self.allContacts);
            }
            return;
        }
        self.allContacts = [self getAllContacts];
        if (completion) {
            completion(self.allContacts);
        }
    }
}

-(NSMutableArray *)fetchAllContacts {
    if (ABAddressBookGetAuthorizationStatus() != kABAuthorizationStatusAuthorized) {
        return nil;
    }
    if (self.allContacts) {
        return self.allContacts;
    }
    self.allContacts = [self getAllContacts];
    return self.allContacts;
}

-(NSArray *)fetchAllContactsInAB {
    return (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(self.addressBook);
}

-(NSArray<NSDictionary *> *)fetchAllContactsInDictionary {
    NSArray * all = [self fetchAllContacts];
    NSMutableArray * container = @[].mutableCopy;
    [all enumerateObjectsUsingBlock:^(DWContactModel * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary * tmp = [obj transferToDictionary];
        if (tmp) {
            [container addObject:tmp];
        }
    }];
    if (container.count) {
        return [container copy];
    }
    return nil;
}

-(void)fetchSortedContactsInGroupWitnCompletion:(void(^)(NSMutableDictionary * sortedContacts,NSArray * sortedKeys))completion {
    if (self.sortedContacts && self.sortedKeys) {
        if (completion) {
            completion(self.sortedContacts,self.sortedKeys);
        }
        return;
    }
    [self fetchAllContactsWithCompletion:^(NSMutableArray *allContacts) {
        ///分组并配置排序信息
        [self seperateContactsToGroup:allContacts completion:^(NSMutableDictionary *contactsInGroup) {
            ///将分组内联系人按拼音、姓名排序
            [self sortContactsInGroup:contactsInGroup];
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(self.sortedContacts,self.sortedKeys);
                });
            }
        }];
    }];
}

-(NSDictionary *)fetchSortedContactsInGroup {
    if (!self.sortedContacts || !self.sortedKeys) {
        NSMutableArray * contacts = [self fetchAllContacts];
        NSMutableDictionary * contactsInGroup = [self seperateContactsToGroup:contacts];
        [self sortContactsInGroup:contactsInGroup];
    }
    if (self.sortedContacts && self.sortedKeys) {
        return @{@"sortedContacts":self.sortedContacts,@"sortedKeys":self.sortedKeys};
    }
    return nil;
}

-(void)setNeedsRefetch {
    [self createAddressBook];
    self.allContacts = nil;
    self.sortedContacts = nil;
    self.sortedKeys = nil;
}

-(void)filterAllContactsWithCondition:(BOOL (^)(DWContactModel *))condition completion:(void (^)(NSArray *))completion {
    if (self.allContacts) {
        [self filterContacts:self.allContacts condition:condition completion:completion];
    } else {
        [self fetchAllContactsWithCompletion:^(NSMutableArray *allContacts) {
            [self filterContacts:allContacts condition:condition completion:completion];
        }];
    }
}

-(NSArray *)filterAllContactsWithCondition:(BOOL (^)(DWContactModel *))condition {
    if (!self.allContacts) {
        [self fetchAllContacts];
    }
    return [self filterContacts:self.allContacts condition:condition];
}


-(void)sortContacts:(NSArray *)contacts completion:(void (^)(NSArray *))completion {
    NSMutableArray * contactsM = [NSMutableArray arrayWithArray:contacts];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self sortContactsArray:contactsM];
        completion ? completion([contactsM copy]) : nil;
    });
}
-(NSArray *)sortContacts:(NSArray *)contacts {
    NSMutableArray * contactsM = [NSMutableArray arrayWithArray:contacts];
    [self sortContactsArray:contactsM];
    return [contactsM copy];
}


///姓名分组
-(void)seperateContactsToGroup:(NSArray *)contacts completion:(void(^)(NSMutableDictionary * contactsInGroup))completion {
    if (!completion) {
        return ;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary * dicG = [NSMutableDictionary dictionary];
        for (DWContactModel * model in contacts) {
            NSString * nameString = [NSString stringWithFormat:@"%@%@%@",model.familyName?:@"",model.middleName?:@"",model.givenName?:@""];
            NSString * firstChar = nil;
            if (nameString.length) {
                model.nameSortString = [self correctTheFirstNameWithChineseStr:nameString];
                model.pinYinString = [self createPinyinString:model.nameSortString];
                firstChar = [self firstCapitalCharOfString:model.pinYinString];
            }
            if (!firstChar) {
                firstChar = @"#";
            }
            NSMutableArray * arr = dicG[firstChar];
            if (!arr) {
                arr = [NSMutableArray array];
                dicG[firstChar] = arr;
            }
            [arr addObject:model];
        }
        completion(dicG);
    });
}

-(NSMutableDictionary *)seperateContactsToGroup:(NSArray *)contacts {
    NSMutableDictionary * dicG = [NSMutableDictionary dictionary];
    for (DWContactModel * model in contacts) {
        NSString * nameString = [NSString stringWithFormat:@"%@%@%@",model.familyName?:@"",model.middleName?:@"",model.givenName?:@""];
        NSString * firstChar = nil;
        if (nameString.length) {
            model.nameSortString = [self correctTheFirstNameWithChineseStr:nameString];
            model.pinYinString = [self createPinyinString:model.nameSortString];
            firstChar = [self firstCapitalCharOfString:model.pinYinString];
        }
        if (!firstChar) {
            firstChar = @"#";
        }
        NSMutableArray * arr = dicG[firstChar];
        if (!arr) {
            arr = [NSMutableArray array];
            dicG[firstChar] = arr;
        }
        [arr addObject:model];
    }
    return dicG;
}

-(BOOL)addNewContact:(DWContactModel *)personModel {
    if (self.isChangingAB) {
        return NO;
    }
    self.isChangingAB = YES;
    ABRecordRef aRecord = [personModel transferToABRecord];
    CFErrorRef error = NULL;
    BOOL success = ABAddressBookAddRecord(self.addressBook, aRecord, &error);
    self.isChangingAB = NO;
    if (error) {
        NSLog(@"Something wrong, you may check this error :%@",(__bridge_transfer NSError *)error);
        CFRelease(error);
    }
    return success;
}

-(BOOL)addNewContactFromArray:(NSArray<DWContactModel *> *)arr {
    __block BOOL success = YES;
    [arr enumerateObjectsUsingBlock:^(DWContactModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        success &= [self addNewContact:obj];
    }];
    return success;
}

-(void)addNewContactFromArray:(NSArray<DWContactModel *> *)arr completion:(void (^)(BOOL))completion {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        BOOL success = [self addNewContactFromArray:arr];
        completion?completion(success):nil;
    });
}

-(BOOL)removeContact:(DWContactModel *)personModel {
    if (self.isChangingAB) {
        return NO;
    }
    BOOL success = NO;
    self.isChangingAB = YES;
    if (personModel.originRecord) {
        CFErrorRef error = NULL;
        success = ABAddressBookRemoveRecord(self.addressBook, personModel.originRecord, &error);
        if (error) {
            NSLog(@"Something wrong, you may check this error :%@",(__bridge_transfer NSError *)error);
            CFRelease(error);
        }
        self.isChangingAB = NO;
    }
    return success;
}

-(BOOL)removeAllContacts {
    NSArray * all = [self fetchAllContacts];
    __block BOOL success = YES;
    [all enumerateObjectsUsingBlock:^(DWContactModel * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        success &= [self removeContact:obj];
    }];
    return success;
}

-(void)removeAllContactsWithCompletion:(void (^)(BOOL))completion {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self fetchAllContactsWithCompletion:^(NSMutableArray *allContacts) {
            __block BOOL success = YES;
            [allContacts enumerateObjectsUsingBlock:^(DWContactModel * obj, NSUInteger idx, BOOL * _Nonnull stop) {
                success &= [self removeContact:obj];
            }];
            completion?completion(success):nil;
        }];
    });
}

-(BOOL)editContactWithModel:(DWContactModel *)personModel handler:(void (^)(DWContactModel *))handler {
    if (!personModel.originRecord || !handler || self.isChangingAB) {
        return NO;
    }
    self.isChangingAB = YES;
    handler(personModel);
    self.isChangingAB = NO;
    return YES;
}

-(BOOL)saveAddressBookChange {
    if (self.isChangingAB) {
        return NO;
    }
    CFErrorRef error = NULL;
    BOOL success = ABAddressBookSave(self.addressBook, &error);
    if (error) {
        NSLog(@"Something wrong, you may check this error :%@",(__bridge_transfer NSError *)error);
        CFRelease(error);
    }
    return success;
}

-(void)dropAddressBookChange {
    if (self.isChangingAB) {
        return;
    }
    ABAddressBookRevert(self.addressBook);
}

#pragma mark --- tool method ---
///获取联系人
-(NSMutableArray *)getAllContacts {
    NSArray * array = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(self.addressBook);
    NSMutableArray <DWContactModel *>* contacts = [NSMutableArray array];
    for (int i = 0;i < array.count;i++) {
        [contacts addObject:[[DWContactModel alloc] initWithABRecord:(ABRecordRef)array[i]]];
    }
    return contacts;
}

///排序分组联系人
-(void)sortContactsInGroup:(NSMutableDictionary *)contactsInGroup {
    [self sortGroupContacts:contactsInGroup];
    self.sortedContacts = contactsInGroup;
    self.sortedKeys = [self sortedKeyInGroup:self.sortedContacts];
}

///同分组按拼音/汉字排序
-(void)sortGroupContacts:(NSMutableDictionary *)groupContacts {
    for (NSMutableArray * arr in groupContacts.allValues) {
        [self sortContactsArray:arr];
    }
}

///按拼音/汉字排序指定范围联系人
-(void)sortContactsArray:(NSMutableArray *)contacts {
    [contacts sortUsingComparator:^NSComparisonResult(DWContactModel * obj1, DWContactModel * obj2) {
        return [obj1.nameSortString dw_ComparedInPinyinWithString:obj2.nameSortString];
    }];
}

///首字母排序
-(NSArray *)sortedKeyInGroup:(NSMutableDictionary *)group {
    NSArray * keys = [group.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    if ([keys.firstObject isEqualToString:@"#"]) {
        NSMutableArray * new = [NSMutableArray arrayWithArray:keys];
        [new addObject:@"#"];
        [new removeObjectAtIndex:0];
        keys = new.copy;
    }
    return keys;
}

///汉字转拼音
-(NSString *)transferChineseToPinYin:(NSString *)string {
    NSMutableString *mutableString = [NSMutableString stringWithString:string];
    CFStringTransform((CFMutableStringRef)mutableString, NULL, kCFStringTransformToLatin, false);
    return [mutableString stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
}

///创建拼音字符串
-(NSString *)createPinyinString:(NSString *)aString {
    if (!aString.length) {
        return nil;
    }
    __block NSString * string = @"";
    NSString * tempString = [NSString stringWithFormat:@"啊啊%@",aString];//别问我为什么，我也不知道为什么第一个字是汉字第二个是单词遍历的时候不会分开，前面有两个字就没关系
    [tempString enumerateSubstringsInRange:NSMakeRange(0, tempString.length) options:(NSStringEnumerationByWords|NSStringEnumerationLocalized) usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        NSString * pinyin = [self transferChineseToPinYin:substring];
        if (!string.length) {
            string = [string stringByAppendingString:[NSString stringWithString:pinyin]];
        } else {
            string = [string stringByAppendingString:[NSString stringWithFormat:@" %@",pinyin]];
        }
    }];
    if ([string hasPrefix:@"a a "]) {
        string = [string substringFromIndex:4];
    }
    return string;
}

///姓氏多音字替换为同音字，主要用于获取正确的pinyinArray
-(NSString *)correctTheFirstNameWithChineseStr:(NSString *)chinese {
    NSString * new = [NSString stringWithString:chinese];
    if (chinese.length >= 2) {///长度大于2考虑复姓
        NSString * firstChar = [chinese substringToIndex:1];
        NSString * firstTwoChar = [chinese substringToIndex:2];
        if (self.correctPinYin[firstTwoChar]) {///优先考虑复姓
            new = [new stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:self.correctPinYin[firstTwoChar]];
        } else if (self.correctPinYin[firstChar]) {///单姓
            new = [new stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:self.correctPinYin[firstChar]];
        }
    } else if (chinese.length == 1) {///仅考虑单姓
        NSString * firstChar = [chinese substringToIndex:1];
        if (self.correctPinYin[firstChar]) {///单姓替换
            new = [new stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:self.correctPinYin[firstChar]];
        }
    }
    return new;
}

///返回字符串的大写首字母
-(NSString *)firstCapitalCharOfString:(NSString *)str {
    NSString *first = [[str substringToIndex:1] uppercaseString];
    if (![[NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"[A-Z]"] evaluateWithObject:first]) {
        first = @"#";
    }
    return first;
}

///以条件过滤数组
-(void)filterContacts:(NSArray *)contacts condition:(BOOL (^)(DWContactModel *))condition completion:(void (^)(NSArray *))completion {
    if (!condition) {
        return;
    }
    if (contacts.count) {
        NSMutableArray * temp = [NSMutableArray array];
        for (DWContactModel * personModel in self.allContacts) {
            if (condition(personModel)) {
                [temp addObject:personModel];
            }
        }
        completion ? completion(temp) : nil;
    } else {
        completion ? completion(nil) : nil;
    }
}
-(NSArray *)filterContacts:(NSArray *)contacts condition:(BOOL (^)(DWContactModel *))condition {
    if (contacts.count) {
        NSMutableArray * temp = [NSMutableArray array];
        for (DWContactModel * personModel in self.allContacts) {
            if (condition(personModel)) {
                [temp addObject:personModel];
            }
        }
        return temp;
    } else {
        return nil;
    }
}

-(void)createAddressBook {
    CFErrorRef error = NULL;
    _addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if (error) {
        NSLog(@"Something wrong, you may check this error :%@",(__bridge_transfer NSError *)error);
        CFRelease(error);
    } else {
        ABAddressBookRegisterExternalChangeCallback(_addressBook, ContactChangeCallBack, nil);
    }
}

void ContactChangeCallBack(ABAddressBookRef addressBook,CFDictionaryRef info,void *context) {
    [manager setNeedsRefetch];
    [manager fetchSortedContactsInGroupWitnCompletion:nil];
}

#pragma mark --- singleton ---
+(instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DWContactManager alloc] init];
    });
    return manager;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [super allocWithZone:zone];
    });
    return manager;
}

-(id)copyWithZone:(struct _NSZone *)zone {
    return manager;
}

#pragma mark --- overwrite ---
-(instancetype)init {
    if (self = [super init]) {
        [self createAddressBook];
    }
    return self;
}

-(void)dealloc {
    ABAddressBookUnregisterExternalChangeCallback(_addressBook, ContactChangeCallBack, nil);
}

#pragma mark --- inline method ---



#pragma mark --- setter/getter ---
-(ABAddressBookRef)addressBook {
    if (!_addressBook) {
        [self createAddressBook];
    }
    return _addressBook;
}

-(NSMutableDictionary *)correctPinYin {
    if (!_correctPinYin) {
        NSString * path = [[NSBundle mainBundle] pathForResource:@"DWContactManagerResource" ofType:@"bundle"];
        NSBundle * bundle = [NSBundle bundleWithPath:path];
        _correctPinYin = [NSMutableDictionary dictionaryWithContentsOfFile:[bundle pathForResource:@"DWContactManagerPinYinCorrect" ofType:@"plist"]];
    }
    return _correctPinYin;
}
@end

#pragma clang diagnostic pop
