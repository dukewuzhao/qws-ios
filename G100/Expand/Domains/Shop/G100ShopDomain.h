//
//  G100ShopDomain.h
//  G100
//
//  Created by 温世波 on 15/12/24.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"

@interface G100ShopDomain : G100BaseDomain

@property (nonatomic, assign) NSInteger placeid; //!< id
@property (nonatomic, assign) double longi; //!< 经度
@property (nonatomic, assign) double lati; //!< 纬度
@property (nonatomic, assign) double distance; //!< 距离 米
@property (nonatomic, copy) NSString *name; //!< 名称
@property (nonatomic, copy) NSString *phone_num; //!< 电话
@property (nonatomic, copy) NSString *area; //!< 区域
@property (nonatomic, copy) NSString *address; //!< 地址
@property (nonatomic, strong) NSArray *picture; //!< 图片列表
@property (nonatomic, assign) double score; //!< 评分
@property (nonatomic, assign) double avgcost; //!< 平均消费额

@end

@interface G100ShopCommentDomain : G100BaseDomain

@property (nonatomic, assign) NSInteger commentid; //!< 评论id
@property (nonatomic, copy) NSString *nickname; //!< 昵称
@property (nonatomic, copy) NSString *usericon; //!< 用户头像地址
@property (nonatomic, copy) NSString *comment; //!< 评论内容
@property (nonatomic, strong) NSArray *picture; //!< 图片列表
@property (nonatomic, assign) double score; //!< 评分
@property (nonatomic, assign) double avgcost; //!< 平均消费额
@property (nonatomic, copy) NSString *ts; //!< 评论时间

@end

@interface G100ShopPlaceDomain : G100BaseDomain

@property (nonatomic, assign) NSInteger placeid; //!< id
@property (nonatomic, assign) double longi; //!< 经度
@property (nonatomic, assign) double lati; //!< 纬度
@property (nonatomic, assign) NSInteger distance; //!< 距离 米
@property (nonatomic, copy) NSString *name; //!< 名称
@property (nonatomic, copy) NSString *phone_num; //!< 电话
@property (nonatomic, copy) NSString *adcode; //!< 区域编码
@property (nonatomic, copy) NSString *area; //!< 所在镇区
@property (nonatomic, copy) NSString *address; //!< 地址
@property (nonatomic, strong) NSArray *picture; //!< 图片列表
@property (nonatomic, assign) double score; //!< 评分
@property (nonatomic, assign) double avgcost; //!< 平均消费额
@property (nonatomic, strong) NSString *type; //!< 店铺类型
@property (nonatomic, assign) NSInteger certified; //!< 认证标志 0未认证 1已认证

@end
