//
//  G100ShopApi.h
//  G100
//
//  Created by 温世波 on 15/12/24.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import "G100Api.h"

typedef enum : NSUInteger {
    G100ShopTypeSale = 1, // 销售点
    G100ShopTypeRepair, // 维修站
    G100ShopTypeCharge, // 充电站
} G100ShopType;

typedef enum : NSUInteger {
    G100ShopSortbyModeDistance = 1, // 距离
    G100ShopSortbyModeScore, // 评分
    G100ShopSortbyModePrice, // 价格
} G100ShopSortbyMode;

typedef enum : NSUInteger {
    G100ShopSorttypeDirectionAscend = 1, // 升序
    G100ShopSorttypeDirectionDescend, // 降序
} G100ShopSorttypeDirection;

typedef enum : NSUInteger {
    G100ShopSearchModeDistance = 1,
    G100ShopSearchModeArea,
    G100ShopSearchModeKeyword,
    G100ShopSearchModeAutomatic = 9
} G100ShopSearchMode;

@interface G100ShopApi : NSObject

+ (instancetype) sharedInstance;

/**
 *  获取周边的店铺 (废弃)
 *
 *  @param location 定位信息 [0] 经度 [1]纬度
 *  @param type     店铺类型
 *  @param sortby   排序方式
 *  @param sorttype 排序方向
 *  @param radius   搜索半径
 *  @param page     分页页码
 *  @param size     每页个数
 *  @param callback 接口回调
 */
- (ApiRequest *)getPlaceNearbyShopWithLocation:(NSArray *)location
                                  type:(G100ShopType)type
                                sortBy:(G100ShopSortbyMode)sortby
                              sorttype:(G100ShopSorttypeDirection)sorttype
                                radius:(NSInteger)radius
                                  page:(NSInteger)page
                                  size:(NSInteger)size
                              callback:(API_CALLBACK)callback G100Deprecated("1.2.3");

/**
 *  获取服务城市列表
 *
 *  @param listts   列表时间戳
 *  @param callback 接口回调
 */
- (ApiRequest *)getServiceCityWithListts:(NSString *)listts callback:(API_CALLBACK)callback;

/**
 *  获取城市下区域列表
 *
 *  @param adcode   城市代码
 *  @param callback 接口回调
 */
- (ApiRequest *)getCityDistrictWithAdcode:(NSString *)adcode callback:(API_CALLBACK)callback;

/**
 *  根据条件搜索店铺
 *
 *  @param searchtype  搜索方式 1距离 2区域 3关键字 9智能搜索
 *  @param searchws    搜索关键字
 *  @param location    当前位置 [0]经度 [1]纬度
 *  @param adcode      区域编码
 *  @param type        店铺类型 1维修站 2销售点 3充电站 4停车场 (1,2,3)
 *  @param sortby      排序方式 1距离 2评分 3价格
 *  @param sorttype    排序方向 1升序 2降序
 *  @param radius      搜索半径 米
 *  @param page        分页页码
 *  @param size        每页个数
 *  @param callback    接口回调
 */
- (ApiRequest *)searchPlaceWithSearchtype:(G100ShopSearchMode)searchtype
                         searchwd:(NSString *)searchwd
                         location:(NSArray *)location
                           adcode:(NSString *)adcode
                             type:(NSArray *)type
                           sortby:(G100ShopSortbyMode)sortby
                         sorttype:(G100ShopSorttypeDirection)sorttype
                           radius:(NSInteger)radius
                             page:(NSInteger)page
                             size:(NSInteger)size
                         callback:(API_CALLBACK)callback;

@end
