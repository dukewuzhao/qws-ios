//
//  G100DevLostListDomain.h
//  G100
//
//  Created by William on 16/4/11.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

@interface G100DevLostDomain : G100BaseDomain

/** 丢车记录id */
@property (nonatomic, assign) NSInteger lostid;
/** 状态（待定） 1丢车中 2已找回 3已过期 4已理赔 */
@property (nonatomic, assign) NSInteger status;
/** 丢车时经度 */
@property (nonatomic, assign) CGFloat lostlongi;
/** 丢车时纬度 */
@property (nonatomic, assign) CGFloat lostlati;
/** 丢车时间 */
@property (nonatomic, copy) NSString * losttime;
/** 联系人 */
@property (nonatomic, copy) NSString * contact;
/** 联系人电话 */
@property (nonatomic, copy) NSString * phonenum;
/** 丢失分钟数 */
@property (nonatomic, assign) NSInteger lostminute;
/** 丢车滚动文字描述 */
@property (nonatomic, copy) NSString * lostdesc;
/** 找车位置文字描述 */
@property (nonatomic, copy) NSString * lostlocdesc;
/** 分享id，数组，长度3，顺序分别为：寻车分享/找到分享/理赔分享*/
@property (nonatomic, strong) NSArray * shareids;
/** 分享链接 */
@property (nonatomic, copy) NSString * shareurl;
/** 车辆找回时间*/
@property (nonatomic, copy) NSString * foundtime;
/** 车辆找回经度*/
@property (nonatomic, assign) CGFloat foundlongi;
/** 车辆找回纬度*/
@property (nonatomic, assign) CGFloat foundlati;
/** 找车位置文字描述*/
@property (nonatomic, copy) NSString * foundlocdesc;
/** 找车分钟数，第一次发布丢车的时间到现在*/
@property (nonatomic, assign) NSInteger reportminute;
/** 丢车上报时间 2016-04-01 13:00:00*/
@property (nonatomic, copy) NSString * reporttime;

- (NSInteger)shareid;

@end

@interface G100DevLostListDomain : G100BaseDomain

@property (nonatomic, copy) NSArray * lost; /* G100DevLostDomain 丢车记录 */

@end
