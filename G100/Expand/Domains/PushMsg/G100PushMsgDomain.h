//
//  G100PushMsgDomain.h
//  G100
//
//  Created by Tilink on 15/5/20.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"
#import "G100ApsMsgDomain.h"

@interface G100PushMsgDomain : G100BaseDomain

/** 极光推送msgid */
@property (assign, nonatomic) NSInteger _j_msgid;
/** 车辆震动等级 */
@property (copy, nonatomic) NSString * addval;
/** 推送主要信息 */
@property (strong, nonatomic) NSDictionary * aps;
/** 推送代码 */
@property (assign, nonatomic) NSInteger errCode;
/** 推送详情 */
@property (copy, nonatomic) NSString * errDesc;
/** 推送的用户id */
@property (assign, nonatomic) NSInteger userid;
/** 推送的标题 */
@property (copy, nonatomic) NSString * custtitle;
/** 推送的内容 */
@property (copy, nonatomic) NSString * custdesc;
/** 2.0 新增 车辆id */
@property (copy, nonatomic) NSString * bikeid;
/** 
 *  推送的设备id
 *  2.0 版本不再使用该字段
 */
@property (copy, nonatomic) NSString * devid;
/** 2.0 新增 设备id */
@property (copy, nonatomic) NSString * deviceid;
/** aps -> domain */
@property (strong, nonatomic) G100ApsMsgDomain * apsdomain;
/** action 动作 0无定义 1跳转指定app页面 2打开webview */
@property (assign, nonatomic) NSInteger action;
/** 页面 url地址或app页面名称 */
@property (copy, nonatomic) NSString * page;

/** 消息中心扩展结构*/
/** 消息id，唯一 */
@property (nonatomic, copy) NSString * msgid;
/** 消息类型 0默认类型 1个人消息 2系统消息 */
@property (nonatomic, assign) NSInteger msgtype;
/** 消息中心消息标题 */
@property (nonatomic, copy) NSString * mctitle;
/** 消息中心消息内容 */
@property (nonatomic, copy) NSString * mcdesc;
/** 点击消息跳转的url，scheme为http或qwsapp */
@property (nonatomic, copy) NSString * mcurl;
/** 消息时间, unix整型，单位s */
@property (nonatomic, assign) long mcts;

/** 额外信息 */
@property (copy, nonatomic) NSString * imageName;
@property (strong, nonatomic) UIColor * lColor;

@end
