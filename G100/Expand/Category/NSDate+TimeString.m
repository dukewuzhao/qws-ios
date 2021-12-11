//
//  NSDate+TimeString.m
//  G100
//
//  Created by 天奕 on 15/12/16.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "NSDate+TimeString.h"

@implementation NSDate (TimeString)

+ (NSString *)getUTCFormateDate:(NSString *)dateStr {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSLog(@"newsDate = %@",dateStr);
    NSDate *newsDateFormatted = [dateFormatter dateFromString:dateStr];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    
    NSDate* current_date = [[NSDate alloc] init];
    
    NSTimeInterval time=[current_date timeIntervalSinceDate:newsDateFormatted];//间隔的秒数
    int month=((int)time)/(3600*24*30);
    int days=((int)time)/(3600*24);
    int hours=((int)time)%(3600*24)/3600;
    int minute=((int)time)%(3600*24)/60;
    
    NSString *dateContent;
    
    if(month!=0){
        
        dateContent = [NSString stringWithFormat:@"%@%i%@",@"   ",month,@"个月前发布"];
        
    }else if(days!=0){
        
        dateContent = [NSString stringWithFormat:@"%@%i%@",@"   ",days,@"天前发布"];
    }else if(hours!=0){
        
        dateContent = [NSString stringWithFormat:@"%@%i%@",@"   ",hours,@"小时前发布"];
    }else if (minute != 0 && minute >= 1){
        
        dateContent = [NSString stringWithFormat:@"%@%i%@",@"   ",minute,@"分钟前发布"];
    }else{
        dateContent = @"刚刚发布";
    }

    return dateContent;
}

+ (NSString*)getCurrentTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"dd日HH时mm分"];
    NSString *dateTime = [formatter stringFromDate:[NSDate date]];
    return [NSString stringWithFormat:@"%@发布",dateTime];
}

/*
 “XXXX发布”
 间隔
 描述
 <=10分钟	刚刚发布
 <=20分钟	10分钟前发布
 <=30分钟	20分钟前发布
 <=60分钟	半小时前发布
 <=2小时	1小时前发布（依次类推至23小时）
 24~48小时	1天前发布（依次类推至6天）
 7~14天	1周前发布（依次类推3周）
 4周~2月	1月前发布（依次类推至11月）
 >12月	1年前发布
 */
+ (NSString *)getWeatherReportTimeWithDate:(NSString *)dateStr {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *newsDateFormatted = [dateFormatter dateFromString:dateStr];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    
    NSDate* current_date = [[NSDate alloc] init];
    
    NSTimeInterval time=[current_date timeIntervalSinceDate:newsDateFormatted]; //间隔的秒数
    int month=((int)time)/(3600*24*30);
    int week=((int)time)/(3600*24*7);
    int days=((int)time)/(3600*24);
    int hours=((int)time)%(3600*24)/3600;
    int minute=((int)time)%(3600*24)/60;
    
    NSString *dateContent = @"--";
    
    if (month != 0 && month > 12) {
        dateContent = @"1年前";
    }else if (month != 0) {
        dateContent = [NSString stringWithFormat:@"%i月前", month];
    }else if (week != 0) {
        dateContent = [NSString stringWithFormat:@"%i周前", week];
    }else if (days != 0) {
        dateContent = [NSString stringWithFormat:@"%i天前", days];
    }else if (hours != 0) {
        dateContent = [NSString stringWithFormat:@"%i小时前", hours];
    }else if (minute != 0 && minute <= 10) {
        dateContent = @"刚刚";
    }else if (minute != 0 && minute <= 20) {
        dateContent = @"10分钟前";
    }else if (minute != 0 && minute <= 30) {
        dateContent = @"20分钟前";
    }else if (minute != 0 && minute <= 60) {
        dateContent = @"半小时前";
    }else
    {
        dateContent = @"刚刚";
    }
    
    return dateContent;
}


+ (NSString *)getMsgTimeWithSp:(long)timeSp {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setDateFormat:@"yy-MM-dd HH:mm:ss"];
    
    NSDate * confirmTimeSp = [NSDate dateWithTimeIntervalSince1970:timeSp];
    
    NSDate * nowDate = [NSDate dateToday0Dian];
    
    NSTimeInterval time = [confirmTimeSp timeIntervalSinceDate:nowDate];
    int month = -((int)time)/(3600*24*30);
    int days = -((int)time)/(3600*24);
    
    NSString *dateStr;
    
    if (month > 12) {
        [dateFormatter setDateFormat:@"yy-MM-dd"];
        dateStr = [dateFormatter stringFromDate:confirmTimeSp];
    }else if (days > 2) {
        [dateFormatter setDateFormat:@"M月dd日"];
        dateStr = [dateFormatter stringFromDate:confirmTimeSp];
    }else{
        if (time > 0) {
            [dateFormatter setDateFormat:@"a H:mm "];
            dateStr = [dateFormatter stringFromDate:confirmTimeSp];
        }else if (time > -24*60*60) {
            dateStr = @"昨天";
        }else{
            dateStr = @"前天";
        }
    }
    
    return dateStr;
}

#pragma mark - 定位时间解析
+ (NSString *)tl_locationTimeParase:(NSString *)timeStr {
    if (!timeStr || ![timeStr trim].length) {
        return @"";
    }
    
    NSString * result = nil;
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate * locationDate = [formatter dateFromString:timeStr];
    NSDate * nowDate = [NSDate dateToday0Dian]; //今天0点
    
    NSTimeInterval interval = [locationDate timeIntervalSinceDate:nowDate];
    
    if (interval > 0) {
        result = [NSString stringWithFormat:@"今天 %@", [timeStr substringWithRange:NSMakeRange(11, 5)]];
    }else if (interval > -24 * 60 * 60) {
        result = [NSString stringWithFormat:@"昨天 %@", [timeStr substringWithRange:NSMakeRange(11, 5)]];
    }else {
        result = [timeStr substringWithRange:NSMakeRange(5, 11)];
    }
    
    return result;
}

+ (NSString *)getTimeIntervalFromNowWithDateStr:(NSString *)dateStr {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    NSDate *someDayDate = [dateFormatter dateFromString:dateStr];
    NSDate *currentDate = [NSDate date];
    
    NSTimeInterval time = [currentDate timeIntervalSinceDate:someDayDate];

    int days = ((int)time)/(3600*24);
    int hours = ((int)time)%(3600*24)/3600;
    int minutes = ((int)time)%(3600*24)%3600/60;
    //int seconds = ((int)time)%(3600*24)%3600%60;
    
    NSString *dateContent = [NSString stringWithFormat:@"%@天%@小时%@分钟",@(days),@(hours),@(minutes)];
    
    return dateContent;
}

+ (int)getTimeIntervalDaysFromNowWithDateStr:(NSString *)dateStr {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *someDayDate = [dateFormatter dateFromString:dateStr];
    NSDate *currentDate = [NSDate date];
    
    NSTimeInterval time = [currentDate timeIntervalSinceDate:someDayDate];
    
    int days = ((int)time)/(3600*24);
    return days;
}

+ (NSString *)getWeekTimeStrWithDateStr:(NSString *)time {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *someDayDate = [dateFormatter dateFromString:time];
    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]; // 指定日历的算法 NSCalendarIdentifierGregorian,NSGregorianCalendar
    // NSDateComponent 可以获得日期的详细信息，即日期的组成
    NSDateComponents *comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:someDayDate];
    NSInteger year = comps.year;
    NSInteger month = comps.month;
    NSInteger day = comps.day;
    //NSInteger hour = comps.hour;
    //NSInteger minute = comps.minute;
    //NSInteger second = comps.second;
    NSInteger weekDay = comps.weekday;
    
    NSString * weekDayStr;
    
    switch (weekDay) {
        case 1:
            weekDayStr = @"星期日";
            break;
        case 2:
            weekDayStr = @"星期一";
            break;
        case 3:
            weekDayStr = @"星期二";
            break;
        case 4:
            weekDayStr = @"星期三";
            break;
        case 5:
            weekDayStr = @"星期四";
            break;
        case 6:
            weekDayStr = @"星期五";
            break;
        case 7:
            weekDayStr = @"星期六";
            break;
        default:
            break;
    }
    
    NSString * timeStr = [NSString stringWithFormat:@"%@年%@月%@日 %@",@(year),@(month),@(day),weekDayStr];
    return timeStr;
}

+ (NSString *)getSummaryTimeStrWithDateStr:(NSString *)time {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *someDayDate = [dateFormatter dateFromString:time];
    
    NSDateFormatter *newDateFormatter = [[NSDateFormatter alloc] init];
    [newDateFormatter setDateFormat:@"HH:mm"];
    
    NSString *tmp = [newDateFormatter stringFromDate:someDayDate];
    return tmp;
}

+ (NSString *)getDateIntervalWithDays:(NSInteger)timeInterval{
    int days = (int)timeInterval/(3600*24);
    int year  = days/365;
    int month = days%365/30;
    int day   = days%365%30;
    if (year>0) {
        return [NSString stringWithFormat:@"%d年%d月%d天",year,month,day];
    }else
    {
        if (month >0) {
            return [NSString stringWithFormat:@"%d月%d天",month,day];
        }else{
            return [NSString stringWithFormat:@"%d天",day];
        }
    }
}


+ (NSString *)getDateStrWithTimeStamp:(NSString *)timeStamp
{
    //转换成date
    NSTimeInterval time=[timeStamp doubleValue];
    NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
    
    //获取当前日期
    NSDate *currentDate = [NSDate date];
    
    //间隔总天数
    //创建日期格式化对象
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    //取两个日期对象的时间间隔：
    //这里的NSTimeInterval 是由c定义的:typedef double NSTimeInterval;
    NSTimeInterval timeInterval = [currentDate timeIntervalSinceDate:detaildate];
    //转换为想要的格式
    NSString *result =  [NSDate getDateIntervalWithDays:timeInterval];
    return result;
}

+ (NSString *)timeWithTimeIntervalString:(NSString *)timeString
{
    NSTimeInterval time=[timeString doubleValue];
    NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentDateStr = [dateFormatter stringFromDate: detaildate];

    return currentDateStr;

}

+ (NSInteger)distanceInDaysToDate:(NSString *)anotherDate {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *anotherdate = [formatter dateFromString:anotherDate];
    
    NSDate *date = [NSDate date];
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components:NSDayCalendarUnit fromDate:date toDate:anotherdate options:0];
    return components.day;
}

+ (NSString *)getMMSSFromSS:(int)totalTime {
    NSInteger seconds = totalTime;
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld", seconds/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld", seconds%60];
    //format of time
    NSString *format_time;
    if (str_minute.intValue == 0) {
        format_time = [NSString stringWithFormat:@"%@秒", str_second];
    }else {
        format_time = [NSString stringWithFormat:@"%@分%@秒", str_minute, str_second];
    }
    return format_time;
}

@end
