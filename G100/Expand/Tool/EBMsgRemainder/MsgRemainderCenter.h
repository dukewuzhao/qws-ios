//
//  MsgRemainderCenter.h
//  Msg_remainder
//
//  Created by yuhanle on 2017/4/5.
//  Copyright © 2017年 tilink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MsgRemainderInfo.h"

typedef void(^MsgRemainderCenterSearchComplete)(BOOL success, NSArray <MsgRemainderInfo *> *msglist);

extern NSString * const kMsgRemainderCenterMsgHandleFinished;

@interface MsgRemainderCenter : NSObject

/**
 消息提醒单例

 @return 消息提醒控制中心
 */
+ (instancetype)defaultCenter;

@property (nonatomic, copy) NSString *lastupdatetime;

@property (nonatomic, copy) NSString *userid;

/**
 搜索相关消息

 @param monitorid 消息id
 @param data 其他条件
 @param complete 完成回调
 */
- (void)searchMsgDataWithMonitorid:(NSString *)monitorid data:(NSDictionary *)data complete:(MsgRemainderCenterSearchComplete)complete;

/**
 添加新的消息

 @param monitorid 消息id
 @param msginfo 消息结构
 */
- (void)newMsgDataWithMonitor:(NSString *)monitorid msginfo:(MsgRemainderInfo *)msginfo;

/**
 读取某条消息 即操作

 @param monitorid 消息id
 @param msginfo 消息结构
 */
- (void)readMsgDataWithMonitor:(NSString *)monitorid msginfo:(MsgRemainderInfo *)msginfo;

@end
