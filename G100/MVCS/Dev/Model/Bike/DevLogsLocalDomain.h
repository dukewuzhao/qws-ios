//
//  DevLogsLocalDomain.h
//  G100
//
//  Created by Tilink on 15/6/24.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

@interface DevLogsLocalDomain : G100BaseDomain

/** 记录详情 */
@property (copy, nonatomic) NSString * msg;
/** 记录标题 */
@property (copy, nonatomic) NSString * title;
/** 记录类型 */
@property (assign, nonatomic) NSInteger type;
/** 记录时间 */
@property (copy, nonatomic) NSString * ts;
/** 记录道路 */
@property (copy, nonatomic) NSString * road;
/** 记录区域 */
@property (copy, nonatomic) NSString * area;
/** 记录距离 */
@property (copy, nonatomic) NSString * distance;
/** 位移时间 秒 */
@property (copy, nonatomic) NSString * time;
/** 位移平均速度 km/h */
@property (copy, nonatomic) NSString * speed;
/** 位移开始时间 */
@property (copy, nonatomic) NSString * begintime;
/** 位移结束时间 */
@property (copy, nonatomic) NSString * endtime;
/** 记录状态 */
@property (assign, nonatomic) NSInteger status;
/** 是否有严重振动 */
@property (assign, nonatomic) BOOL hasYanzhong;

@property (assign, nonatomic) CGFloat cellHeight;

/** 最高时速 */
@property (nonatomic, assign) NSInteger maxspeed;
/** 提示字体颜色 0-不显示 1-黑色 2-红色 */
@property (nonatomic, assign) NSInteger remindtype;
/** 超速后提示文字 */
@property (nonatomic, copy) NSString *remindcontent;
/** 超速提醒开启状态 */
@property (nonatomic, assign) BOOL overSpeedOpen;
/** 超速提醒开启状态 */
@property (nonatomic, assign) BOOL topSpeedOpen;
@end
