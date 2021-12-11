//
//  G100HomeHintMgr.m
//  G100
//
//  Created by yuhanle on 2018/9/5.
//  Copyright © 2018年 Tilink. All rights reserved.
//

#import "G100HomeHintMgr.h"

@implementation G100HomeHintMgr

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (G100InsuranceManager *)insuranceDataManager {
    if (!_insuranceDataManager) {
        _insuranceDataManager = [[G100InsuranceManager alloc] init];
    }
    return _insuranceDataManager;
}

#pragma mark - Public Method
- (void)updateInfo {
    // 查询即将过期 待续费的设备列表
    NSArray *allDevsArr = [[G100InfoHelper shareInstance] findMyDevListWithUserid:self.userid bikeid:self.bikeid];
    NSMutableArray *tempDevServiceArr = [NSMutableArray array];
    for (G100DeviceDomain *deviceDomain in allDevsArr) {
        if (deviceDomain.service.left_days <= 30 && !deviceDomain.isSpecialChinaMobileDevice) {
            G100DeviceDomain *tempDomain = [[G100DeviceDomain alloc] init];
            tempDomain = deviceDomain;
            [tempDevServiceArr addObject:tempDomain];
        }
    }
    
    [tempDevServiceArr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [[NSNumber numberWithInteger:[obj1 leftdays]] compare:[NSNumber numberWithInteger:[obj2 leftdays]]];
    }];
    
    // 查询设备是否存在更新
    [self.insuranceDataManager getInsuranceModelWithUserid:self.userid bikeid:self.bikeid compete:^(G100InsuranceCardModel *insuranceModel) {
        
    }];
    
    // 查询
}

@end
