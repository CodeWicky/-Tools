//
//  NSDate+DWDateUtils.h
//  ddd
//
//  Created by Wicky on 16/10/11.
//  Copyright © 2016年 Wicky. All rights reserved.
//
/*
 NSDate+DWDateUtils
 
 NSDate的扩展类
 方便查看日期的每一个属性
 
 version 1.0.0
 
 添加日期元素的属性查看
 添加是否闰年属性
 添加生成指定时间的NSDate实例api
 添加时区转换api
 添加时间戳属性
 添加时间描述
 
 */
#import <Foundation/Foundation.h>

@interface NSDate (DWDateUtils)
/**
 返回当前日期天数
 */
@property (nonatomic ,assign ,readonly) NSInteger day;
/**
 返回当前日期月份
 */
@property (nonatomic ,assign ,readonly) NSInteger month;
/**
 返回当前日期年份
 */
@property (nonatomic ,assign ,readonly) NSInteger year;
/**
 返回当前日期为周几
 注：1为周日，2为周一，依次排列
 */
@property (nonatomic ,assign ,readonly) NSInteger weekDay;
/**
 返回当前日期小时数
 */
@property (nonatomic ,assign ,readonly) NSInteger hour;
/**
 返回当前日期分钟数
 */
@property (nonatomic ,assign ,readonly) NSInteger minute;
/**
 返回当前日期秒数
 */
@property (nonatomic ,assign ,readonly) NSInteger second;
/**
 返回当前时区数
 */
@property (nonatomic ,assign ,readonly) NSInteger GMTNum;
/**
 返回当前月份总天数
 */
@property (nonatomic ,assign ,readonly) NSInteger dayCountOfCurrentMonth;
/**
 返回当前日期为当月第几周
 */
@property (nonatomic ,assign ,readonly) NSInteger weekOfCurrentMonth;
/**
 返回当前日期为当年第几周
 */
@property (nonatomic ,assign ,readonly) NSInteger weekOfCurrentYear;
/**
 返回当前日期为当年第几天
 */
@property (nonatomic ,assign ,readonly) NSInteger dayOfCurrentYear;
/**
 返回当前是否为闰年
 */
@property (nonatomic ,assign ,readonly) BOOL isLeapYear;
/**
 返回日期字符串
 */
@property (nonatomic ,strong ,readonly) NSString * dateString;
/**
 返回时间字符串
 */
@property (nonatomic ,strong ,readonly) NSString * timeString;

/**
 返回时间戳
 */
@property (nonatomic ,assign ,readonly) NSInteger timeStamp;

/**
 转换为中国时区（GMT+8）date
 */
-(NSDate *)translateToChina;

/**
 转换为GMTNum时区的date
 */
-(NSDate *)translateToGMT:(NSInteger)GMTNum;

/**
 转换为系统时区的date
 */
-(NSDate *)translateToSystemZone;

/**
 以年月日时分秒生成date
 */
+(NSDate *)dateWithYear:(NSInteger)year
                  month:(NSInteger)month
                    day:(NSInteger)day
                   hour:(NSInteger)hour
                 minute:(NSInteger)minute
                 second:(NSInteger)second
                    GMT:(NSInteger)GMTNum;

/**
 以年月日生成date
 */
+(NSDate *)dateWithYear:(NSInteger)year
                  month:(NSInteger)month
                    day:(NSInteger)day
                    GMT:(NSInteger)GMTNum;

/**
 以时分秒生成日期
 */
+(NSDate *)dateWithHour:(NSInteger)hour
                 minute:(NSInteger)minute
                 second:(NSInteger)second
                    GMT:(NSInteger)GMTNum;
/**
 已整数生成date
 number形如20161019
 */
+(NSDate *)dateWithNumber:(NSInteger)number
                      GMT:(NSInteger)GMTNum;

/**
 与时间戳相差的时间描述
 */
-(NSString *)distantStringSinceTimeStamp:(NSInteger)timeStamp;

/**
 与date相差的时间描述
 */
-(NSString *)distantStringSinceDate:(NSDate *)date;
@end
