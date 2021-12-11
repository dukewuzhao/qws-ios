//
//  MsgRemainderDataController.h
//  Msg_remainder
//
//  Created by yuhanle on 2017/4/5.
//  Copyright © 2017年 tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^MsgRemainderComplete)(BOOL success);
typedef void(^MsgRemainderFeatchFinishsed)(BOOL success, NSString *userid, NSArray *msglist, NSError *error);

@class MsgRemainderInfo;
@interface MsgRemainderDataController : NSObject

/**
 *  返回一个数据库实例
 *
 *  @return database
 */
+ (MsgRemainderDataController *)controller;

/**
 创建消息提醒表
 */
- (void)createTable;

/**
 更新一组消息提醒数据

 @param msglist 消息提醒数组
 @param complete 完成回调
 */
- (void)updateDataWithMessageList:(NSArray *)msglist complete:(MsgRemainderComplete)complete;

/**
 更新一条消息提醒数据

 @param msginfo 消息
 @param complete 完成回调
 */
- (void)updateDataItemWithMesssge:(MsgRemainderInfo *)msginfo complete:(MsgRemainderComplete)complete;

/**
 获取消息提醒

 @param userid 用户id
 @param featchFinished 获取消息回调
 */
- (void)featchAllDataItemsWithUserid:(NSString *)userid complete:(MsgRemainderFeatchFinishsed)featchFinished;

/**
 查询符合dict 条件的消息

 @param msgid 消息id
 @param dict 条件的字典
 @param featchFinished 消息结果
 */
- (void)searchDataItemWithMsgid:(NSString *)msgid dict:(NSDictionary *)dict complete:(MsgRemainderFeatchFinishsed)featchFinished;

/**
 同时查询多条消息记录

 @param msgids 消息id数组
 @param dict 其他条件
 @param featchFinished 查询结果
 */
- (void)searchDataItemWithMsgids:(NSArray *)msgids dict:(NSDictionary *)dict complete:(MsgRemainderFeatchFinishsed)featchFinished;

/**
 删除某条消息提醒

 @param msg 消息结果
 @param complete 完成回调
 */
- (void)deleteDataItemWithMessage:(MsgRemainderInfo *)msg complete:(MsgRemainderComplete)complete;

@end
