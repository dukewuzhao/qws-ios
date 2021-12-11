//
//  G100DevFeatureInfoViewController.h
//  G100
//
//  Created by yuhanle on 16/3/24.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseVC.h"

typedef void(^AddBikeFeatureBlock)(NSArray *images, NSDictionary *feature);

typedef enum : NSUInteger {
    BikeFeatureInfoEntranceFromBikeInfo = 0,
    BikeFeatureInfoEntranceFromLostBike,
    BikeFeatureInfoEntranceFromAddBike //!< 添加车辆模式下 bikeid是nil
} BikeFeatureInfoEntrance;

@interface G100BikeFeatureInfoViewController : G100BaseVC

@property (nonatomic, copy) NSString * userid; //!< 用户 userid
@property (nonatomic, copy) NSString * bikeid; //!< 车辆 id
@property (nonatomic, copy) NSString * devid; //!< 设备 id

@property (nonatomic, strong) NSDictionary *featureDict;

// 设置VC 的入口 如车辆详情页 或者 丢车信息页 添加车辆
@property (nonatomic, assign) BikeFeatureInfoEntrance entranceFrom;

@property (nonatomic, copy) AddBikeFeatureBlock bikeFeatureBlock;

- (instancetype)initWithUserid:(NSString *)userid bikeid:(NSString *)bikeid entranceFrom:(BikeFeatureInfoEntrance)entranceFrom;

@end
