//
//  G100DevDataHelper.h
//  G100
//
//  Created by William on 16/8/17.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kDevDataReceivedNotification;
@interface G100DevDataHelper : NSObject

@property (assign, nonatomic) BOOL isCustomInterval;

+ (instancetype)shareInstance;

/**
 添加关注信息

 @param userid 用户id
 @param bikeid 车辆id
 */
- (void)addConcernWithUserid:(NSString *)userid bikeid:(NSString *)bikeid;
/**
 移除关注 -> 弃用 自动判断是否需要定时刷新

 @param userid 用户id
 @param bikeid 车辆id
 */
- (void)removeConcernWithUserid:(NSString *)userid bikeid:(NSString *)bikeid;
/**
 立即获取数据

 @param userid 用户id
 @param bikeid 车辆id
 @param callback 接口回调
 */
- (void)concernNowWithUserid:(NSString *)userid bikeid:(NSString *)bikeid callback:(API_CALLBACK)callback;
/**
 立即刷新所有车辆数据
 */
- (void)updateAllBikeRuntimeData;

@end
