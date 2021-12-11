//
//  G100LocationUploader.m
//  G100
//
//  Created by yuhanle on 2018/7/10.
//  Copyright © 2018年 Tilink. All rights reserved.
//

#import "G100LocationUploader.h"
#import "G100LocationResultManager.h"
#import "G100StartPageManager.h"
#import "G100UserApi.h"

@interface G100LocationUploader ()

@property (nonatomic, strong) AMapLocationManager *lmManager;

@end

static G100LocationUploader *_instance = nil;
@implementation G100LocationUploader

#pragma mark - Public Method
- (void)lmu_updateLocation {
    [self lmu_updateLocation:nil];
}

- (void)lmu_updateLocation:(void (^)(CLLocation *, AMapLocationReGeocode *, NSError *))completionBlock {
    AMapLocatingCompletionBlock proxx = ^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error){
        if (error) {
            NSLog(@"定位失败: %ld - %@", (long)error.code, error.localizedDescription);
        }
        
        if (location && regeocode) {
            [[G100LocationResultManager sharedInstance] saveUserLocationWithLocation:location result:regeocode];
            // 获取定位信息后 -> 更新广告图
            [[G100StartPageManager sharedInstance] updateAdPageList:regeocode.adcode];
        }
        
        [self uploadUserLocation];
        
        if (completionBlock) {
            completionBlock(location, regeocode, error);
        }
    };
    
    [self.lmManager requestLocationWithReGeocode:YES completionBlock:proxx];
}

#pragma mark - Private Method
- (void)uploadUserLocation {
    if (!IsLogin()) {
        return;
    }
    
    NSDictionary *locationDict = [[[G100LocationResultManager sharedInstance] locationResult] mj_keyValues];
    [[G100UserApi sharedInstance] uploadUserlocationWithLocation:locationDict callback:nil];
}

#pragma mark - Lazy load
- (AMapLocationManager *)lmManager {
    if (!_lmManager) {
        _lmManager = [[AMapLocationManager alloc] init];
    }
    return _lmManager;
}

#pragma mark - 初始化单例
+ (instancetype)uploader {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    });

    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [G100LocationUploader uploader];
}

- (instancetype)copyWithZone:(struct _NSZone *)zone {
    return [G100LocationUploader uploader];
}

@end
