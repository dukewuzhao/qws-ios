//
//  G100GoodsApi.h
//  G100
//
//  Created by Tilink on 15/5/8.
//  Copyright (c) 2015年 Tilink. All rights reserved.
//

#import "G100Api.h"

@interface G100GoodsApi : NSObject

+(instancetype) sharedInstance;

/**
 *  获取商品列表(保险)
 *
 *  @param  type        商品类型    1 服务    2 保险
 *  @param  callback    接口回调
 */
-(ApiRequest *)loadProductListWithType:(NSString *)type callback:(API_CALLBACK)callback;

/**
 *  获取商品列表 (服务)
 *
 *  @param  type      商品类型    1 服务    2 保险
 *  @param  devid     设备ID    判断摩托车和电动车
 *  @param  callback  接口回调
 */
-(ApiRequest *)loadProductListWithType:(NSString *)type devid:(NSInteger)devid callback:(API_CALLBACK)callback;

/**
 *  获取商品列表 (指定商品)
 *
 *  @param  type      商品类型    1 服务    2 保险
 *  @param  productid 指定商品id
 *  @param  devid     设备ID    判断摩托车和电动车
 *  @param  callback  接口回调
 */
-(ApiRequest *)loadProductListWithType:(NSString *)type productid:(NSInteger)productid devid:(NSInteger)devid callback:(API_CALLBACK)callback;

@end
