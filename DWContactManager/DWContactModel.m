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
}
@end

@implementation DWContactModel
-(instancetype)initWithABRecord:(ABRecordRef)ABRecord {
    if (self = [super init]) {
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
        _nonGregorianBirthday = (__bridge_transfer NSDate *)ABRecordCopyValue(ABRecord, kABPersonAlternateBirthdayProperty);
        _recordID = ABRecordGetRecordID(ABRecord);
    }
    return self;
}

-(void)transferToABRecordWithCompletion:(void(^)(ABRecordRef aRecord))completion {
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
        CFDateRef nonGregorianBirthday = (__bridge_retained CFDateRef)self.nonGregorianBirthday;
        ABRecordSetValue(record, kABPersonAlternateBirthdayProperty, nonGregorianBirthday, nil);
        CFRelease(nonGregorianBirthday);
    }
    completion?completion(record):nil;
    CFRelease(record);
}

-(void)setUpdated {
    toBeUpdated = NO;
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

-(void)setNonGregorianBirthday:(NSDate *)nonGregorianBirthday {
    if (![_nonGregorianBirthday isEqualToDate:nonGregorianBirthday]) {
        _nonGregorianBirthday = nonGregorianBirthday;
        if (self.originRecord) {
            toBeUpdated = YES;
            if (nonGregorianBirthday) {
                CFDateRef nonGregorianBirthDay = (__bridge_retained CFDateRef)nonGregorianBirthday;
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
        void * value = (__bridge_retained void *)model.labelValue;
        CFStringRef label = (__bridge_retained CFStringRef)model.label;
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
