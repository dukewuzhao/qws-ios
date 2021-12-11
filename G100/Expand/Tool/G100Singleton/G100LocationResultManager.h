//
//  G100LocationResultManager.h
//  G100
//
//  Created by 温世波 on 15/12/16.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import "G100LocationResultModel.h"
#import "G100DiscoveryLocationModel.h"
#import "G100ServiceCityDataDomain.h"

@interface G100LocationResultManager : NSObject

@property (nonatomic, strong) G100LocationInfoModel * locationInfo; //!< 详细定位信息
@property (nonatomic, strong) G100LocationResultModel * locationResult; //!< 上传给服务器的数据

@property (nonatomic, strong) G100DiscoveryLocationModel * discoveryLocatedCity; //定位城市模型
@property (nonatomic, strong) G100DiscoveryLocationModel * discoverySelectedCity; //选择城市模型

+ (instancetype)sharedInstance;

- (void)saveUserLocationWithLocation:(CLLocation *)location result:(AMapLocationReGeocode *)result;

/* 保存定位城市 */
- (void)saveDiscoveryLocatedCityModelWithResult:(AMapLocationReGeocode *)result;
/* 保存选中城市 */
- (void)saveDiscoverySelectedCityModelWithResult:(G100ServiceCityDomain *)result;

@end
