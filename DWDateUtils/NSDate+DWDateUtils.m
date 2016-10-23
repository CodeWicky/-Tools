//
//  NSDate+DWDateUtils.m
//  ddd
//
//  Created by Wicky on 16/10/11.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#import "NSDate+DWDateUtils.h"

#define Calendar [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian]
#define DateTo(x) [Calendar component:x fromDate:self]
@implementation NSDate (DWDateUtils)
@dynamic day,month,year,weekDay,hour,minute,second,weekOfCurrentMonth,weekOfCurrentYear,dayCountOfCurrentMonth,dayOfCurrentYear;
-(NSInteger)day
{
    return DateTo(NSCalendarUnitDay);
}

-(NSInteger)month
{
    return DateTo(NSCalendarUnitMonth);
}

-(NSInteger)year
{
    return DateTo(NSCalendarUnitYear);
}

-(NSInteger)hour
{
    return DateTo(NSCalendarUnitHour);
}

-(NSInteger)minute
{
    return DateTo(NSCalendarUnitMinute);
}

-(NSInteger)second
{
    return DateTo(NSCalendarUnitSecond);
}

-(NSInteger)weekDay
{
    return DateTo(NSCalendarUnitWeekday);
}


-(NSInteger)weekOfCurrentMonth
{
    return DateTo(NSCalendarUnitWeekOfMonth);
}

-(NSInteger)weekOfCurrentYear
{
    return DateTo(NSCalendarUnitWeekOfYear);
}

-(NSInteger)dayCountOfCurrentMonth
{
    return [Calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:self].length;
}

-(NSInteger)dayOfCurrentYear
{
    int a[] = {31,28,31,30,31,30,31,31,30,31,30,31};
    if (self.isLeapYear) {
        a[1] = 29;
    }
    NSInteger count = 0;
    for (int i = 1; i < self.month; i ++) {
        count += a[i - 1];
    }
    count += self.day;
    return count;
}

-(BOOL)isLeapYear
{
    NSDateComponents * comp = [Calendar components:(kCFCalendarUnitYear | kCFCalendarUnitMonth | kCFCalendarUnitDay) fromDate:self];
    [comp setMonth:2];
    [comp setDay:1];
    NSDate * dateFeb = [Calendar dateFromComponents:comp];
    return ([dateFeb dayCountOfCurrentMonth] == 29);
}

-(NSString *)dateString
{
    return [NSString stringWithFormat:@"%ld年%02ld月%02ld日",self.year,self.month,self.day];
}

-(NSString *)timeString
{
    return [NSString stringWithFormat:@"%02ld时%02ld分%02ld秒",self.hour,self.minute,self.second];
}

-(NSInteger)timeStamp
{
    return [self timeIntervalSince1970];
}

-(NSDate *)translateToGMT:(NSInteger)GMTNum
{
    return [NSDate dateWithTimeInterval:(GMTNum * 3600) sinceDate:self];
}

-(NSDate *)translateToChina
{
    return [self translateToGMT:8];
}

-(NSDate *)translateToSystemZone
{
    NSTimeZone * zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:self];
    return [self dateByAddingTimeInterval:interval];
}

+(NSDate *)dateWithNumber:(NSInteger)number GMT:(NSInteger)GMTNum
{
    NSInteger year = number / 10000;
    NSInteger temp = number % 10000;
    NSInteger month = temp / 100;
    NSInteger day = temp % 100;
    return [NSDate dateWithYear:year month:month day:day GMT:GMTNum];
}

+(NSDate *)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day GMT:(NSInteger)GMTNum
{
    return [NSDate dateWithYear:year month:month day:day hour:0 minute:0 second:0 GMT:GMTNum];
}

+(NSDate *)dateWithHour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second GMT:(NSInteger)GMTNum
{
    return [NSDate dateWithYear:[NSDate date].year month:[NSDate date].month day:[NSDate date].day hour:hour minute:minute second:second GMT:GMTNum];
}

+(NSDate *)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour
                 minute:(NSInteger)minute second:(NSInteger)second GMT:(NSInteger)GMTNum
{
    NSDateComponents * comp = [[NSDateComponents alloc] init];
    NSTimeZone * timeZone = [NSTimeZone timeZoneForSecondsFromGMT:GMTNum];
    comp.timeZone = timeZone;
    [comp setYear:year];
    [comp setMonth:month];
    [comp setDay:day];
    [comp setHour:hour];
    [comp setMinute:minute];
    [comp setSecond:second];
    return [Calendar dateFromComponents:comp];
}

-(NSString *)distantStringSinceTimeStamp:(NSInteger)timeStamp
{
    NSInteger distant = self.timeStamp - timeStamp;
    NSString * sufStr = @"前";
    if (distant < 0) {
        sufStr = @"后";
        distant = -distant;
    }
    NSString * preStr = @"";
    NSString * midStr = @"";
    if (distant >= 3600 * 24 * 365 * 4) {
        preStr = @"很久以";
    }
    else if (distant >= 3600 * 24 * 365)
    {
        midStr = @"年";
        preStr = [NSString stringWithFormat:@"%d",(distant / (3600 * 24 * 365) > 3)?3:(int)(distant / (3600 * 24 * 365))];
    }
    else if (distant >= 3600 * 24 * 183)
    {
        preStr = @"半年";
    }
    else if (distant >= 3600 * 24 * 30)
    {
        midStr = @"个月";
        preStr = [NSString stringWithFormat:@"%d",(distant / (3600 * 24 * 30) > 3)?3:(int)(distant / (3600 * 24 * 30))];
    }
    else if (distant >= 3600 * 24 * 15)
    {
        preStr = @"半个月";
    }
    else if (distant >= 3600 * 24)
    {
        midStr = @"天";
        preStr = [NSString stringWithFormat:@"%ld",distant / (3600 *24)];
    }
    else if (distant >= 3600)
    {
        midStr = @"小时";
        preStr = [NSString stringWithFormat:@"%ld",distant / 3600];
    }
    else if (distant >= 60)
    {
        midStr = @"分钟";
        preStr = [NSString stringWithFormat:@"%ld",distant / 60];
    }
    else
    {
        midStr = @"秒";
        preStr = [NSString stringWithFormat:@"%ld",distant];
    }
    return [NSString stringWithFormat:@"%@%@%@",preStr,midStr,sufStr];
}

-(NSString *)distantStringSinceDate:(NSDate *)date
{
    return [self distantStringSinceTimeStamp:date.timeStamp];
}

@end
