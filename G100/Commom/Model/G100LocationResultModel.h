//
//  G100LocationResultModel.h
//  G100
//
//  Created by 温世波 on 15/12/16.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

@interface G100LocationResultModel : G100BaseDomain

@property (nonatomic, strong) NSArray * coordinate; //!< 经纬度，第一个为经度 第二个为纬度
@property (nonatomic, assign) double altitude; //!< 高度
@property (nonatomic, assign) double accuracy; //!< 精度
@property (nonatomic, assign) NSInteger course; //!< 方向 0~359
@property (nonatomic, assign) double speed; //!< 速度 m/s
@property (nonatomic, assign) NSInteger ts; //!< 定位时间, utc整数
@property (nonatomic, copy) NSString * citycode; //!< 城市编码
@property (nonatomic, copy) NSString * adcode; //!< 区域编码
@property (nonatomic, copy) NSString * road; //!< 道路
@property (nonatomic, copy) NSString * town; //!< 镇
@property (nonatomic, copy) NSString * address; //!< 格式化地址

@end

@interface G100LocationInfoModel : G100LocationResultModel

@property (nonatomic, copy) NSString *province; //!< 省/直辖市
@property (nonatomic, copy) NSString *city;     //!< 市
@property (nonatomic, copy) NSString *district; //!< 区
@property (nonatomic, copy) NSString *neighborhood; //!< 社区
@property (nonatomic, copy) NSString *number;   //!< 门牌号

@end
