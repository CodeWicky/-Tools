//
//  DWContactModel.h
//  sd
//
//  Created by Wicky on 2017/4/18.
//  Copyright © 2017年 Wicky. All rights reserved.
//

/**
 提供数据模型
 */

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
///排序用姓名
@property (nonatomic ,copy) NSString * nameSortString;

///转换后可用于全名拼音（英文名称以处理过）
@property (nonatomic ,copy) NSString * pinYinString;

#pragma mark --- 存取用属性 ---
///原始对象
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
@property (nonatomic ,assign) ABRecordRef originRecord;
#pragma clang diagnostic pop
///唯一标识
@property (nonatomic ,assign) int32_t recordID;

///需要更新
@property (nonatomic ,assign ,readonly) BOOL needUpdate;

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"

///以ABRecord实例化方法
-(instancetype)initWithABRecord:(ABRecordRef)ABRecord;

///将模型转化为ABRecord对象
-(void)transferToABRecordWithCompletion:(void(^)(ABRecordRef aRecord))completion;
#pragma clang diagnostic pop

///重置联系人更新状态
/**
 注：
 模型属性发生改变时，会改变对应的ABRecord对象，此时模型会被标记为需要更新状态
 */
-(void)setUpdated;

@end

@interface DWContactLabelModel : NSObject

///标签名
@property (nonatomic ,copy) NSString * label;

///标签值
@property (nonatomic ,strong) id labelValue;

@end

@interface DWContactLabelStringModel : DWContactLabelModel

///字符串类型标签值
@property (nonatomic ,strong) NSString * labelValue;

@end

@interface DWContactLabelDictionaryModel : DWContactLabelModel

///字典类型标签值
@property (nonatomic ,strong) NSDictionary * labelValue;

@end

@interface DWContactLabelDateModel : DWContactLabelModel

///日期类型标签值
@property (nonatomic ,strong) NSDate * labelValue;

@end
