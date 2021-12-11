//
//  InsuranceCheckService.m
//  G100
//
//  Created by yuhanle on 2017/8/10.
//  Copyright © 2017年 Tilink. All rights reserved.
//

#import "InsuranceCheckService.h"
#import "G100InsuranceApi.h"

@implementation InsuranceCheckService

+ (instancetype)sharedService {
    static InsuranceCheckService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[InsuranceCheckService alloc] init];
    });
    return instance;
}

- (void)checkInsurancePacksWithUserid:(NSString *)userid complete:(InsuranceCheckServiceComplete)complete {
    if (kNetworkNotReachability) {
        return;
    }
    
    __weak typeof(self) wself = self;
    [[G100InsuranceApi sharedInstance] queryInsuranceOrderWithUserid:userid
                                                              status:@[ @(0) ]
                                                            callback:^(NSInteger statusCode, ApiResponse *response, BOOL requestSuccess) {
        if (requestSuccess) {
            wself.insuranceStatusPacks = [[G100InsuranceStatusPacks alloc] initWithDictionary:response.data];
            [wself configurationDataComplete:complete];
        }
    }];
}

- (void)configurationDataComplete:(InsuranceCheckServiceComplete)complete {
    NSInteger lingquCount = 0;
    NSInteger waitPayCount = 0;
    NSInteger guaranteeCount = 0;
    NSInteger expiredCount = 0;
    
    for (G100InsuranceStatusPack *pack in self.insuranceStatusPacks.list) {
        if (pack.orderlist.count) {
            if (pack.status == 9) {
                lingquCount += pack.orderlist.count;
            }
            else if (pack.status == 10) {
                waitPayCount += pack.orderlist.count;
            }
            else if (pack.status == 1) {
                guaranteeCount += pack.orderlist.count;
            }
            else if (pack.status == 8) {
                expiredCount += pack.orderlist.count;
            }
        }
    }
    
    self.lingquCount = lingquCount;
    self.waitPayCount = waitPayCount;
    self.guaranteeCount = guaranteeCount;
    self.expiredCount = expiredCount;
    
    self.totalCount = lingquCount + waitPayCount;
    
    if (complete) {
        complete(self.totalCount);
    }
}

@end
