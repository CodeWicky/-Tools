//
//  DWContactModel.h
//  sd
//
//  Created by Wicky on 2017/4/18.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>

@class DWContactLabelStringModel;
@class DWContactLabelDictionaryModel;
@class DWContactLabelDateModel;
@interface DWContactModel : NSObject

#pragma mark --- 直接属性 ---
///头像图片
@property (nonatomic ,strong) UIImage * headerImage;

///名
@property (nonatomic ,copy) NSString * givenName;

///姓
@property (nonatomic ,copy) NSString * familyName;

///中间
@property (nonatomic ,copy) NSString * middleName;

///Prefix ("Sir" "Duke" "General")
@property (nonatomic ,copy) NSString * namePrefix;

///Suffix ("Jr." "Sr." "III")
@property (nonatomic ,copy) NSString * nameSuffix;

///昵称
@property (nonatomic ,copy) NSString * nickname;

///名音标或拼音
@property (nonatomic ,copy) NSString * phoneticGivenName;

///姓音标或拼音
@property (nonatomic ,copy) NSString * phoneticFamilyName;

///中间字音标或拼音
@property (nonatomic ,copy) NSString * phoneticMiddleName;

///公司
@property (nonatomic ,copy) NSString * organizationName;

///部门
@property (nonatomic ,copy) NSString * departmentName;

///职位
@property (nonatomic ,copy) NSString * jobTitle;

///邮箱
@property (nonatomic ,strong) NSArray<DWContactLabelStringModel *> * emailAddresses;

///生日
@property (nonatomic ,strong) NSDate * birthday;

///备注
@property (nonatomic ,copy) NSString * note;

///邮寄地址
@property (nonatomic ,strong) NSArray<DWContactLabelDictionaryModel *> * postalAddresses;

///纪念日
@property (nonatomic ,strong) NSArray<DWContactLabelDateModel *> * dates;

///联系人类型
@property (nonatomic ,assign) NSInteger contactType;

///电话号码
@property (nonatomic ,strong) NSArray<DWContactLabelStringModel *> * phoneNumbers;

///社交地址
@property (nonatomic ,strong) NSArray<DWContactLabelDictionaryModel *> * instantMessageAddresses;

///链接
@property (nonatomic ,strong) NSArray<DWContactLabelStringModel *> * urlAddresses;

///关联联系人
@property (nonatomic ,strong) NSArray<DWContactLabelStringModel *> * contactRelations;

///住址
@property (nonatomic ,strong) NSArray<DWContactLabelStringModel *> * socialProfiles;

///生日（格林尼日）
@property (nonatomic ,strong) NSDate * nonGregorianBirthday;

#pragma mark --- 间接属性 ---
///全名
@property (nonatomic ,copy) NSString * fullName;

#pragma mark --- 排序用属性 ---
///拼音按字分组
@property (nonatomic ,strong) NSArray<NSString *> * pinYinArray;

///转换后可用于排序拼音字符串（英文名称以处理过）
@property (nonatomic ,copy) NSString * pinYinString;

///用来排序的姓名字符串
@property (nonatomic ,copy) NSString * nameSortString;

#pragma mark --- 存取用属性 ---
///原始对象
@property (nonatomic ,assign) ABRecordRef originRecord;

///唯一标识
@property (nonatomic ,assign) int32_t recordID;

///需要更新
@property (nonatomic ,assign ,readonly) BOOL needUpdate;

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"

-(instancetype)initWithABRecord:(ABRecordRef)ABRecord;

-(void)transferToABRecordWithCompletion:(void(^)(ABRecordRef aRecord))completion;
#pragma clang diagnostic pop

-(void)setUpdated;
@end

@interface DWContactLabelModel : NSObject

@property (nonatomic ,copy) NSString * label;

@property (nonatomic ,strong) id labelValue;

@end

@interface DWContactLabelStringModel : DWContactLabelModel

@property (nonatomic ,strong) NSString * labelValue;

@end

@interface DWContactLabelDictionaryModel : DWContactLabelModel

@property (nonatomic ,strong) NSDictionary * labelValue;

@end

@interface DWContactLabelDateModel : DWContactLabelModel

@property (nonatomic ,strong) NSDate * labelValue;

@end
