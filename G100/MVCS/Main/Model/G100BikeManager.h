//
//  G100BikeManager.h
//  G100
//
//  Created by sunjingjing on 16/7/22.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface G100BikeModel : NSObject

@property (nonatomic, assign) NSInteger soc;            //!< 电量
@property (nonatomic, assign) CGFloat   expecteddistance;   //!< 续航里程
@property (assign, nonatomic) BOOL      eleDoorState;   //!< 电门开关状态

@property (nonatomic, copy) NSString    *name;          //!< 车辆名称
@property (nonatomic, copy) NSString    *is_master;     //!< 是否车主
@property (nonatomic, assign) NSInteger user_count;     //!< 绑定用户数
@property (copy, nonatomic) NSString    *pic_small;     //!< 车辆图片
@property (nonatomic, assign) NSInteger bike_type;      //!< 车辆类型 0 电动车  1 摩托车
@property (copy, nonatomic) NSString    *car_scanBar;   //!< 车辆二维码
@property (copy, nonatomic) NSString    *car_logo;      //!< 车辆品牌logo
@property (assign, nonatomic) BOOL      isSmartDevice;  //!< 是否是智能电池
@property (assign, nonatomic) BOOL      hasDevice;      //!< 是否有设备
@property (nonatomic, assign) BOOL      isChinaMobileCustom;   //!< 是否是移动定制版
@property (assign, nonatomic) NSInteger setSafeMode;    //!< 主设备设防模式
@end

typedef void(^G100BikeModelCallback)(G100BikeModel *bikeModel);

@interface G100BikeManager : NSObject

- (void)getBikeModelWithData:(G100BikeDomain *)bike compete:(G100BikeModelCallback)callback;

@end
