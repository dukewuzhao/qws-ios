//
//  MAGeoCodeResult.h
//  G100
//
//  Created by 温世波 on 15/11/25.
//  Copyright © 2015年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMapSearchKit/AMapCommonObj.h>

@class AMapReGeocodeSearchResponse;
@interface MAGeoCodeResult : NSObject

@property (nonatomic, strong) AMapReGeocodeSearchResponse *result;

+ (instancetype)instance;

@end
