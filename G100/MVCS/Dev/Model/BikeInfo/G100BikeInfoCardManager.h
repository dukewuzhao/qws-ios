//
//  G100BikeInfoCardManager.h
//  G100
//
//  Created by yuhanle on 2017/6/1.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G100BikeInfoCardModel.h"

extern NSString * const BikeInfoCardViewId_bikeinfo;
extern NSString * const BikeInfoCardViewId_batteryinfo;
extern NSString * const BikeInfoCardViewId_deviceinfo;
extern NSString * const BikeInfoCardViewId_bikeuser;

@interface G100BikeInfoCardManager : NSObject

@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *bikeid;

/**
 *  卡片管理器 属于的车辆模型
 */
@property (nonatomic, strong) G100BikeDomain *bike;
/**
 *  卡片的个数 只读 通过设置bike 属性后才会有该值 否则为 0
 */
@property (nonatomic, assign, readonly) NSInteger numberOfRows;
/**
 *  卡片的数据源 只读 通过设置bike 属性
 */
@property (nonatomic, strong, readonly) NSArray *dataArray;

/**
 创建车辆详情卡片管理器

 @param userid 用户id
 @param bikeid 车辆id
 @return 返回管理器
 */
+ (instancetype)cardManagerWithUserid:(NSString *)userid bikeid:(NSString *)bikeid;
/**
 *  通过该方法 返回一个卡片
 *
 *  @param item       <G100BikeInfoCardModel *>item
 *
 *  @return 卡片控制器
 */
- (UIViewController *)cardViewWithItem:(G100BikeInfoCardModel *)item;
/**
 *  通过该方法 返回卡片的高度
 *
 *  @param item      <G100BikeInfoCardModel *>item
 *  @param width     卡片宽度
 *
 *  @return 卡片高度
 */
- (CGFloat)heightForCardViewWithItem:(G100BikeInfoCardModel *)item width:(CGFloat)width;

@end
