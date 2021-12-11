//
//  G100BikeUpdateInfoDomain.h
//  G100
//
//  Created by sunjingjing on 16/9/28.
//  Copyright © 2016年 Tilink. All rights reserved.
//

#import "G100BaseDomain.h"
@class G100BikeFeatureDomain;
@class G100BrandInfoDomain;
@class G100BikeBatteryInfoDomain;

@interface G100BikeUpdateInfoDomain : G100BaseDomain

@property (nonatomic, assign) NSInteger bike_id; //!< 车辆id
@property (nonatomic, copy) NSString *name; //!< 车辆名称
@property (nonatomic, assign) NSInteger bike_type; //!< 车辆类型
@property (nonatomic, strong) G100BrandInfoDomain *brand; //!< 车辆品牌
@property (nonatomic, strong) G100BikeFeatureDomain *feature; //!< 车辆特征信息

@end
