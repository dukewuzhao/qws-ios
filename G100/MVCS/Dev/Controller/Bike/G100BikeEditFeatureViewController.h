//
//  G100DevFeatureInfoViewController.h
//  G100
//
//  Created by yuhanle on 16/3/24.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseVC.h"
#import "G100BikeUpdateInfoDomain.h"

typedef void(^AddBikeFeatureBlock)(G100BikeUpdateInfoDomain *bikeInfo);

typedef enum : NSUInteger {
    BikeEditFeatureEntranceFromBikeInfo = 0,
    BikeEditFeatureEntranceFromLostBike,
    BikeEditFeatureEntranceFromAddBike //!< 添加车辆模式下 bikeid是nil
} BikeEditFeatureEntrance;

@interface G100BikeEditFeatureViewController : G100BaseVC

@property (nonatomic, copy) NSString * userid; //!< 用户 userid
@property (nonatomic, copy) NSString * bikeid; //!< 车辆 id
@property (nonatomic, copy) NSString * devid; //!< 设备 id

@property (nonatomic, strong) G100BikeUpdateInfoDomain *bikeInfo;

// 设置VC 的入口 如车辆详情页 或者 丢车信息页 添加车辆
@property (nonatomic, assign) BikeEditFeatureEntrance entranceFrom;

@property (nonatomic, copy) AddBikeFeatureBlock bikeFeatureBlock;

- (instancetype)initWithUserid:(NSString *)userid bikeid:(NSString *)bikeid entranceFrom:(BikeEditFeatureEntrance)entranceFrom;

@end
