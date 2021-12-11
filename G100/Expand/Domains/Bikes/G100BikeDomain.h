//
//  G100BikeDomain.h
//  G100
//
//  Created by yuhanle on 16/6/30.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"


@class G100BrandInfoDomain;
@class G100ModelInfoDomain;
@class G100DeviceDomain;
@class G100BikeFeatureDomain;
@class G100TestResultDomain;
@class G100BikeUpdateInfoDomain;
/**
 *  车辆资料 2.0
 */
@interface G100BikeDomain : G100BaseDomain

@property (nonatomic, assign) NSInteger bike_id; //!< 车辆id
@property (nonatomic, copy) NSString *name; //!< 车辆名称
@property (nonatomic, assign) NSInteger user_id; //!< 用户id
@property (nonatomic, copy) NSString *is_master; //!< 是否车主
@property (nonatomic, assign) NSInteger state; //!< 车辆状态
@property (nonatomic, strong) G100BrandInfoDomain *brand; //!< 车辆品牌
@property (nonatomic, strong) G100ModelInfoDomain *model; //!< 车辆型号
@property (nonatomic, strong) NSArray <G100DeviceDomain *> *devices; //!< 设备列表 所有设备列表
@property (nonatomic, assign) NSInteger lost_count; //!< 丢车次数
@property (nonatomic, assign) NSInteger lost_id; //!< 丢车id，为0时表示不在丢车状态
@property (nonatomic, assign) NSInteger user_count; //!< 绑定用户数
@property (nonatomic, strong) G100BikeFeatureDomain *feature; //!< 车辆特征信息
@property (nonatomic, assign) NSInteger created_time; //!< 车辆添加时间，UTC时间戳(秒)
@property (nonatomic, copy) NSString *add_url; //!< 车辆绑定二维码
@property (nonatomic, assign) NSInteger bike_seq; //!< 车辆信息顺序
@property (nonatomic, assign) NSInteger bike_type; //!< 车辆类型 0 电动车  1 摩托车
@property (nonatomic, assign) CGFloat max_speed; //!< 车辆最高时速 不设置则为0
@property (nonatomic, assign) BOOL max_speed_on; //!< 车辆最高时速开关 默认为关
@property (nonatomic, strong) G100TestResultDomain *test_result; //!< 评测结果
@property (nonatomic, strong) NSDictionary *bikeRuntime; //!< 实时数据
@property (strong, nonatomic) NSDictionary *lastFindRecord; //!<最新一次寻车记录
@property (strong, nonatomic) G100BikeUpdateInfoDomain *bikeUpdateInfo; //需要更新电动车资料信息

@property (nonatomic, strong) NSArray <G100DeviceDomain *> *gps_devices; //!< 普通GPS设备列表
@property (nonatomic, strong) NSArray <G100DeviceDomain *> *battery_devices; //!< 智能电池设备列表

/** 是否车主*/
- (BOOL)isMaster;

/**
 是否摩托车

 @return YES/NO
 */
- (BOOL)isMOTOBike;

/** 返回该车辆的主设备*/
- (G100DeviceDomain *)mainDevice;

/** 车辆状态是否正常*/
- (BOOL)isNormalBike;

/** 是否处于丢车中*/
- (BOOL)isLostBike;

/** 返回可以远程控制的设备*/
- (G100DeviceDomain *)ableRemote_ctrlDevice;

/**
 判断是否带有智能电池设备

 @return 智能电池设备 device_id 表示智能电池的battery_id
 */
- (G100DeviceDomain *)hasSmartBatteryDevice;

/**
 已安全守护爱车天数

 @return 守护天数
 */
- (NSInteger)guardDays;

@end

/**
 *  车辆品牌 2.0
 */
@interface G100BrandInfoDomain : G100BaseDomain

@property (nonatomic, assign) NSInteger brand_id; //!< 品牌id 0值表示无品牌
@property (nonatomic, copy) NSString *name; //!< 品牌名称
@property (nonatomic, copy) NSString *channel; //!< 分销渠道
@property (nonatomic, copy) NSString *channel_theme; //!< 厂商渠道品牌主题包
@property (nonatomic, copy) NSString *service_num; //!< 厂商服务号码

/** 客户输入品牌 */
@property (copy, nonatomic) NSString *custbrand;
/** 客户输入厂商服务号码 */
@property (copy, nonatomic) NSString * custservicenum;

@end

/**
 *  车辆型号 2.0
 */
@interface G100ModelInfoDomain : G100BaseDomain

@property (nonatomic, assign) NSInteger model_id; //!< 型号id 0值表示无型号
@property (nonatomic, copy) NSString *name; //!< 型号名称
@property (nonatomic, copy) NSString *pic_big; //!< 型号图片大
@property (nonatomic, copy) NSString *pic_small; //!< 型号图片小

@end

/**
 *  车辆特征信息 2.0
 */
@interface G100BikeFeatureDomain : G100BaseDomain

@property (nonatomic, strong) NSArray *pictures; //!< 车辆图片
@property (nonatomic, copy) NSString *color; //!< 颜色
@property (nonatomic, assign) NSInteger type;// !< 类型
@property (nonatomic, copy) NSString *plate_number; //!< 车牌号
@property (nonatomic, copy) NSString *other_feature; //!< 其他特征
@property (nonatomic, copy) NSString *vin; //!< 车架号
@property (nonatomic, copy) NSString *motor_number; //!< 电机号
@property (nonatomic, assign) NSInteger integrity; //!< 资料完整度
@property (nonatomic, assign) NSInteger batteryInfo;//!<电池类型名称 1.铅酸电池 2.锂电池
@property (nonatomic, assign) CGFloat voltageInfo;//!<电池电压
@property (nonatomic, copy) NSString *cover_picture; //!< 车辆封面
@property (nonatomic, copy) NSString *cust_brand; //!< 品牌名

@end


