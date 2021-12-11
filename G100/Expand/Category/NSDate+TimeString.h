//
//  NSDate+TimeString.h
//  G100
//
//  Created by 天奕 on 15/12/16.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (TimeString)

+ (NSString *)getUTCFormateDate:(NSString *)dateStr;
+ (NSString *)getCurrentTime;

/**
 *  获取天气预报的时间格式化字符串
 *
 *  @param dateStr 时间串
 *
 *  @return 符合天气预报的时间字符串
 */
+ (NSString *)getWeatherReportTimeWithDate:(NSString *)dateStr;

/**
 *  获取消息的时间格式化字符串
 *
 *  @param timeSp 时间戳
 *
 *  @return 符合时间的字符串
 */
+ (NSString *)getMsgTimeWithSp:(long)timeSp;

/**
 *  获取定位时间格式化字符串
 *  @param timeStr 时间戳
 *
 *  @return 符合时间的字符串
 */
+ (NSString *)tl_locationTimeParase:(NSString *)timeStr;

/**
 *  获取某个时间距离当天时间的间隔
 *
 *  @param dateStr 当前时间的字符串
 *
 *  @return 时间间隔 X天XX小时XX分钟
 */
+ (NSString *)getTimeIntervalFromNowWithDateStr:(NSString *)dateStr;

/**
 *  获取某个时间距离当天时间的间隔
 *
 *  @param dateStr 当前时间的字符串
 *
 *  @return 时间间隔 X天
 */
+ (int)getTimeIntervalDaysFromNowWithDateStr:(NSString *)dateStr;

/**
 *  获取有星期的时间格式字符串
 *
 *  @param time 某个时间字符串
 *
 *  @return 时间格式字符串 XX年XX月XX日 星期X
 */
+ (NSString *)getWeekTimeStrWithDateStr:(NSString *)time;

/**
 *  获取简要时间格式字符串
 *
 *  @param time 某个时间字符串
 *
 *  @return 时间格式字符串 HH:ss
 */
+ (NSString *)getSummaryTimeStrWithDateStr:(NSString *)time;


/**
 *  根据天数返回年月日时间段
 *
 *  @param days 天数
 *  @return 时间段字符串
 */
+ (NSString *)getDateIntervalWithDays:(NSInteger)timeInterval;

/**
 *  根据时间戳 计算和当前日期的间隔
 *
 *  @param timeStamp 时间戳
 *  @return **年**月**日
 */
+ (NSString *)getDateStrWithTimeStamp:(NSString *)timeStamp;

/**
 时间戳转换成时间

 @param timeString 时间戳
 @return 
 */
+ (NSString *)timeWithTimeIntervalString:(NSString *)timeString;


+ (NSInteger)distanceInDaysToDate:(NSString *)anotherDate;


/**
 秒转换成分秒
 
 @param totalTime 秒
 @return *分*秒
 */
+ (NSString *)getMMSSFromSS:(int)totalTime;
@end
