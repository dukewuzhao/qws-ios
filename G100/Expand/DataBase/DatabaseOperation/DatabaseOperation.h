//
//  DatabaseOperation.h
//  G100
//
//  Created by yuhanle on 16/3/9.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class G100MsgDomain;
extern NSString *const DBFileName;
@interface DatabaseOperation : NSObject

@property (nonatomic, copy, readonly) NSString *dbPath;

/**
 *  返回一个数据库实例
 *
 *  @return database
 */
+ (DatabaseOperation *)operation;

/**
 *  创建测试数据
 */
- (void)setupTestData;

/**
 *  快速创建信息表
 */
+ (void)createTable;

/**
 *  插入一条消息
 *
 *  @param msg   消息
 *  @param block 接口回调
 */
- (void)insertDatabaseWithMsg:(G100MsgDomain *)msg success:(void(^)(BOOL success))block;

/**
 *  更新一条消息
 *
 *  @param msg   消息
 *  @param block 接口回调
 */
- (void)updateDatabaseWithMsg:(G100MsgDomain *)msg success:(void(^)(BOOL success))block;

/**
 *  设置宜都某条消息
 *
 *  @param msg   某条消息
 *  @param block 接口回调
 */
- (void)hasReadMsgWithMsg:(G100MsgDomain *)msg success:(void(^)(BOOL success))block;

/**
 *  获取数据库中全部消息
 *
 *  @param userid 用户id
 *  @param block  接口回调
 */
- (void)fetchAllDataWithUserid:(NSInteger)userid completion:(void(^)(NSMutableArray *personalMsgArr, NSMutableArray * systemMsgArr))block;

/**
 *  删除数组中的消息
 *
 *  @param userid   用户id
 *  @param msgArray 即将删除的消息数组
 *  @param block    接口回调
 */
- (void)deleteDatabaseWithUserid:(NSInteger)userid msgArray:(NSArray *)msgArray success:(void(^)(BOOL success))block;

/**
 *  查询未读消息个数
 *
 *  @param userid 用户id
 *  @param block  接口回调
 */
- (void)countUnreadNumberWithUserid:(NSInteger)userid success:(void(^)(NSInteger personalUnreadNum, NSInteger systemUnreadNum))block;

@end
