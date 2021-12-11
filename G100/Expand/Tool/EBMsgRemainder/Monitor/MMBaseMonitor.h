//
//  MMBaseMonitor.h
//  Msg_remainder
//
//  Created by yuhanle on 2017/4/17.
//  Copyright © 2017年 tilink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MsgRemainderCenter.h"
#import "MMMonitorConfig.h"

/**
 监控消息回调

 @param hasUnread 是否已读 决定是否显示提醒
 @param msgInfo 消息详情
 */
typedef void(^MMBaseMonitorComplete)(BOOL hasUnread, MsgRemainderInfo *msgInfo);

/**
 *  执行策略
 *
 *  每一个Monitor 表示一个业务方
 *  在程序启动时 由消息中心调用监控
 */
@interface MMBaseMonitor : NSObject

@property (copy, nonatomic) NSString *userid;
@property (copy, nonatomic) NSString *bikeid;
@property (copy, nonatomic) NSString *devid;

@property (copy, nonatomic) NSString *monitorid;
@property (strong, nonatomic) MsgRemainderInfo *orinalMsg;
@property (strong, nonatomic) MsgRemainderInfo *msginfo;

/**
 Monitor 关心的消息id
 */
@property (strong, nonatomic) NSArray *concernObjects;

/**
 当消息中心有变化时 通过此方法将结果告知观众
 */
@property (copy, nonatomic) MMBaseMonitorComplete monitorRes;

/**
 绑定一个附带userid 的监控

 @param userid 用户id
 @return 监控
 */
- (instancetype)initWithUserid:(NSString *)userid;

/**
 绑定一个附带userid bikeid 的监控

 @param userid 用户id
 @param bikeid 车辆id
 @return 监控
 */
- (instancetype)initWithUserid:(NSString *)userid bikeid:(NSString *)bikeid;

/**
 初始化数据 必须调用 super
 */
- (void)setupData NS_REQUIRES_SUPER;

/**
 启动监控
 通过重写该方法 实现自定义的消息统计
 */
- (void)runMonitor;

@end
