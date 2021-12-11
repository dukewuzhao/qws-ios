//
//  G100DevPositionDomain.h
//  G100
//
//  Created by Tilink on 15/5/18.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

@interface G100DevPositionDomain : G100BaseDomain

/** 位置描述 */
@property (copy, nonatomic) NSString * desc;
/** 位置方向 */
@property (assign, nonatomic) CGFloat heading;
/** 位置纬度 */
@property (assign, nonatomic) CGFloat lati;
/** 位置经度 */
@property (assign, nonatomic) CGFloat longi;
/** 车辆速度 */
@property (assign, nonatomic) CGFloat speed;
/** 位置时间 */
@property (copy, nonatomic) NSString * ts;
/** 电动车id */
@property (copy, nonatomic) NSString * devid;
/** 错误代码 193gps通信故障 194对码故障 */
@property (copy, nonatomic) NSString * faultcode;
/** 对码状态 0未锁定 1加锁中 2加锁成功 3解锁中 -1获取出错 */
@property (assign, nonatomic) NSInteger controllerstatus;
/** gps 卫星个数 */
@property (assign, nonatomic) NSInteger gpssvs;
/** gsm 基站信号强度 */
@property (assign, nonatomic) NSInteger bssignal;
/** 报警器状态   1 设防已上传 2 设防已响应 3 撤防已上传 4 撤防已响应*/
@property (assign, nonatomic) NSInteger alertstatus;
/** 定位器与服务端的连接模式 0 http模式方式 1 udp长连接模式方式 */
@property (assign, nonatomic) NSInteger locatorconnmode;
/** 盗抢险状态 0无 1有效期保障中 2投保审核中 3破案期 4丢车审核期 5已赔付 */
@property (copy, nonatomic) NSString * theftinsurance;
/** 破案期开始时间 */
@property (copy, nonatomic) NSString * detectionbegindate;

@end
