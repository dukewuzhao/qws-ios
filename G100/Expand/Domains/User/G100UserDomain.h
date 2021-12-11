//
//  G100UserDomain.h
//  G100
//
//  Created by Tilink on 15/5/8.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"
#import <AMapLocationKit/AMapLocationKit.h>

@class UserHomeInfo;
@interface G100UserDomain : G100BaseDomain

/** 注册时间 */
@property (copy, nonatomic) NSString * regtime;
/** 帐号名 */
@property (copy, nonatomic) NSString * account;
/** 生日 */
@property (copy, nonatomic) NSString * birthday;
/** 性别 1男 2女 */
@property (copy, nonatomic) NSString * gender;
/** 头像 */
@property (copy, nonatomic) NSString * icon;
/** 身份证号 */
@property (copy, nonatomic) NSString * idcardno;
/** 地理位置 */
@property (copy, nonatomic) NSString * location;
/** 昵称 */
@property (copy, nonatomic) NSString * nickname;
/** 电话号码 */
@property (copy, nonatomic) NSString * phonenum;
/** 真实姓名 */
@property (copy, nonatomic) NSString * realname;
/** 帐号id */
@property (copy, nonatomic) NSString * userid;
/** 是否机主 */
@property (assign, nonatomic) NSInteger isMaster;
/** 个人资料完整度 */
@property (assign, nonatomic) NSInteger integrity;
/** 用户id 弃用整型 使用字符型 @see userid*/
@property (nonatomic, assign) NSInteger user_id;
/** 电话号码*/
@property (nonatomic, copy) NSString *phone_num;
/** 昵称*/
@property (nonatomic, copy) NSString *nick_name;
/** 真实姓名*/
@property (nonatomic, copy) NSString *real_name;
/** 身份证号码*/
@property (nonatomic, copy) NSString *id_card_no;
/** 注册时间*/
@property (nonatomic, copy) NSString *reg_time;
/** 是否主用户*/
@property (nonatomic, copy) NSString *is_master;
/** 绑定车辆时间*/
@property (nonatomic, copy) NSString *created_time;
/** 车辆数量*/
@property (nonatomic, assign) NSInteger bike_count;
/** 设备数量*/
@property (nonatomic, assign) NSInteger device_count;
/** 服务数量*/
@property (nonatomic, assign) NSInteger service_count;
/** 副用户备注*/
@property (copy, nonatomic) NSString *comment;
/** 家的地址*/
@property (strong, nonatomic) UserHomeInfo *homeinfo;
/** 用户状态 1 正常 2 待审核*/
@property (assign, nonatomic) NSInteger user_status;

/**
 *  判断该用户是否开启了报警提醒
 *
 *  @return YES/NO
 */
- (BOOL)isOpenWxAlarmPush;

/**
 判断该用户是否开通电话报警

 @return YES/NO
 */
- (BOOL)isOpenPhoneAlarm;

@end

@interface UserHomeInfo : G100BaseDomain

/** 家的经度*/
@property (assign, nonatomic) CLLocationDegrees homelon;
/** 家的纬度*/
@property (assign, nonatomic) CLLocationDegrees homelat;
/** 家的详细地址*/
@property (copy, nonatomic) NSString *homeaddr;
/** 家的地址开关 默认开启 1 开启 2 关闭*/
@property (assign, nonatomic) NSInteger home_addr_switch;

@end
