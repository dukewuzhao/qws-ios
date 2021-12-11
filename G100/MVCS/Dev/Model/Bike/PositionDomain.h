//
//  DevPositionDomain.h
//  G100
//
//  Created by Tilink on 15/6/29.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

@interface PositionDomain : G100BaseDomain

/** 位置描述 */
@property (copy, nonatomic) NSString * desc;
/** 位置方向 */
@property (assign, nonatomic) CGFloat heading;
/** 位置纬度 */
@property (copy, nonatomic) NSString * lati;
/** 位置经度 */
@property (copy, nonatomic) NSString * longi;
/** 当前速度 */
@property (assign, nonatomic) CGFloat speed;
/** 位置时间 */
@property (copy, nonatomic) NSString * ts;
/** 错误码 */
@property (copy, nonatomic) NSString * faultcode;
/** 车辆id */
@property (copy, nonatomic) NSString * devid;
/** 对码状态 */
@property (assign, nonatomic) NSInteger controllerstatus;
/** 头标题 */
@property (copy, nonatomic) NSString * topTitle;
/** 副标题 */
@property (copy, nonatomic) NSString * bottomContent;
/** GPS */
@property (assign, nonatomic) NSInteger gpssvs;
/** GSM */
@property (assign, nonatomic) NSInteger bssignal;

@property (nonatomic, copy) NSString *name; //!< 气泡的设备名称
@property (nonatomic, copy) NSString *time; //!< 定位时间
@property (nonatomic, assign) NSInteger index; //!< 选择设备的索引序号 用于GPS页面
@property (nonatomic, assign) BOOL isMainDevice; //!< 是否是主设备
@property (nonatomic, assign) CLLocationCoordinate2D coordinate; // !< 适用于高的坐标系的坐标

@end
