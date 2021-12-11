//
//  G100DeviceDomainExpand.h
//  G100
//
//  Created by Tilink on 15/5/9.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

//############################# 报警器类型     ###################################
typedef enum : NSUInteger {
    DEV_ALERTOR_TYPE_HASALARM = 1,
    DEV_ALERTOR_TYPE_NOTAPPLICABLE = 0,
    DEV_ALERTOR_TYPE_NOALARM = -1
} DEV_ALERTOR_TYPE;

//############################# 报警器指令     ###################################
typedef enum : NSInteger {
    DEV_ALERTOR_COMMAND_SHEFANG     = 1,//  设防
    DEV_ALERTOR_COMMAND_CHEFANG     = 2,//  撤防
    DEV_ALERTOR_COMMAND_ACC         = 3,//  开关电门
    DEV_ALERTOR_COMMAND_FIND        = 4,//  找车
    DEV_ALERTOR_COMMAND_BARREL      = 5,//  开坐桶
    DEV_ALERTOR_COMMAND_MIDLOCK     = 6,//  开中撑锁
    DEV_ALERTOR_COMMAND_LEADLOCK    = 7,//  开龙头锁
    DEV_ALERTOR_COMMAND_ONEKEYSTART = 8,//  一键启动
    DEV_ALERTOR_COMMAND_CARCHASE    = 9//  追车报警
} DEV_ALERTOR_COMMAND;
//############################# 定位器与服务端的连接模式     ########################
typedef enum : NSInteger {
    DEV_LOCATOR_CONNMODE_HTTP = 0,//HTTP模式
    DEV_LOCATOR_CONNMODE_UDP  = 1//UDP长连接模式
} DEV_LOCATOR_CONNMODE;
//############################# 报警器状态设防撤防     #############################
typedef enum : NSInteger {
    DEV_ALERTOR_STATUS_SECURITY_UNKNOW = 0,//未知状态
    DEV_ALERTOR_STATUS_SECURITY_SHEFANG_UPLOADED = 1,//设防已上传
    DEV_ALERTOR_STATUS_SECURITY_SHEFANG_OK       = 2,//设防
    DEV_ALERTOR_STATUS_SECURITY_CHEFANG_UPLOADED = 3,//撤防已上传
    DEV_ALERTOR_STATUS_SECURITY_CHEFANG_OK       = 4//撤防
} DEV_ALERTOR_STATUS_SECURITY;
//############################# 报警器状态开关电门     #############################
typedef enum : NSInteger {
    DEV_ALERTOR_STATUS_ACC_UNKNOW  = 0,//未知状态
    DEV_ALERTOR_STATUS_ACC_OPEN_UPLOADED  = 1,//开电门已上传
    DEV_ALERTOR_STATUS_ACC_OPEN_OK        = 2,//电门开
    DEV_ALERTOR_STATUS_ACC_CLOSE_UPLOADED = 3,//关电门已上传
    DEV_ALERTOR_STATUS_ACC_CLOSE_OK       = 4//电门关
} DEV_ALERTOR_STATUS_ACC;


@class G100DevAlarmPushWx;
@class G100DevAlarmPushPhone;
@class G100DevAlertorSound;
@interface G100DevAlertorStatus : G100BaseDomain

/** 1 设防已上传 2 设防 3 撤防已上传 4 撤防 */
@property (nonatomic, assign) NSInteger security;
/** 1 开电门已上传 2 电门开 3 关电门已上传 4 电门关 */
@property (nonatomic, assign) NSInteger acc;

@end

@interface G100DeviceDomainExpand : G100BaseDomain

@end

@interface G100DevBindResultDomain : G100BaseDomain

@property (nonatomic, copy) NSString * devid; //!< 电动车id
@property (nonatomic, copy) NSString * logo_small; //!< 绑定界面使用品牌logo
@property (nonatomic, copy) NSString * channel; //!< 定位器分销渠道
@property (nonatomic, assign) NSInteger modelid; //!< 车型id
@property (nonatomic, copy) NSString * model; //!< 车型名称
@property (nonatomic, copy) NSString * pic_big; //!< 车辆型号大图
@property (nonatomic, copy) NSString * pic_small; //!< 车辆型号小图
@property (nonatomic, copy) NSString * channeltheme; //!< 厂商渠道品牌主题包
@property (nonatomic, copy) NSString * ownerphone; //!< 主用户号码
@property (nonatomic, copy) NSString * distchannel; //!< 渠道
@property (nonatomic, copy) NSString * brand; //!< 品牌
@property (nonatomic, copy) NSString * locatorname; //!< gps设备名称
@property (copy, nonatomic) NSString *device_id;
@property (copy, nonatomic) NSString *bike_id;
/** 定位器型号 1前装 2后装 3机卡分离 4套装 5 G500设备 10电动车*/
@property (assign, nonatomic) NSInteger locmodeltype;

@end

@interface G100DevAlarmPushWx : G100BaseDomain

@property (nonatomic, copy) NSString *label; //!< 开通微信报警后的描述
@property (nonatomic, copy) NSString *nickname; //!< 微信帐号昵称
@property (nonatomic, assign) NSInteger notify; //!< 微信报警功能开关

@end

@interface G100DevAlarmPushPhone : G100BaseDomain

@property (nonatomic, assign) NSInteger already; //!< 已经接听电话的次数
@property (nonatomic, copy) NSString *label; //!< 开通电话后的描述
@property (nonatomic, assign) NSInteger notify; //!< 电话报警功能开关
@property (nonatomic, assign) NSInteger total; //!< 电话报警次数上限
@property (nonatomic, copy) NSString *callernum; //!< 告警来电显示号码
@property (nonatomic, copy) NSString *callername; //!< 告警电话显示名称
@property (nonatomic, copy) NSString *calleenum; //!< 告警电话接收号码

@end

@class G100DevAlertorSoundFunc;
@interface G100DevAlertorSound : G100BaseDomain

@property (nonatomic, assign) BOOL enable; //!< 报警器声音设置 1可以设置 0不可设置
@property (nonatomic, strong) NSArray <G100DevAlertorSoundFunc *> *sounds; //!< 功能对应的声音

@end

@interface G100DevAlertorSoundFunc : G100BaseDomain

@property (nonatomic, assign) NSInteger func; //!< 功能id
@property (nonatomic, assign) NSInteger sound; //!< 声音id
@property (nonatomic, copy) NSString *funcName; //!< 功能对应的名称
@property (nonatomic, copy) NSString *soundDisplayName; //!< 声音对应显示的名称
@property (nonatomic, copy) NSString *soundName; //!< 声音对应的资源名称

/**
 *  根据func和sound 返回声音文件
 *
 *  @param func  功能id
 *  @param sound 声音id
 *
 *  @return 声音对应的资源名称
 */
- (NSString *)soundNameWithFunc:(NSInteger)func sound:(NSInteger)sound;

@end

@interface G100DevFirmDomain : G100BaseDomain

@property (nonatomic, copy) NSString *version; //!< 硬件版本 "version":"Project Version: G200.TY01.V25.T60120"
@property (nonatomic, copy) NSString *sn; //!< 硬件sn号
@property (nonatomic, copy) NSString *imsi; //!< 硬件ismi号
@property (nonatomic, copy) NSString *imei; //!< 硬件imei号

@end
