//
//  G100MsgDomain.h
//  G100
//
//  Created by William on 16/3/9.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"
#import <LKDBHelper/LKDBHelper.h>

@interface G100MsgStatusDomain : G100BaseDomain

@property (nonatomic, copy) NSString *msgid;
@property (nonatomic, assign) NSInteger userid;
@property (nonatomic, assign) BOOL isread;
@property (nonatomic, assign) BOOL isdelete;

@end

@interface G100MsgDomain : G100BaseDomain

/** 推送用户id, 为0时不判断用户id */
@property (nonatomic, assign) NSInteger userid;
/** 2.0 车辆id*/
@property (nonatomic, copy) NSString * bikeid;
/** 设备id */
@property (nonatomic, copy) NSString * devid;
/** 2.0 设备id */
@property (nonatomic, copy) NSString * deviceid;
/** 附加值(不同代码格式不同，见下方表格说明) */
@property (nonatomic, copy) NSString * addval;
/** 定制标题 */
@property (nonatomic, copy) NSString * custtitle;
/** 定制内容 */
@property (nonatomic, copy) NSString * custdesc;
/** 动作 0无定义 1跳转指定app页面 2打开webview */
@property (nonatomic, assign) NSInteger action;
/** 页面 url地址或app页面名称, url里的参数含有参数 fullscreen=1 时表示需要将webview全屏显示 */
@property (nonatomic, copy) NSString * page;
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

/** 是否为已读消息 */
@property (nonatomic, assign) BOOL hasRead;
/** 是否被选中 */
@property (nonatomic, assign) BOOL hasPicked;

@end
