//
//  MMMonitorConfig.h
//  Msg_remainder
//
//  Created by yuhanle on 2017/5/4.
//  Copyright © 2017年 tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 APP 角标消息
 */
extern NSString * const MMMonitorID_APP;
/**
 主页面左上角菜单入口消息
 */
extern NSString * const MMMonitorID_MainHome;
/**
 主页面右上角添加入口消息
 */
extern NSString * const MMMonitorID_MainAdd;
/**
 侧边栏我的消息入口消息
 */
extern NSString * const MMMonitorID_MsgCenter;
/**
 侧边栏我的保险入口消息
 */
extern NSString * const MMMonitorID_Insurance;
/**
 我的保险中待支付消息
 */
extern NSString * const MMMonitorID_WaitPay;
/**
 我的保险中待审核消息
 */
extern NSString * const MMMonitorID_WaitShenhe;
/**
 我的保险中历史保单消息
 */
extern NSString * const MMMonitorID_History;
/**
 侧边栏我的订单入口消息
 */
extern NSString * const MMMonitorID_Order;
/**
 侧边栏我的车库入口消息
 */
extern NSString * const MMMonitorID_Garage;
/**
 侧边栏门店服务入口消息
 */
extern NSString * const MMMonitorID_StoreService;
/**
 离线地图入口消息
 */
extern NSString * const MMMonitorID_Offline;
/**
 新增车辆的消息
 */
extern NSString * const MMMonitorID_Bike_Add;

@interface MMMonitorConfig : NSObject

@end
