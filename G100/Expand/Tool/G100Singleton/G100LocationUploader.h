//
//  G100LocationUploader.h
//  G100
//
//  Created by yuhanle on 2018/7/10.
//  Copyright © 2018年 Tilink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMapLocationKit/AMapLocationKit.h>

@interface G100LocationUploader : NSObject

+ (instancetype)uploader;

/**
 更新用户位置信息
 */
- (void)lmu_updateLocation;

/**
 更新用户位置信息

 @param completionBlock 回调
 */
- (void)lmu_updateLocation:(void (^)(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error))completionBlock;

@end
