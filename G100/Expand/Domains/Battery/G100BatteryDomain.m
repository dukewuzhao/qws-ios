//
//  G100BatteryDomain.m
//  G100
//
//  Created by yuhanle on 2016/12/28.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BatteryDomain.h"

@implementation G100BatteryDomain

- (NSString *)getBatteryType
{
    switch (self.type) {
        case 0:
            return @"未知电池";
            break;
        case 1:
            return @"铅酸电池";
            break;
        case 2:
            return @"锂电池";
            break;
        default:
            return @"未知电池";
            break;
    }
    return nil;
}
@end

@implementation BatteryBindStatus

@end

@implementation BatteryLastUse

@end

@implementation BatteryPerformance

@end

@implementation BatteryUseCycle

@end

@implementation BatteryLoss

- (void)setList:(NSArray<BatteryLossDetail *> *)list {
    if (NOT_NULL(list)) {
        _list = [list mapWithBlock:^id(id item, NSInteger idx) {
            if (INSTANCE_OF(item, NSDictionary)) {
                return [[BatteryLossDetail alloc] initWithDictionary:item];
            }else if(INSTANCE_OF(item, BatteryLossDetail)){
                return item;
            }
            return nil;
        }];
    }
}

@end

@implementation BatteryLossDetail

- (void)setDate:(NSString *)date {
    _date = date;
    
    NSDateFormatter *formatter = [NSDateFormatter dateFormatterWithFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *result = [formatter dateFromString:date];
    
    NSDate *currentDate = [NSDate date];
    
    NSString *year = [NSString stringWithFormat:@"%@", @(result.year)];
    NSString *month = [NSString stringWithFormat:@"%@", @(result.month)];
                       
    if (result.year == currentDate.year && result.month == currentDate.month) {
        _chartDisplayDate = @"本月";
    }else {
        _chartDisplayDate = [NSString stringWithFormat:@"%@\n%@月", year, month];
    }
}

- (void)setLoss:(CGFloat)loss {
    _loss = loss;
    _remain = 1-loss;
}

@end

@implementation BatteryCycle

- (void)setList:(NSArray<BatteryCycleDetail *> *)list {
    if (NOT_NULL(list)) {
        _list = [list mapWithBlock:^id(id item, NSInteger idx) {
            if (INSTANCE_OF(item, NSDictionary)) {
                return [[BatteryCycleDetail alloc] initWithDictionary:item];
            }else if(INSTANCE_OF(item, BatteryCycleDetail)){
                return item;
            }
            return nil;
        }];
    }
}

@end

@implementation BatteryCycleDetail

- (void)setDate:(NSString *)date {
    _date = date;
    
    NSDateFormatter *formatter = [NSDateFormatter dateFormatterWithFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *result = [formatter dateFromString:date];
    
    NSDate *currentDate = [NSDate date];
    
    NSString *year = [NSString stringWithFormat:@"%@", @(result.year)];
    NSString *month = [NSString stringWithFormat:@"%@", @(result.month)];
    
    if (result.year == currentDate.year && result.month == currentDate.month) {
        _chartDisplayDate = @"本月";
    }else {
        _chartDisplayDate = [NSString stringWithFormat:@"%@\n%@月", year, month];
    }
}

@end
