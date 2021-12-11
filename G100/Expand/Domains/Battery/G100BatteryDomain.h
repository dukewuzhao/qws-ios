//
//  G100BatteryDomain.h
//  G100
//
//  Created by yuhanle on 2016/12/28.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

@class BatteryBindStatus;
@class BatteryLastUse;
@class BatteryPerformance;
@class BatteryUseCycle;

@interface G100BatteryDomain : G100BaseDomain
/** 电池id*/
@property (nonatomic, assign) NSInteger battery_id;
/** 0-默认/1-充电中/-1-结束充电*/
@property (nonatomic, assign) NSInteger status;
/** 充电状态（1-智能涓流充/2-智能快充/3-智能恒压充）*/
@property (nonatomic, assign) NSInteger charging_status;
/** 剩余充电时间 只有在充电状态为1时才有值 -1默认*/
@property (assign, nonatomic) NSInteger remain_charging_time;
/** 电池使用时间 long:（Unix timestamp）*/
@property (nonatomic, assign) NSInteger use_duration;
/** 涓流充电/高功耗使用中/使用/xxxx*/
@property (nonatomic, copy) NSString *status_des;
/** 电池充电状态描述(涓流充电/高功耗使用中/使用/xxxx)*/
@property (copy, nonatomic) NSString *charging_status_des;
/** 建议充电/暂时不需要充电/预估还有多久充满*/
@property (nonatomic, copy) NSString *use_advice;
/** 当前电量*/
@property (nonatomic, assign) CGFloat current_elec;
/** 预期续航*/
@property (nonatomic, assign) CGFloat expe_distance;
/** 温度*/
@property (nonatomic, assign) CGFloat temperature;
/** 额定电压*/
@property (nonatomic, assign) CGFloat rated_v;
/** 电池类型 0 - 未知/1 - 铅酸/2 - 锂电*/
@property (nonatomic, assign) NSInteger type;
/** 绑定状态*/
@property (nonatomic, strong) BatteryBindStatus *bind_status;
/** 最后一次使用*/
@property (nonatomic, strong) BatteryLastUse *last_use;
/** 性能参数*/
@property (nonatomic, strong) BatteryPerformance *performance;
/** 循环使用参数*/
@property (nonatomic, strong) BatteryUseCycle *use_cycle;

- (NSString *)getBatteryType;
@end

@interface BatteryBindStatus : G100BaseDomain

/** 绑定状态*/
@property (nonatomic, assign) NSInteger status;
/** 车辆id*/
@property (nonatomic, assign) NSInteger bike_id;
/** 用户id*/
@property (nonatomic, assign) NSInteger user_id;

@end

@interface BatteryLastUse : G100BaseDomain

/** 最后一次充电时间*/
@property (nonatomic, copy) NSString *last_charging;
/** 充电时长（分钟）*/
@property (nonatomic, assign) NSInteger charging_duration;
/** 充电电量*/
@property (nonatomic, assign) NSInteger charging_elec;

@end

@interface BatteryPerformance : G100BaseDomain

/** 性能状态（0 - 10级）*/
@property (nonatomic, assign) NSInteger status;
/** 性能状态描述*/
@property (nonatomic, copy) NSString *status_des;
/** 建议*/
@property (nonatomic, copy) NSString *use_advice;
/** 额定容量（单位mAh）*/
@property (nonatomic, assign) CGFloat rated_c;
/** 有效容量（单位mAh）*/
@property (nonatomic, assign) CGFloat valid_c;

@end

@interface BatteryUseCycle : G100BaseDomain

/** 循环状态(0 - 10级)*/
@property (nonatomic, assign) NSInteger status;
/** 循环状态描述*/
@property (nonatomic, copy) NSString *status_des;
/** 建议*/
@property (nonatomic, copy) NSString *use_advice;
/** 使用时长（天）*/
@property (nonatomic, assign) NSInteger use_duration;
/** 额定循环次数*/
@property (nonatomic, assign) NSInteger rated_num;
/** 实际循环使用次数*/
@property (nonatomic, assign) NSInteger use_num;

@end

#pragma mark - 电池损耗
@class BatteryLossDetail;
@interface BatteryLoss : G100BaseDomain

/** 电池id*/
@property (nonatomic, assign) NSInteger battery_id;
/** 查询类型 0-按天/1-按周/2-按月*/
@property (nonatomic, assign) NSInteger query_type;
/** 损耗list*/
@property (nonatomic, strong) NSArray <BatteryLossDetail *> *list;

@end

@interface BatteryLossDetail : G100BaseDomain

/** 时间*/
@property (nonatomic, copy) NSString *date;
/** 损耗百分比*/
@property (nonatomic, assign) CGFloat loss;
/** 剩余百分比*/
@property (nonatomic, assign) CGFloat remain;
/** 图表显示时间*/
@property (nonatomic, copy) NSString *chartDisplayDate;

@end

#pragma mark - 电池循环次数
@class BatteryCycleDetail;
@interface BatteryCycle : G100BaseDomain

/** 电池id*/
@property (nonatomic, assign) NSInteger battery_id;
/** 查询类型 0-按天/1-按周/2-按月*/
@property (nonatomic, assign) NSInteger query_type;
/** 损耗list*/
@property (nonatomic, strong) NSArray <BatteryCycleDetail *> *list;

@end

@interface BatteryCycleDetail : G100BaseDomain

/** 时间*/
@property (nonatomic, copy) NSString *date;
/** 电池循环使用次数*/
@property (nonatomic, assign) CGFloat cycle;
/** 图表显示时间*/
@property (nonatomic, copy) NSString *chartDisplayDate;

@end
