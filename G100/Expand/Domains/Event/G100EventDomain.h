//
//  G100EventDomain.h
//  G100
//
//  Created by William on 16/2/1.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

@class G100EventControl;
@interface G100EventDetailDomain : G100BaseDomain
/** 活动id 1骑行报告  2领取盗抢险*/
@property (nonatomic, assign) NSInteger eventid;
/** 开始时间 */
@property (nonatomic, strong) NSString * begintime;
/** 结束时间 */
@property (nonatomic, strong) NSString * endtime;
/** 动作 0无定义 1跳转指定app页面 2打开webview */
@property (nonatomic, assign) NSInteger action;
/** 页面 url地址或app页面名称, url里的参数含有参数 */
@property (nonatomic, strong) NSString * page;
/** 活动类型 1常规活动 2海报活动*/
@property (nonatomic, assign) NSInteger type;
/** 活动图标*/
@property (nonatomic, copy) NSString * icon;
/** 海报图片*/
@property (nonatomic, copy) NSString *poster;
/** 海报点击跳转链接*/
@property (nonatomic, copy) NSString *poster_url;
/** 本地事件类型 1填写电池信息*/
@property (nonatomic, assign) NSInteger localtype;
/** 用户id*/
@property (nonatomic, copy) NSString *userid;
/** 车辆id*/
@property (nonatomic, copy) NSString *bikeid;
/**
 活动控制
 */
@property (nonatomic, strong) G100EventControl *control;

/**
 *  判断当前时间是否在有效期内
 *
 *  @return 是否有效
 */
- (BOOL)isInValidEvent;

@end

@interface G100EventDomain : G100BaseDomain
/** 活动数组 */
@property (nonatomic, strong) NSArray * events/* G100EventDetailDomain */;

/**
 返回第一个海报活动
 
 @return 活动详情
 */
- (G100EventDetailDomain *)firstPosterEventDetail;

@end

@interface G100EventControl : G100BaseDomain

@property (nonatomic, assign) BOOL poster;
@property (nonatomic, assign) BOOL icon;

@end
