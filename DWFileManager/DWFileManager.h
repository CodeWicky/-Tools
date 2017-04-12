//
//  DWFileManager.h
//  video
//
//  Created by Wicky on 2017/4/12.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 DWFileManager
 文件工具类
 
 version 1.0.0
 提供日常文件操作方法
 
 */

@interface DWFileManager : NSObject

#pragma mark --- 沙盒相关 ---
///沙盒的主目录路径
+(NSString *)dw_HomeDir;

///沙盒中Documents的目录路径
+(NSString *)dw_DocumentsDir;

///沙盒中Library的目录路径
+(NSString *)dw_LibraryDir;

///沙盒中Libarary/Preferences的目录路径
+(NSString *)dw_PreferencesDir;

///沙盒中Library/Caches的目录路径
+(NSString *)dw_CachesDir;

///沙盒中tmp的目录路径
+(NSString *)dw_TmpDir;

#pragma mark --- 获取文件属性 ---
///根据key获取文件某个属性
+(id)dw_AttributeOfItemAtPath:(NSString *)path forKey:(NSString *)key;

///根据key获取文件某个属性(错误信息error)
+(id)dw_AttributeOfItemAtPath:(NSString *)path forKey:(NSString *)key error:(NSError **)error;

///获取文件属性集合
+(NSDictionary *)dw_AttributesOfItemAtPath:(NSString *)path;

///获取文件属性集合(错误信息error)
+(NSDictionary *)dw_AttributesOfItemAtPath:(NSString *)path error:(NSError **)error;

#pragma mark --- 存在性 ---
///文件夹存在
+(BOOL)dw_IsDirectoryAtPath:(NSString *)path;

///文件存在
+(BOOL)dw_IsFileAtPath:(NSString *)path;

#pragma mark --- 遍历文件夹 ---
/**
 文件遍历
 
 @param path 目录的绝对路径
 @param deep 是否深遍历
 @return 遍历结果数组
 
 注：
 1. 浅遍历：返回当前目录下的所有文件和文件夹
 2. 深遍历：返回当前目录下及子目录下的所有文件和文件夹
 */
+(NSArray *)dw_ListFilesInDirectoryAtPath:(NSString *)path deep:(BOOL)deep;

#pragma mark --- 文件夹操作 ---

///创建文件夹
+(BOOL)dw_CreateDirectoryAtPath:(NSString *)path;

///创建文件夹并返回错误信息
+(BOOL)dw_CreateDirectoryAtPath:(NSString *)path error:(NSError **)error;

///判断文件夹是否为空
+(BOOL)dw_IsDirectoryIsEmptyAtPath:(NSString *)path;

///删除对应路径的文件或文件夹
+(BOOL)dw_RemoveItemAtPath:(NSString *)path;

///清空文件夹
+(BOOL)dw_ClearDirectoryAtPath:(NSString *)path;

///清除cache文件夹
+(BOOL)dw_ClearCache;

///清除Tmp
+(BOOL)dw_ClearTmp;

#pragma mark --- 文件操作 ---

/**
 创建文件并写入数据

 @param path 创建路径
 @param content 数据
 @param overwrite 是否覆盖
 @param error 错误信息
 @return 是否成功
 */
+(BOOL)dw_CreateFileAtPath:(NSString *)path content:(NSObject *)content overwrite:(BOOL)overwrite error:(NSError **)error;

///创建文件
+(BOOL)dw_CreateFileAtPath:(NSString *)path;

///写数据至文件
+(BOOL)dw_WriteFileAtPath:(NSString *)path content:(NSObject *)content error:(NSError *__autoreleasing *)error;

///复制文件，是否覆盖(错误信息error)
+(BOOL)dw_CopyItemAtPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite error:(NSError **)error;

///移动文件，是否覆盖(错误信息error)
+(BOOL)dw_MoveItemAtPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite error:(NSError **)error;

///获取文件名(是否包含后缀)
+(NSString *)dw_FileNameAtPath:(NSString *)path extention:(BOOL)extention;

///获取文件夹路径
+(NSString *)dw_DirectoryPathAtPath:(NSString *)path;

///获取后缀名
+(NSString *)dw_ExtentionAtPath:(NSString *)path;

#pragma mark --- 统计操作 ---
///统计文件夹大小
+(NSNumber *)dw_SizeOfDirectoryAtPath:(NSString *)path;

///统计问价大小
+(NSNumber *)dw_SizeOfFileAtPath:(NSString *)path;

///获取创建文件时间
+(NSDate *)dw_CreationDateOfItemAtPath:(NSString *)path;

///获取文件修改时间
+(NSDate *)dw_ModificationDateOfItemAtPath:(NSString *)path;

///判断目录是否可以执行
+(BOOL)dw_IsExecutableItemAtPath:(NSString *)path;

///判断目录是否可读
+(BOOL)dw_IsReadableItemAtPath:(NSString *)path;

///判断目录是否可写
+(BOOL)dw_IsWritableItemAtPath:(NSString *)path;

@end

/**
 搜索文件的结果
 */
@interface DWFileManagerFile : NSObject

///当前文件名
@property (nonatomic ,copy) NSString * fileName;

///如果当前文件是文件夹则返回当前文件夹中的所有文件
@property (nonatomic ,strong) NSArray * files;

///当前文件路径
@property (nonatomic ,copy) NSString * path;

///如果当前文件是文件夹，是否展示当前文件夹中的内容
@property (nonatomic ,assign) BOOL showContent;

///当前文件是否为文件夹
@property (nonatomic ,assign) BOOL isFolder;

///当前文件处于搜索任务中的深度
@property (nonatomic ,assign) NSUInteger depth;

@end
