//
//  G100AccountDomain.h
//  G100
//
//  Created by Tilink on 15/5/11.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

@class G100UserDomain;
@class G100BikeDomain;

@interface FuncSample : G100BaseDomain

/** 功能名称 */
@property (strong, nonatomic) NSString * func;
/** 是否开启 */
@property (assign, nonatomic) BOOL enable;

@end

@interface UserAppFunction : G100BaseDomain

/** 安全评分 */
@property (strong, nonatomic) FuncSample * securityscore;
/** 安防设置 */
@property (strong, nonatomic) FuncSample * securitysetting;
/** 实时追踪 */
@property (strong, nonatomic) FuncSample * biketrace;
/** 车辆切换 */
@property (strong, nonatomic) FuncSample * switchbike;
/** 服务状态 */
@property (strong, nonatomic) FuncSample * servicestatus;
/** 服务状态-购买服务 */
@property (strong, nonatomic) FuncSample * servicestatus_buy;
/** 服务状态-电话客服 */
@property (strong, nonatomic) FuncSample * servicestatus_call;
/** 用车报告 */
@property (strong, nonatomic) FuncSample * bikeusagereport;
/** 退出登录 */
@property (strong, nonatomic) FuncSample * logout;
/** 个人资料 */
@property (strong, nonatomic) FuncSample * profile;
/** 个人资料-头像 */
@property (strong, nonatomic) FuncSample * profile_icon;
/** 个人资料-昵称 */
@property (strong, nonatomic) FuncSample * profile_nickname;
/** 个人资料-性别 */
@property (strong, nonatomic) FuncSample * profile_gender;
/** 个人资料-生日 */
@property (strong, nonatomic) FuncSample * profile_birthday;
/** 个人资料-常住地 */
@property (strong, nonatomic) FuncSample * profile_location;
/** 个人资料-第三方帐号 */
@property (strong, nonatomic) FuncSample * profile_otheraccount;
/** 个人资料-修改密码 */
@property (strong, nonatomic) FuncSample * profile_modifypassword;
/** 个人资料-修改手机号 */
@property (strong, nonatomic) FuncSample * profile_modifyphonenum;
/** 我的保险 */
@property (strong, nonatomic) FuncSample * insurance;
/** 我的保险-购买 */
@property (strong, nonatomic) FuncSample * insurance_buy;
/** 我的保险-投保 */
@property (strong, nonatomic) FuncSample * insurance_apply;
/** 我的保险-支付 */
@property (strong, nonatomic) FuncSample * insurance_pay;
/** 我的订单 */
@property (strong, nonatomic) FuncSample * myorders;
/** 我的车辆 */
@property (strong, nonatomic) FuncSample * mybikes;
/** 我的车辆-添加新车辆 */
@property (strong, nonatomic) FuncSample * mybikes_add;
/** 我的车辆-车辆详情 */
@property (strong, nonatomic) FuncSample * mybikes_bikedetail;
/** 我的车辆-车辆详情-重命名 */
@property (strong, nonatomic) FuncSample * mybikes_bikedetail_rename;
/** 我的车辆-车辆详情-重新绑定 */
@property (strong, nonatomic) FuncSample * mybikes_bikedetail_rebind;
/** 我的车辆-车辆详情-与该车辆解绑 */
@property (strong, nonatomic) FuncSample * mybikes_bikedetail_unbind;
/** 我的车辆-车辆详情-二维码 */
@property (strong, nonatomic) FuncSample * mybikes_bikedetail_qr;
/** 离线地图 */
@property (strong, nonatomic) FuncSample * offlinemap;
/** 关于 */
@property (strong, nonatomic) FuncSample * about;
/** 用户反馈 */
@property (strong, nonatomic) FuncSample * userfeedback;

@end

@interface UserAppWaterMarking : G100BaseDomain

/** app水印 0 无水印     1 样机水印*/
@property (assign, nonatomic) NSInteger type;

@end

@interface G100AccountDomain : G100BaseDomain

/** 帐号 */
@property (copy, nonatomic) NSString * account;
/** 生日 */
@property (copy, nonatomic) NSString * birthday;
/** 设备列表 */
@property (retain, nonatomic) NSArray * devList;
/** 性别 1 男 2 女*/
@property (assign, nonatomic) NSInteger gender;
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
/** 安防设置 */
@property (copy, nonatomic) NSArray * secset;
/** 注册时间 */
@property (copy, nonatomic) NSString * regtime;
/** 请求token */
@property (copy, nonatomic) NSString * token;
/** 用户id */
@property (assign, nonatomic) NSInteger userid;
/** 用于A/Btest */
@property (copy, nonatomic) NSString * solution;
/** app功能控制 */
@property (strong, nonatomic) NSArray * appfunc;
/** app水印 0 无水印 1 样机水印 */
@property (strong, nonatomic) NSDictionary * appwm;

/***************************************************  V2.0   ************************************************************/

@property (nonatomic, strong) G100UserDomain *user_info; //!< 用户资料信息
@property (nonatomic, strong) NSArray <G100BikeDomain *>*bikes; //!< 车辆信息
@property (nonatomic, copy) NSString *push_block; //!< 手机可能阻止推送 空表示无阻止 非空为跳转帮助页面链接
@property (nonatomic, copy) NSString *picvc_url; //!< 图形验证码 当state为91时 有值 其他情况为空

/** 用户功能可点击列表 */
@property (strong, nonatomic) UserAppFunction *appfunction;
/** 用户根据状态是否显示水印 */
@property (strong, nonatomic) UserAppWaterMarking *appwatermarking;
/** 令牌有效时间*/
@property (assign, nonatomic) NSInteger expires_in;

@end
