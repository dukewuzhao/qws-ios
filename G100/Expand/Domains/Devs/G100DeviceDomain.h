//
//  G100DeviceDomain.h
//  G100
//
//  Created by yuhanle on 16/6/30.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"
#import "G100DeviceDomainExpand.h"

@class G100DeviceDomainExpand;
@class G100DevAlertorStatus;
@class G100DeviceFunction;
@class G100DeviceSecuritySetting;
@class G100DeviceServiceInfo;
@class G100DeviceAlertorInfo;
@class G100DeviceSecurityWxNotify;
@class G100DeviceSecurityPhoneNotify;

/**
 *  设备列表 2.0
 */
@interface G100DeviceDomain : G100BaseDomain

@property (nonatomic, assign) NSInteger device_id; //!< 设备id 当 model_type_id == 11 时 表示智能电池的 battery_id
@property (nonatomic, copy) NSString *name; //!< 设备名称
@property (nonatomic, assign) NSInteger type; //!< 类型
@property (nonatomic, assign) NSInteger model_id; //!< 设备型号
@property (nonatomic, assign) NSInteger state; //!< 设备状态
@property (nonatomic, assign) NSInteger main_device; //!<主设备标志 0 非主设备 1 主设备
@property (nonatomic, copy) NSString *sn; //!< 设备SN号
@property (nonatomic, copy) NSString *qr; //!< 二维码
@property (nonatomic, copy) NSString *pcb; //!< 硬件PCB版本
@property (nonatomic, assign) NSInteger comm_mode; //!< 与服务端通信模式
@property (nonatomic, copy) NSString *warranty; //!< 硬件保修截止日期
@property (nonatomic, copy) NSString *origin_firm; //!< 出场固件版本
@property (nonatomic, copy) NSString *firm; //!< 当前固件版本
@property (nonatomic, assign) NSInteger model_type_id; //<!设备型号类型 1 前装单品 2 后装单品 3 插卡激活 4 套装 5 G500 6后装单品的机卡分离 10电动车 11智能电池 12 G800
@property (nonatomic, strong) G100DeviceFunction *func; //!< 设备功能
@property (nonatomic, strong) G100DeviceSecuritySetting *security; //!< 安防设置
@property (nonatomic, strong) G100DeviceServiceInfo *service; //!< 服务期信息
@property (nonatomic, assign) NSInteger seq; //!< 服务器默认设备列表排序
@property (nonatomic, copy) NSString *add_url; //!< 添加设备url，用作app端生成二维码使用

@property (nonatomic, assign) NSInteger index; //!< 选择设备的索引序号 用于GPS页面

// 本地属性
@property (nonatomic, assign) NSInteger alarm_bell_time; //!< 报警响铃时长 分钟
@property (nonatomic, assign) NSInteger remote_ctrl_mode; //!< 远程控制模式 1 蓝牙 2 GPRS
@property (nonatomic, assign) BOOL location_display; //!< 是否显示设备位置信息

// 提醒记录
@property (nonatomic, assign) BOOL left30remainder; //!< 服务期剩余30天提醒状态
@property (nonatomic, assign) BOOL left20remainder; //!< 服务期剩余20天提醒状态
@property (nonatomic, assign) BOOL left15remainder; //!< 服务期剩余15天提醒状态
@property (nonatomic, assign) BOOL left10remainder; //!< 服务期剩余10天提醒状态

- (BOOL)isSpecialChinaMobileDevice;

- (BOOL)isLostDevice;

- (BOOL)isOverdue;

- (BOOL)canRechargeAndOverdue;

- (BOOL)canRecharge;

- (BOOL)needOverdueWarn;

- (NSInteger)leftdays;

- (NSString *)securityModeResourceImageName;

/** 设备状态是否正常*/
- (BOOL)isNormalDevice;

/** 设备是否是主设备*/
- (BOOL)isMainDevice;

/** 设备是否是前装设备*/
- (BOOL)isFrontDevice;

/** 设备是否是G500设备*/
- (BOOL)isG500Device;

/** 设备是否是G800设备*/
- (BOOL)isG800Device;

/** 设备是否是普通设备*/
- (BOOL)isGPSDevice;

/** 设备是否是智能电池设备*/
- (BOOL)isSmartBatteryDevice;

/**
 判断是够是后装单品机卡分离设备
 
 @return YES/NO
 */
- (BOOL)isAfterInstallSingleDevice;

/** 设备是否是移动定制设备*/
- (BOOL)isChinaMobileCustomMode;
@end

/**
 *  设备功能 2.0
 */
@interface G100DeviceFunction : G100BaseDomain

@property (nonatomic, copy) NSString *controller_key; //!< 控制器密码
@property (nonatomic, strong) G100DeviceAlertorInfo *alertor; //!< 报警器选项
@property (nonatomic, assign) NSInteger remote_power; //!< 远程断电

@end

/**
 *  安防设置 2.0
 */
@interface G100DeviceSecuritySetting : G100BaseDomain

@property (nonatomic, assign) NSInteger mode; //!< 安防模式 1低 2标准 3警戒 9撤防 8丢车
@property (nonatomic, assign) NSInteger acc_on_notify; //!< 电门打开通知
@property (nonatomic, strong) G100DeviceSecurityWxNotify *wx_notify; //!< 微信报警
@property (nonatomic, strong) G100DeviceSecurityPhoneNotify *phone_notify; //!< 电话报警
@property (nonatomic, assign) NSInteger ignore_notify_time; //!< 忽略报警时间（分钟）

@end

/**
 *  服务期信息 2.0
 */
@interface G100DeviceServiceInfo : G100BaseDomain

@property (nonatomic, copy) NSString *activated_date; //!< 激活日期
@property (nonatomic, copy) NSString *binded_date; //!< 绑定日期
@property (nonatomic, assign) NSInteger binded_days; //!< 已绑定天数
@property (nonatomic, copy) NSString *end_date; //!< 服务结束日期
@property (nonatomic, assign) NSInteger left_days; //!< 服务剩余天数

@end

/**
 *  报警器功能 2.0
 */
@interface G100DeviceAlertorInfo : G100BaseDomain

@property (nonatomic, assign) NSInteger switch_on; //!< 报警器开关 0 不适用 -1 无报警器 1 有报警器
@property (nonatomic, copy) NSString *version; //!< 报警器版本
@property (nonatomic, assign) NSInteger remote_ctrl; //!< 远程控制功能 报警版本 0 无此功能 1 有此功能
@property (nonatomic, strong) NSArray *remote_ctrl_func; //!< 报警器控制界面按钮功能 0 无此功能 1 有此功能 （按数组顺序：设防/撤防/开电门/关电门/开座桶/开中撑锁/寻车/开龙头锁）
@property (nonatomic, strong) NSArray *remote_ctrl_func_seq; //!< 功能排序
@property (nonatomic, strong) G100DevAlertorStatus *status;
@property (nonatomic, strong) G100DevAlertorSound *alertor_sound; //!< 报警声音设置

@end

/**
 *  微信报警
 */
@interface G100DeviceSecurityWxNotify : G100BaseDomain

@property (nonatomic, assign) NSInteger switch_on; //!< 微信报警开关 0 不通知 1 通知
@property (nonatomic, copy) NSString *nick_name; //!< 微信昵称
@property (nonatomic, copy) NSString *label; //!< 描述标签

@end

/**
 *  电话报警 2.0
 */
@interface G100DeviceSecurityPhoneNotify : G100BaseDomain

@property (nonatomic, assign) NSInteger switch_on; //!< 电话报警开关 0 不通知 1 通知
@property (nonatomic, assign) NSInteger month_limit; //!< 月限额
@property (nonatomic, assign) NSInteger used; //!< 已拨打且接通次数
@property (nonatomic, copy) NSString *label; //!< 描述标签
@property (nonatomic, copy) NSString *caller_num; //!< 呼叫者号码
@property (nonatomic, copy) NSString *caller_name; //!< 呼叫者号码名称
@property (nonatomic, copy) NSString *callee_num; //!< 告警电话接收号码

@end

@interface G100DeviceFirmDomain : G100BaseDomain

@property (nonatomic, copy) NSString *version; //!< 硬件版本 "version":"Project Version: G200.TY01.V25.T60120"
@property (nonatomic, copy) NSString *sn; //!< 硬件sn号
@property (nonatomic, copy) NSString *imsi; //!< 硬件ismi号
@property (nonatomic, copy) NSString *imei; //!< 硬件imei号

@end

