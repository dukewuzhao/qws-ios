//
//  G100BikesRuntimeDomain.h
//  G100
//
//  Created by William on 16/8/19.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

@class G100BikeRuntimeDomain;
@interface G100BikesRuntimeDomain : G100BaseDomain

@property (nonatomic, strong) NSArray <G100BikeRuntimeDomain *>* runtime;

@end


@interface G100BikeRuntimeDomain : G100BaseDomain

@property (nonatomic, assign) NSInteger bike_id; //!< 车辆id
@property (nonatomic, assign) CGFloat longi; //!< 经度
@property (nonatomic, assign) CGFloat lati; //!< 纬度
@property (nonatomic, copy) NSString *loc_desc; //!< 位置描述信息
@property (nonatomic, copy) NSString *loc_time; //!< 位置时间
@property (nonatomic, assign) NSInteger gps_level; //!< gps卫星信号级别
@property (nonatomic, assign) NSInteger bs_level; //!< 基站信号强度级别
@property (nonatomic, assign) NSInteger acc; //!< 电门状态 0关闭 1打开
@property (nonatomic, assign) CGFloat batt_vol; //!< 电池电压
@property (nonatomic, assign) CGFloat device_batt_vol; //!< 设备电池电压
@property (nonatomic, assign) CGFloat batt_soc; //!< 剩余电量百分比 -1未检测到电瓶 0电量无法计算
@property (nonatomic, assign) CGFloat expected_distance; //!< 预计行驶里程 公里
@property (nonatomic, assign) NSInteger controller_status; //!< 设备锁定状态 0未锁定 1加锁中 2加锁成功 3解锁中 -1获取出错
@property (nonatomic, copy) NSString *fault_code; //!< 车辆故障码 193通信故障 194对码故障
@property (nonatomic, assign) NSInteger gps_conn_mode; //!< GPS设备与服务端连接模式 0http模式方式 1udp长连接模式方式
@property (nonatomic, strong) G100DevAlertorStatus *alertor_status; //!< 报警器状态
@property (nonatomic, copy) NSString *theft_insurance; //!< 盗抢险状态
@property (nonatomic, copy) NSString *detection_begin_data; //!< 破案起开始时间
@property (nonatomic, strong) NSArray *device_runtimes;
@property (assign,nonatomic) NSInteger compute; //!< 是否计算电量

@end


@interface G100DeviceRuntimeDomain : G100BaseDomain

@property (nonatomic, assign) NSInteger device_id; //!< 设备id
@property (nonatomic, assign) CGFloat longi; //!< 经度
@property (nonatomic, assign) CGFloat lati; //!< 纬度
@property (nonatomic, copy) NSString * loc_desc; //!< 位置描述信息
@property (nonatomic, copy) NSString * loc_time; //!< 位置时间
@property (nonatomic, assign) NSInteger gps_level; //!< gps卫星信号级别
@property (nonatomic, assign) NSInteger bs_level; //!< 基站信号强度级别
@property (nonatomic, assign) NSInteger acc; //!< 电门状态 0关闭 1打开
@property (nonatomic, assign) CGFloat batt_vol; //!< 电池电压
@property (nonatomic, assign) CGFloat device_batt_vol; //!< 设备电池电压

@property (copy, nonatomic) NSString *bs_loc_time; /** 基站定位时间 */
@property (assign, nonatomic) CGFloat bs_longi; //基站定位经度
@property (assign, nonatomic) CGFloat bs_lati; //基站定位纬度
@property (copy, nonatomic) NSString *bs_loc_desc; // 基站定位位置描述
@property (assign, nonatomic) CGFloat last_accoff_longi; // 最后关电门时位置经度
@property (assign, nonatomic) CGFloat last_accoff_lati;  // 最后关电门时位置纬度


@end
