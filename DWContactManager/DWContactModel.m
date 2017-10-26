//
//  DWContactModel.m
//  sd
//
//  Created by Wicky on 2017/4/18.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "DWContactModel.h"
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"


#define NeedsToUpdateStringValue(value,property) \
if (![_##value isEqualToString:value]) {\
_##value = value;\
UpdateStringValue(self.originRecord, property, value, &toBeUpdated);\
}


#define NeedsToUpdateArrayValue(value,property) \
if (![_##value isEqual:value]) {\
_##value = value;\
UpdateArrayValue(self.originRecord, property, value, &toBeUpdated);\
}

@interface DWContactModel ()
{
    BOOL toBeUpdated;
    dispatch_queue_t serialQ;
    BOOL setValueWithD;
    NSArray * stringKeys;
    NSArray * dateKeys;
    NSArray * arrStringKeys;
    NSArray * arrDicKeys;
    NSArray * arrDateKeys;
}
@end

@implementation DWContactModel
-(instancetype)init {
    if (self = [super init]) {
        serialQ = dispatch_queue_create("com.DWContactModel.transfer.queue", DISPATCH_QUEUE_SERIAL);
        setValueWithD = NO;
        stringKeys = @[@"givenName",@"familyName",@"middleName",@"namePrefix",@"nameSuffix",@"nickname",@"phoneticGivenName",@"phoneticFamilyName",@"phoneticMiddleName",@"organizationName",@"departmentName",@"jobTitle",@"note"];
        dateKeys = @[@"birthday"];
        arrStringKeys = @[@"emailAddresses",@"phoneNumbers",@"urlAddresses",@"contactRelations",@"socialProfiles"];
        arrDicKeys = @[@"postalAddresses",@"instantMessageAddresses"];
        arrDateKeys = @[@"dates"];
    }
    return self;
}

-(instancetype)initWithABRecord:(ABRecordRef)ABRecord {
    if (self = [self init]) {
        _originRecord = ABRecord;
        _fullName = CFStringToNSString(ABRecordCopyCompositeName(ABRecord));
        _headerImage = [UIImage imageWithData:(__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(ABRecord, kABPersonImageFormatThumbnail)];
        _givenName = CFStringToNSString(ABRecordCopyValue(ABRecord, kABPersonFirstNameProperty));
        _familyName = CFStringToNSString(ABRecordCopyValue(ABRecord, kABPersonLastNameProperty));
        _middleName = CFStringToNSString(ABRecordCopyValue(ABRecord, kABPersonMiddleNameProperty));
        _namePrefix = CFStringToNSString(ABRecordCopyValue(ABRecord, kABPersonPrefixProperty));
        _nameSuffix = CFStringToNSString(ABRecordCopyValue(ABRecord, kABPersonSuffixProperty));
        _nickname = CFStringToNSString(ABRecordCopyValue(ABRecord, kABPersonNicknameProperty));
        _phoneticGivenName = CFStringToNSString(ABRecordCopyValue(ABRecord, kABPersonFirstNamePhoneticProperty));
        _phoneticFamilyName = CFStringToNSString(ABRecordCopyValue(ABRecord, kABPersonLastNamePhoneticProperty));
        _phoneticMiddleName = CFStringToNSString(ABRecordCopyValue(ABRecord, kABPersonMiddleNamePhoneticProperty));
        _organizationName = CFStringToNSString(ABRecordCopyValue(ABRecord, kABPersonOrganizationProperty));
        _departmentName = CFStringToNSString(ABRecordCopyValue(ABRecord, kABPersonDepartmentProperty));
        _jobTitle = CFStringToNSString(ABRecordCopyValue(ABRecord, kABPersonJobTitleProperty));
        _emailAddresses = [self getLabelValueWithABRecord:ABRecord property:kABPersonEmailProperty];
        _birthday = (__bridge_transfer NSDate *)ABRecordCopyValue(ABRecord, kABPersonBirthdayProperty);
        _note = CFStringToNSString(ABRecordCopyValue(ABRecord, kABPersonNoteProperty));
        _postalAddresses = [self getLabelValueWithABRecord:ABRecord property:kABPersonAddressProperty];
        _dates = [self getLabelValueWithABRecord:ABRecord property:kABPersonDateProperty];
        _contactType = ((__bridge_transfer NSNumber *)ABRecordCopyValue(ABRecord, kABPersonKindProperty)).integerValue;
        _phoneNumbers = [self getLabelValueWithABRecord:ABRecord property:kABPersonPhoneProperty];
        _instantMessageAddresses = [self getLabelValueWithABRecord:ABRecord property:kABPersonInstantMessageProperty];
        _urlAddresses = [self getLabelValueWithABRecord:ABRecord property:kABPersonURLProperty];
        _contactRelations = [self getLabelValueWithABRecord:ABRecord property:kABPersonRelatedNamesProperty];
        _socialProfiles = [self getLabelValueWithABRecord:ABRecord property:kABPersonSocialProfileProperty];
        _nonGregorianBirthday = (__bridge_transfer NSDictionary *)ABRecordCopyValue(ABRecord, kABPersonAlternateBirthdayProperty);
        _recordID = ABRecordGetRecordID(ABRecord);
    }
    return self;
}

-(instancetype)initWithDictionary:(NSDictionary *)dic {
    if (!dic.allKeys.count) {
        return nil;
    }
    if (self = [self init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

-(void)transferToABRecordWithCompletion:(void(^)(ABRecordRef aRecord))completion {
    dispatch_async(serialQ, ^{
        ABRecordRef record = [self transferToABRecord];
        completion?completion(record):nil;
    });
}

-(ABRecordRef)transferToABRecord {
    ABRecordRef record = self.originRecord?:ABPersonCreate();
    if (self.headerImage) {
        CFDataRef data = CFBridgingRetain(UIImagePNGRepresentation(self.headerImage));;
        ABPersonSetImageData(record, data, nil);
        CFRelease(data);
    }
    SetValueCFStringWithProperty(record, kABPersonFirstNameProperty, self.givenName);
    SetValueCFStringWithProperty(record, kABPersonLastNameProperty, self.familyName);
    SetValueCFStringWithProperty(record, kABPersonMiddleNameProperty, self.middleName);
    SetValueCFStringWithProperty(record, kABPersonPrefixProperty, self.namePrefix);
    SetValueCFStringWithProperty(record, kABPersonSuffixProperty, self.nameSuffix);
    SetValueCFStringWithProperty(record, kABPersonNicknameProperty, self.nickname);
    SetValueCFStringWithProperty(record, kABPersonFirstNamePhoneticProperty, self.phoneticGivenName);
    SetValueCFStringWithProperty(record, kABPersonLastNamePhoneticProperty, self.phoneticFamilyName);
    SetValueCFStringWithProperty(record, kABPersonMiddleNamePhoneticProperty, self.phoneticMiddleName);
    SetValueCFStringWithProperty(record, kABPersonOrganizationProperty, self.organizationName);
    SetValueCFStringWithProperty(record, kABPersonDepartmentProperty, self.departmentName);
    SetValueCFStringWithProperty(record, kABPersonJobTitleProperty, self.jobTitle);
    SetArrayWithProperty(record, kABPersonEmailProperty, self.emailAddresses);
    if (self.birthday) {
        CFDateRef birthday = (__bridge_retained CFDateRef)self.birthday;
        ABRecordSetValue(record, kABPersonBirthdayProperty, birthday, nil);
        CFRelease(birthday);
    }
    SetValueCFStringWithProperty(record, kABPersonNoteProperty, self.note);
    SetArrayWithProperty(record, kABPersonAddressProperty, self.postalAddresses);
    SetArrayWithProperty(record, kABPersonDateProperty, self.dates);
    CFNumberRef number = (__bridge_retained CFNumberRef)@(self.contactType);
    ABRecordSetValue(record, kABPersonKindProperty, number, nil);
    CFRelease(number);
    SetArrayWithProperty(record, kABPersonPhoneProperty, self.phoneNumbers);
    SetArrayWithProperty(record, kABPersonInstantMessageProperty, self.instantMessageAddresses);
    SetArrayWithProperty(record, kABPersonURLProperty, self.urlAddresses);
    SetArrayWithProperty(record, kABPersonRelatedNamesProperty, self.contactRelations);
    SetArrayWithProperty(record, kABPersonSocialProfileProperty, self.socialProfiles);
    if (self.nonGregorianBirthday) {
        CFDictionaryRef nonGregorianBirthday = (__bridge_retained CFDictionaryRef)self.nonGregorianBirthday;
        ABRecordSetValue(record, kABPersonAlternateBirthdayProperty, nonGregorianBirthday, nil);
        CFRelease(nonGregorianBirthday);
    }
    return CFAutorelease(record);
}

-(void)transferToDictionaryWithCompletion:(void (^)(NSDictionary *))completion {
    dispatch_async(serialQ, ^{
        NSDictionary * dic = [self transferToDictionary];
        completion?completion(dic):nil;
    });
}

-(NSDictionary *)transferToDictionary {
    NSMutableDictionary * dic = @{}.mutableCopy;
    
    for (NSString * key in stringKeys) {
        NSString * value = [self valueForKey:key];
        if (value.length) {
            [dic setValue:value forKey:key];
        }
    }
    
    for (NSString * key in dateKeys) {
        NSDate * date = [self valueForKey:key];
        if (date) {
            [dic setValue:date forKey:key];
        }
    }
    
    for (NSString * key in arrStringKeys) {
        NSArray <DWContactLabelStringModel *>* arr = [self valueForKey:key];
        if (arr) {
            NSMutableArray * temp = @[].mutableCopy;
            for (DWContactLabelStringModel * model in arr) {
                if (model.label.length && model.labelValue.length) {
                    NSDictionary * dicT = @{@"label":model.label,@"labelValue":model.labelValue};
                    [temp addObject:dicT];
                }
            }
            if (temp.count) {
                [dic setValue:temp forKey:key];
            }
        }
    }
    
    for (NSString * key in arrDicKeys) {
        NSArray <DWContactLabelDictionaryModel *>* arr = [self valueForKey:key];
        if (arr) {
            NSMutableArray * temp = @[].mutableCopy;
            for (DWContactLabelDictionaryModel * model in arr) {
                if (model.label.length && model.labelValue.allKeys.count) {
                    NSDictionary * dicT = @{@"label":model.label,@"labelValue":model.labelValue};
                    [temp addObject:dicT];
                }
            }
            if (temp.count) {
                [dic setValue:temp forKey:key];
            }
        }
    }
    
    for (NSString * key in arrDateKeys) {
        NSArray <DWContactLabelDateModel *>* arr = [self valueForKey:key];
        if (arr) {
            NSMutableArray * temp = @[].mutableCopy;
            for (DWContactLabelDateModel * model in arr) {
                if (model.label.length && model.labelValue) {
                    NSDictionary * dicT = @{@"label":model.label,@"labelValue":model.labelValue};
                    [temp addObject:dicT];
                }
            }
            if (temp.count) {
                [dic setValue:temp forKey:key];
            }
        }
    }
    
    if (self.headerImage) {
        NSData * jpgData = UIImageJPEGRepresentation(self.headerImage, 1);
        if (jpgData) {
            [dic setValue:jpgData forKey:@"headerImage"];
        }
    }
    
    [dic setValue:@(self.contactType) forKey:@"contactType"];
    
    if (self.nonGregorianBirthday.allKeys.count) {
        [dic setValue:self.nonGregorianBirthday forKey:@"nonGregorianBirthday"];
    }
    
    return [dic copy];
}

-(void)setUpdated {
    toBeUpdated = NO;
}

#pragma mark --- override ---
-(void)setValuesForKeysWithDictionary:(NSDictionary<NSString *,id> *)keyedValues {
    setValueWithD = YES;
    [super setValuesForKeysWithDictionary:keyedValues];
    setValueWithD = NO;
}

-(void)setValue:(id)value forKey:(NSString *)key {
    if (setValueWithD) {
        if (!value) {
            return;
        }
        if ([stringKeys containsObject:key]) {
            if ([value isKindOfClass:[NSString class]]) {
                [super setValue:value forKey:key];
            } else {
                NSLog(@"Wrong type of value with property in DWContactModel Class:\tkey:%@\tvalue:%@",key,value);
            }
        } else if ([dateKeys containsObject:key]) {
            if ([value isKindOfClass:[NSDate class]]) {
                [super setValue:value forKey:key];
            } else {
                NSLog(@"Wrong type of value with property in DWContactModel Class:\tkey:%@\tvalue:%@",key,value);
            }
        } else if ([arrStringKeys containsObject:key]) {
            if ([value isKindOfClass:[NSArray class]]) {
                NSArray * temp = (NSArray *)value;
                if (temp.count) {
                    NSMutableArray * container = @[].mutableCopy;
                    for (id obj in temp) {
                        if ([obj isKindOfClass:[NSDictionary class]] && [[obj valueForKey:@"label"] length] && [[obj valueForKey:@"labelValue"] isKindOfClass:[NSString class]] && [[obj valueForKey:@"labelValue"] length]) {
                            DWContactLabelStringModel * model = [DWContactLabelStringModel new];
                            [model setValuesForKeysWithDictionary:obj];
                            [container addObject:model];
                        } else if ([obj isKindOfClass:[DWContactLabelStringModel class]] && [[obj label] length] && [[obj labelValue] isKindOfClass:[NSString class]] && [[obj labelValue] length]) {
                            [container addObject:obj];
                        } else {
                            NSLog(@"Wrong type of value with property in DWContactModel Class:\tkey:%@\tvalue:%@",key,value);
                        }
                    }
                    if (container.count) {
                        [super setValue:container forKey:key];
                    }
                }
            } else {
                NSLog(@"Wrong type of value with property in DWContactModel Class:\tkey:%@\tvalue:%@",key,value);
            }
        } else if ([arrDicKeys containsObject:key]) {
            if ([value isKindOfClass:[NSArray class]]) {
                NSArray * temp = (NSArray *)value;
                if (temp.count) {
                    NSMutableArray * container = @[].mutableCopy;
                    for (id obj in temp) {
                        if ([obj isKindOfClass:[NSDictionary class]] && [[obj valueForKey:@"label"] length] && [[obj valueForKey:@"labelValue"] isKindOfClass:[NSDictionary class]] && [[[obj valueForKey:@"labelValue"] allKeys] count]) {
                            DWContactLabelDictionaryModel * model = [DWContactLabelDictionaryModel new];
                            [model setValuesForKeysWithDictionary:obj];
                            [container addObject:model];
                        } else if ([obj isKindOfClass:[DWContactLabelDictionaryModel class]] && [[obj label] length] && [[obj labelValue] isKindOfClass:[NSDictionary class]] && [[[obj labelValue] allKeys] count]) {
                            [container addObject:obj];
                        } else {
                            NSLog(@"Wrong type of value with property in DWContactModel Class:\tkey:%@\tvalue:%@",key,value);
                        }
                    }
                    if (container.count) {
                        [super setValue:container forKey:key];
                    }
                }
            } else {
                NSLog(@"Wrong type of value with property in DWContactModel Class:\tkey:%@\tvalue:%@",key,value);
            }
        } else if ([arrDateKeys containsObject:key]) {
            if ([value isKindOfClass:[NSArray class]]) {
                NSArray * temp = (NSArray *)value;
                if (temp.count) {
                    NSMutableArray * container = @[].mutableCopy;
                    for (id obj in temp) {
                        if ([obj isKindOfClass:[NSDictionary class]] && [[obj valueForKey:@"label"] length] && [[obj valueForKey:@"labelValue"] isKindOfClass:[NSDate class]]) {
                            DWContactLabelDateModel * model = [DWContactLabelDateModel new];
                            [model setValuesForKeysWithDictionary:obj];
                            [container addObject:model];
                        } else if ([obj isKindOfClass:[DWContactLabelDateModel class]] && [[obj label] length] && [[obj labelValue] isKindOfClass:[NSDate class]]) {
                            [container addObject:obj];
                        } else {
                            NSLog(@"Wrong type of value with property in DWContactModel Class:\tkey:%@\tvalue:%@",key,value);
                        }
                    }
                    if (container.count) {
                        [super setValue:container forKey:key];
                    }
                }
            } else {
                NSLog(@"Wrong type of value with property in DWContactModel Class:\tkey:%@\tvalue:%@",key,value);
            }
        } else if ([key isEqualToString:@"headerImage"]) {
            if ([value isKindOfClass:[UIImage class]]) {
                [super setValue:value forKey:key];
            } else if ([value isKindOfClass:[NSData class]]) {
                UIImage * img = [UIImage imageWithData:value];
                if (img) {
                    [super setValue:img forKey:key];
                } else {
                    NSLog(@"Wrong type of value with property in DWContactModel Class:\tkey:%@\tvalue:%@",key,value);
                }
            } else {
                NSLog(@"Wrong type of value with property in DWContactModel Class:\tkey:%@\tvalue:%@",key,value);
            }
        } else if ([key isEqualToString:@"contactType"]) {
            if ([value isKindOfClass:[NSNumber class]]) {
                [super setValue:value forKey:key];
            } else {
                NSLog(@"Wrong type of value with property in DWContactModel Class:\tkey:%@\tvalue:%@",key,value);
            }
        } else if ([key isEqualToString:@"nonGregorianBirthday"]) {
            NSSet * valueKeySet = [NSSet setWithArray:[value allKeys]];
            NSSet * targetKeySet = [NSSet setWithObjects:@"calendarIdentifier",@"era",@"isLeapMonth",@"day",@"month",@"year", nil];
            if ([value isKindOfClass:[NSDictionary class]] && [valueKeySet isEqualToSet:targetKeySet]) {
                [super setValue:value forKey:key];
            } else {
                NSLog(@"Wrong type of value with property in DWContactModel Class:\tkey:%@\tvalue:%@",key,value);
            }
        } else {
            [super setValue:value forKey:key];
        }
    } else {
        [super setValue:value forKey:key];
    }
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"Unknown key named %@ in DWContactModel Class.",key);
}

#pragma mark --- setter/getter ---

/**
 setter方法同时改变ABRecord属性
 */
-(void)setHeaderImage:(UIImage *)headerImage {
    if (![_headerImage isEqual:headerImage]) {
        _headerImage = headerImage;
        if (self.originRecord) {
            toBeUpdated = YES;
            if (!headerImage && ABPersonHasImageData(self.originRecord)) {
                ABPersonRemoveImageData(self.originRecord, nil);
            } else {
                CFDataRef data = CFBridgingRetain(UIImagePNGRepresentation(self.headerImage));;
                ABPersonSetImageData(self.originRecord, data, nil);
                CFRelease(data);
            }
        }
    }
}

-(void)setGivenName:(NSString *)givenName {
    NeedsToUpdateStringValue(givenName, kABPersonFirstNameProperty);
}

-(void)setFamilyName:(NSString *)familyName {
    NeedsToUpdateStringValue(familyName, kABPersonLastNameProperty);
}

-(void)setMiddleName:(NSString *)middleName {
    NeedsToUpdateStringValue(middleName, kABPersonMiddleNameProperty);
}

-(void)setNamePrefix:(NSString *)namePrefix {
    NeedsToUpdateStringValue(namePrefix, kABPersonPrefixProperty);
}

-(void)setNameSuffix:(NSString *)nameSuffix {
    NeedsToUpdateStringValue(nameSuffix, kABPersonSuffixProperty);
}

-(void)setNickname:(NSString *)nickname {
    NeedsToUpdateStringValue(nickname, kABPersonNicknameProperty);
}

-(void)setPhoneticGivenName:(NSString *)phoneticGivenName {
    NeedsToUpdateStringValue(phoneticGivenName, kABPersonFirstNamePhoneticProperty);
}

-(void)setPhoneticFamilyName:(NSString *)phoneticFamilyName {
    NeedsToUpdateStringValue(phoneticFamilyName, kABPersonLastNamePhoneticProperty);
}

-(void)setPhoneticMiddleName:(NSString *)phoneticMiddleName {
    NeedsToUpdateStringValue(phoneticMiddleName, kABPersonMiddleNamePhoneticProperty);
}

-(void)setOrganizationName:(NSString *)organizationName {
    NeedsToUpdateStringValue(organizationName, kABPersonOrganizationProperty);
}

-(void)setDepartmentName:(NSString *)departmentName {
    NeedsToUpdateStringValue(departmentName, kABPersonDepartmentProperty);
}

-(void)setJobTitle:(NSString *)jobTitle {
    NeedsToUpdateStringValue(jobTitle, kABPersonJobTitleProperty);
}

-(void)setEmailAddresses:(NSArray<DWContactLabelStringModel *> *)emailAddresses {
    NeedsToUpdateArrayValue(emailAddresses, kABPersonEmailProperty);
}

-(void)setBirthday:(NSDate *)birthday {
    if (![_birthday isEqualToDate:birthday]) {
        _birthday = birthday;
        if (self.originRecord) {
            toBeUpdated = YES;
            if (birthday) {
                CFDateRef birthDay = (__bridge_retained CFDateRef)birthday;
                ABRecordSetValue(self.originRecord, kABPersonBirthdayProperty, birthDay, nil);
                CFRelease(birthDay);
            } else {
                ABRecordRemoveValue(self.originRecord, kABPersonBirthdayProperty, nil);
            }
        }
    }
}

-(void)setNote:(NSString *)note {
    NeedsToUpdateStringValue(note, kABPersonNoteProperty);
}

-(void)setPostalAddresses:(NSArray<DWContactLabelDictionaryModel *> *)postalAddresses {
    NeedsToUpdateArrayValue(postalAddresses, kABPersonAddressProperty);
}

-(void)setDates:(NSArray<DWContactLabelDateModel *> *)dates {
    NeedsToUpdateArrayValue(dates, kABPersonDateProperty);
}

-(void)setContactType:(NSInteger)contactType {
    if (_contactType != contactType) {
        toBeUpdated = YES;
        CFNumberRef number = (__bridge_retained CFNumberRef)@(self.contactType);
        ABRecordSetValue(self.originRecord, kABPersonKindProperty, number, nil);
        CFRelease(number);
    }
}

-(void)setPhoneNumbers:(NSArray<DWContactLabelStringModel *> *)phoneNumbers {
    NeedsToUpdateArrayValue(phoneNumbers, kABPersonPhoneProperty);
}

-(void)setInstantMessageAddresses:(NSArray<DWContactLabelDictionaryModel *> *)instantMessageAddresses {
    NeedsToUpdateArrayValue(instantMessageAddresses, kABPersonInstantMessageProperty);
}

-(void)setUrlAddresses:(NSArray<DWContactLabelStringModel *> *)urlAddresses {
    NeedsToUpdateArrayValue(urlAddresses, kABPersonURLProperty);
}

-(void)setContactRelations:(NSArray<DWContactLabelStringModel *> *)contactRelations {
    NeedsToUpdateArrayValue(contactRelations, kABPersonRelatedNamesProperty);
}

-(void)setSocialProfiles:(NSArray<DWContactLabelStringModel *> *)socialProfiles {
    NeedsToUpdateArrayValue(socialProfiles, kABPersonSocialProfileProperty);
}

-(void)setNonGregorianBirthday:(NSDictionary *)nonGregorianBirthday {
    if (![_nonGregorianBirthday isEqualToDictionary:nonGregorianBirthday]) {
        _nonGregorianBirthday = nonGregorianBirthday;
        if (self.originRecord) {
            toBeUpdated = YES;
            if (nonGregorianBirthday) {
                CFDictionaryRef nonGregorianBirthDay = (__bridge_retained CFDictionaryRef)nonGregorianBirthday;
                ABRecordSetValue(self.originRecord, kABPersonAlternateBirthdayProperty, nonGregorianBirthDay, nil);
                CFRelease(nonGregorianBirthDay);
            } else {
                ABRecordRemoveValue(self.originRecord, kABPersonAlternateBirthdayProperty, nil);
            }
        }
    }
}

-(BOOL)needUpdate {
    return toBeUpdated;
}

static inline void UpdateStringValue(ABRecordRef record,ABPropertyID property,NSString * value,BOOL * update) {
    if (record) {
        *update = YES;
        if (value.length) {
            SetValueCFStringWithProperty(record, property, value);
        } else {
            ABRecordRemoveValue(record, property, nil);
        }
    }
}

static inline void UpdateArrayValue(ABRecordRef record,ABPropertyID property,NSArray <DWContactLabelModel *> *values,BOOL * update) {
    if (record) {
        *update = YES;
        if (values.count) {
            SetArrayWithProperty(record, property, values);
        } else {
            ABRecordRemoveValue(record, property, nil);
        }
    }
}

static inline NSString * CFStringToNSString(CFStringRef CFStr) {
    return (__bridge_transfer NSString *)CFStr;
}

static inline void SetValueCFStringWithProperty(ABRecordRef record,ABPropertyID property,NSString * value) {
    if (!value) return;
    CFStringRef string = CFBridgingRetain(value);
    ABRecordSetValue(record, property, string, nil);
    CFRelease(string);
}

static inline void SetArrayWithProperty(ABRecordRef record,ABPropertyID property,NSArray <DWContactLabelModel *> *values) {
    if (!values.count) {
        return;
    }
    ABMultiValueRef multi = ABMultiValueCreateMutable(kABStringPropertyType);
    for (DWContactLabelModel * model in values) {
        void * value = (__bridge_retained void *)[model valueForKey:@"labelValue"];
        CFStringRef label = (__bridge_retained CFStringRef)[model valueForKey:@"label"];
        ABMultiValueAddValueAndLabel(multi, value, label, NULL);
        CFRelease(value);
        CFRelease(label);
    }
    ABRecordSetValue(record, property, multi, NULL);
    CFRelease(multi);
}

-(NSArray *)getLabelValueWithABRecord:(ABRecordRef)ABRecord property:(ABPropertyID)property {
    ABMultiValueRef values = ABRecordCopyValue(ABRecord, property);
    CFIndex count = ABMultiValueGetCount(values);
    NSMutableArray * arr = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        DWContactLabelModel * model = [DWContactLabelModel new];
        model.label = [(__bridge_transfer NSString *)ABMultiValueCopyLabelAtIndex(values, i) copy];
        model.labelValue = [(__bridge_transfer id)ABMultiValueCopyValueAtIndex(values, i) copy];
        [arr addObject:model];
    }
    CFRelease(values);
    return arr;
}

@end

@implementation DWContactLabelModel

-(void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"Unknown key named %@ in DWContactModel Class.",key);
}

@end

@implementation DWContactLabelStringModel
@dynamic labelValue;
@end

@implementation DWContactLabelDictionaryModel
@dynamic labelValue;
@end

@implementation DWContactLabelDateModel
@dynamic labelValue;
@end
#pragma clang diagnostic pop
