//
//  G100Constants.h
//  G100
//
//  Created by Tilink on 15/5/8.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

//############################# MODULE TAG ############################

//############################# TIME CONSTANT ########################
extern const NSTimeInterval kVMCToastDuration;
extern const NSTimeInterval kAnimationDuration;
extern const NSTimeInterval G100VCodeDuration;

//############################# 安全评分  #############################
extern const NSInteger MAX_COLOR;	//绿色
extern const NSInteger MIN_COLOR;	//红色
extern const NSInteger MAX_SCORE;
extern const NSInteger MIN_SCORE;
extern const CGFloat mRate;         //颜色和分数比率

//############################# API     #############################
extern const NSInteger kApiPageStart;
extern const NSInteger kApiPageSize;

//############################# 网络错误提示     #############################
extern NSString * kError_Network_NotReachable;

//############################# 推送消息代码     #############################
enum {
    NOTI_MSG_CODE_DEV_SHAKE           = 1,//!< 震动
    NOTI_MSG_CODE_SWITCH_OPEN         = 2,//!< 电门打开
    NOTI_MSG_CODE_SWITCH_CLOSE        = 3,//!< 电门关闭
    NOTI_MSG_CODE_BATTERY_IN          = 4,//!< 电瓶插入
    NOTI_MSG_CODE_BATTERY_OUT         = 5,//!< 电瓶移除
    NOTI_MSG_CODE_VOLTAGE_LOW         = 6,//!< 低电压
    NOTI_MSG_CODE_DEV_FAULT           = 7,//!< 电动车故障
    NOTI_MSG_CODE_ILLEGAL_DIS         = 8,//!< 非法位移
    NOTI_MSG_CODE_MATCH_FAULT         = 9,//!< 对码故障
    NOTI_MSG_CODE_COMM_FAULT          = 10,//!< 通信故障
    NOTI_MSG_CODE_ALARM_REMOVE        = 11,//!< 报警器被移除
    NOTI_MSG_CODE_SWITCH_ILLEGAL_OPEN = 12,//!< 电门非法打开
    NOTI_MSG_CODE_ALARM_HANDLE        = 13,//!< 报警器操作
    NOTI_MSG_CODE_MUTE_HANDLE         = 14,//!< 静音操作
    NOTI_MSG_CODE_SOS_HANDLE          = 15,//!< SOS操作
    NOTI_MSG_CODE_LOST_DIS            = 19,//!< 丢车时车辆移动
    NOTI_MSG_CODE_DEV_STATUS_UPDATE   = 20,//!< 车辆状态更新
    NOTI_MSG_CODE_BIKE_INFO_UPDATE    = 22,//!< 车辆数据更新
    NOTI_MSG_CODE_VICE_USER_DELETED   = 23,//!< 主用户删除副用户
    NOTI_MSG_CODE_BIND_SUCCESS        = 41,//!< 绑定成功
    NOTI_MSG_CODE_BIND_FAIL           = 42,//!< 绑定失败
    NOTI_MSG_CODE_UNBIND_MAIN         = 43,//!< 主用户解绑，向副用户推送消息
    NOTI_MSG_CODE_NORMAL_DRIVE        = 50,//!< 正常行驶记录（不推送）
    NOTI_MSG_CODE_UNNORMAL_DRIVE      = 51,//!< 异常行驶记录（不推送）
    NOTI_MSG_CODE_DEV_AUTH_TO         = 61,//!< 电动车授权（发给主用户）
    NOTI_MSG_CODE_DEV_AUTH_FROM       = 62,//!< 电动车授权（发给申请人）
    NOTI_MSG_CODE_OTHRER_LOGIN        = 63,//!< 他设备登录提醒
    NOTI_MSG_CODE_BUY_SERVICE         = 71,//!< 购买服务
    NOTI_MSG_CODE_BUY_INSURANCE       = 72,//!< 购买保险
    NOTI_MSG_CODE_REMINDER_RENEWAL    = 73,//!< 续费提醒
    NOTI_MSG_CODE_REMINDER_THIEFINSURANCE_ACTIVE   = 74,//!< 盗抢险激活提醒
    NOTI_MSG_CODE_REMINDER_THIEFINSURANCE_REVIEWED = 75,//!< 盗抢险激活提醒
    NOTI_MSG_CODE_LOSECAR_FORCED_OFF               = 76,//!< 盗抢险丢车强制断电
    NOTI_MSG_CODE_THIEFINSURANCE_PAYOUT            = 77,//!< 盗抢险赔付
    NOTI_MSG_CODE_THIEFINSURANCE_RESTORE           = 78,//!< 盗抢险恢复
    NOTI_MSG_CODE_TEST_PUSH           = 98,//!< 推送测试唯一Code
    NOTI_MSG_CODE_DEFAULT_NOTIFY      = 99,// 默认类型（暂无分类的通知）
    NOTI_MSG_CODE_SETHOME_NOTIFY      = 110,//!< 设置家提醒
    NOTI_MSG_CODE_GOHOMEDISTANCE_NOTIFY            = 111,//!< 离家距离低电量提醒
    NOTI_MSG_CODE_UPGRADE__SUCCESS_NOTIFY            = 112,//!< OTA升级 定位器升级成功
    NOTI_MSG_CODE_UPGRADE__DOWNLOAD_TIMEOUT_NOTIFY   = 113,//!< OTA升级 定位器下载超时
    NOTI_MSG_CODE_UPGRADE_TIMEOUT_NOTIFY           = 114,//!< OTA升级 定位器升级超时
    NOTI_MSG_CODE_UPGRADE_FAIL_NOTIFY              = 115,//!< OTA升级 定位器升级失败
    
};

//############################# 用车报告代码     #############################
enum {
    REPT_MSG_CODE_UNNORMAL_DATA       = 0,//!< 非正常数据
    REPT_MSG_CODE_DEV_SHAKE           = 1,//!< 震动
    REPT_MSG_CODE_SWITCH_OPEN         = 2,//!< 电门打开
    REPT_MSG_CODE_SWITCH_CLOSE        = 3,//!< 电门关闭
    REPT_MSG_CODE_BATTERY_IN          = 4,//!< 电瓶插入
    REPT_MSG_CODE_BATTERY_OUT         = 5,//!< 电瓶移除
    REPT_MSG_CODE_VOLTAGE_LOW         = 6,//!< 低电压
    REPT_MSG_CODE_DEV_FAULT           = 7,//!< 电动车故障
    REPT_MSG_CODE_ILLEGAL_DIS         = 8,//!< 非法位移
    REPT_MSG_CODE_MATCH_FAULT         = 9,//!< 对码故障
    REPT_MSG_CODE_COMM_FAULT          = 10,//!< 通信故障
    REPT_MSG_CODE_ALARM_REMOVE        = 11,//!< 报警器被移除
    REPT_MSG_CODE_SWITCH_ILLEGAL_OPEN = 12,//!< 电门非法打开
    REPT_MSG_CODE_NORMAL_DRIVE        = 50,//!< 正常行驶记录（不推送）
    REPT_MSG_CODE_UNNORMAL_DRIVE      = 51//!< 异常行驶记录（不推送）
};

//############################# 震动消息等级     #############################
enum {
    DEV_SHAKE_LIGHT   = 10,//!< 轻度震动
    DEV_SHAKE_MEDIUM  = 20,//!< 中度震动
    DEV_SHAKE_SERIOUS = 30//<! 严重震动
};

//############################# 安防设置等级     #############################
typedef enum : NSInteger {
    DEV_SECSET_MODE_WARN      = 3,//!< 警戒模式
    DEV_SECSET_MODE_STANDARD  = 2,//!< 标准模式
    DEV_SECSET_MODE_NODISTURB = 1,//!< 免打扰模式
    DEV_SECSET_MODE_DEVLOST   = 8,//!< 寻车模式
    DEV_SECSET_MODE_DISARMING = 9//!< 关闭通知模式
} DEV_SECSET_MODE;

@interface G100Constants : NSObject

@end
